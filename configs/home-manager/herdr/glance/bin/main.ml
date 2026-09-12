open Herdr_glance

(* 誰も動いていないときの確認間隔。状態やタイトルの変化は購読できないので、これで拾う。
   どれかが working の間は回転アニメーションのために spinner_period ごとに見直すので、
   working からの変化はすぐ反映される。遅れるのは idle などから working になるときだけ。 *)
let heartbeat = 1.0

let log fmt = Printf.ksprintf (fun s -> Printf.eprintf "herdr-glance: %s\n%!" s) fmt

let () =
  Eio_main.run @@ fun env ->
  let clock = Eio.Stdenv.clock env and net = Eio.Stdenv.net env in
  let path = Herdr.socket_path () in
  let stop = Atomic.make false in
  let on_signal = Sys.Signal_handle (fun _ -> Atomic.set stop true) in
  Sys.set_signal Sys.sigterm on_signal;
  Sys.set_signal Sys.sigint on_signal;
  let engine = Engine.create () in
  let with_fx f = Runtime.with_io ~clock ~net ~path f in
  let failures = ref 0 in
  (* 1 回の接続の間の処理。購読と描画のどちらかが抜けたら (切断・停止) 両方終わる *)
  let session () =
    let wake = Eio.Stream.create 1 in
    let poke () = if Eio.Stream.is_empty wake then Eio.Stream.add wake () in
    Eio.Fiber.first
      (fun () ->
        (* 購読は反応を速くするためのもので、拒否されても定期確認だけで動き続ける *)
        try Herdr.subscribe ~net ~path ~on_event:poke
        with Herdr.Rpc_error e ->
          log "subscription rejected (%s); relying on polling" e;
          Eio.Fiber.await_cancel ())
      (fun () ->
        let agents = Herdr.agents ~net ~path in
        let ids = List.map (fun (a : Model.agent) -> a.pane_id) agents in
        let orphans = List.filter (fun id -> not (List.mem id ids)) (Herdr.panes_with_our_tokens ~net ~path) in
        with_fx (fun () -> Engine.clear_panes orphans);
        log "connected to %s (%d agents)" path (List.length agents);
        let rec loop agents =
          if not (Atomic.get stop) then begin
            with_fx (fun () -> Engine.sync engine agents);
            failures := 0;
            let delay = if Engine.any_working engine then Model.spinner_period else heartbeat in
            Eio.Fiber.first (fun () -> Eio.Stream.take wake) (fun () -> Eio.Time.sleep clock delay);
            loop (Herdr.agents ~net ~path)
          end
        in
        loop agents)
  in
  let rec run () =
    if not (Atomic.get stop) then begin
      (match session () with
      | () -> ()
      | exception (Eio.Cancel.Cancelled _ as e) -> raise e
      | exception e ->
          incr failures;
          let backoff = Float.min 30. (0.5 *. (2. ** float_of_int (min !failures 6))) in
          if !failures = 1 || !failures mod 10 = 0 then
            log "herdr unavailable (%s); retrying in %.1fs" (Printexc.to_string e) backoff;
          Eio.Time.sleep clock backoff);
      run ()
    end
  in
  run ();
  (try with_fx (fun () -> Engine.clear_all engine)
   with e -> log "could not clear tokens on exit: %s" (Printexc.to_string e));
  log "stopped"
