(* agent.list のスナップショットを受けて、ペインごとの状態を持ち、表示を書き換える *)

type pane = {
  mutable status : Model.status;
  mutable last_active : float option;
  mutable published : Fx.patch; (* 最後に書いた内容。変わらなければ書かない *)
}

type t = (string, pane) Hashtbl.t

let create () : t = Hashtbl.create 16
let any_working (t : t) = Hashtbl.fold (fun _ p acc -> acc || p.status = Model.Working) t false
let clear_patch = List.map (fun k -> (k, None)) Model.all_tokens

let sync (t : t) (agents : Model.agent list) =
  let now = Fx.now () in
  let present = Hashtbl.create 16 in
  List.iter
    (fun (a : Model.agent) ->
      Hashtbl.replace present a.pane_id ();
      let p =
        match Hashtbl.find_opt t a.pane_id with
        | Some p -> p
        | None ->
            let last_active =
              if a.status = Model.Working then Some now else Fx.last_activity a
            in
            let p = { status = a.status; last_active; published = [] } in
            Hashtbl.replace t a.pane_id p;
            p
      in
      (* 最後に動いた時刻は、動いている間と、動き終わった瞬間に刻む *)
      if a.status = Model.Working || p.status = Model.Working then p.last_active <- Some now;
      p.status <- a.status;
      let patch = Model.patch ~now a (Model.view ~now ~last_active:p.last_active a) in
      if patch <> p.published then begin
        Fx.publish a.pane_id patch;
        p.published <- patch
      end)
    agents;
  (* agent.list から消えた (エージェントが終了した / ペインが閉じた) ものは、表示を消して忘れる *)
  let gone = Hashtbl.fold (fun id _ acc -> if Hashtbl.mem present id then acc else id :: acc) t [] in
  List.iter
    (fun id ->
      Fx.publish id clear_patch;
      Hashtbl.remove t id)
    gone

let clear_panes ids = List.iter (fun id -> Fx.publish id clear_patch) ids

let clear_all (t : t) =
  Hashtbl.iter (fun id _ -> Fx.publish id clear_patch) t;
  Hashtbl.reset t
