(* Fx の本番用ハンドラ。時計は Eio、書き込みは herdr の socket、活動時刻は会話記録。
   socket が使えないとき (Eio.Io など) はそのまま投げ、呼び出し側が再接続する。 *)

let last_logged : (string, float) Hashtbl.t = Hashtbl.create 8

(* 同じメッセージは 1 分に 1 回まで *)
let log_limited ~now msg =
  match Hashtbl.find_opt last_logged msg with
  | Some at when now -. at < 60. -> ()
  | _ ->
      Hashtbl.replace last_logged msg now;
      Printf.eprintf "herdr-glance: %s\n%!" msg

(* 「最後に動いた時刻」の書き出しの間引き。間引いた分は pending に置いて、
   次の機会か flush (終了時) に書く *)
let persist_interval = 5.
let last_persist = ref neg_infinity
let pending = ref None

let write_activity ~now entries =
  last_persist := now;
  pending := None;
  try Sessions.save_activity entries
  with e ->
    log_limited ~now
      (Printf.sprintf "could not save activity: %s" (Printexc.to_string e))

let flush () =
  match !pending with
  | Some entries -> write_activity ~now:0. entries
  | None -> ()

let with_io ~clock ~net ~path f =
  Effect.Deep.try_with f ()
    {
      effc =
        (fun (type a) (eff : a Effect.t) ->
          match eff with
          | Fx.Now ->
              Some
                (fun (k : (a, _) Effect.Deep.continuation) ->
                  Effect.Deep.continue k (Eio.Time.now clock))
          | Fx.Publish (pane, patch) ->
              Some
                (fun k ->
                  (try Herdr.report ~net ~path pane patch
                   with Herdr.Rpc_error e ->
                     log_limited ~now:(Eio.Time.now clock)
                       (Printf.sprintf "report to %s rejected: %s" pane e));
                  Effect.Deep.continue k ())
          | Fx.Last_activity a ->
              Some (fun k -> Effect.Deep.continue k (Sessions.last_activity a))
          | Fx.Restore ->
              Some (fun k -> Effect.Deep.continue k (Sessions.load_activity ()))
          | Fx.Persist entries ->
              Some
                (fun k ->
                  let now = Eio.Time.now clock in
                  (* working の間は毎フレーム変わるので、書き出しは 5 秒に 1 回までにする *)
                  if now -. !last_persist >= persist_interval then
                    write_activity ~now entries
                  else pending := Some entries;
                  Effect.Deep.continue k ())
          | _ -> None);
    }
