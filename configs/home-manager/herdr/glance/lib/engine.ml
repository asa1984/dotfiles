(* agent.list のスナップショットを受けて、ペインごとの状態と並び・グループを決め、表示を書き換える *)

type workspace = {
  label : string;
  repo_key : string option; (* worktree グループの識別子 (同じリポジトリなら同じ値) *)
  repo_name : string option;
  linked : bool; (* リンクされた worktree か (親のチェックアウトなら false) *)
}

type pane = {
  mutable status : Model.status;
  mutable last_active : float option;
  mutable published : Fx.patch; (* 最後に書いた内容。変わらなければ書かない *)
}

type t = (string, pane) Hashtbl.t

let create () : t = Hashtbl.create 16
let any_working (t : t) = Hashtbl.fold (fun _ p acc -> acc || p.status = Model.Working) t false
let clear_patch = List.map (fun k -> (k, None)) Model.all_tokens

(* 並び替えキーは分単位。文字列比較がそのまま時刻の比較になるよう 0 埋めする *)
let minute_key = function
  | None -> String.make 12 '0'
  | Some at -> Printf.sprintf "%012d" (max 0 (int_of_float (at /. 60.)))

let newer a b =
  match (a, b) with None, x | x, None -> x | Some x, Some y -> Some (Float.max x y)

let sync (t : t) ~(workspaces : (string * workspace) list) (agents : Model.agent list) =
  let now = Fx.now () in
  let ws_of id = List.assoc_opt id workspaces in
  let cluster_of id = match ws_of id with Some { repo_key = Some r; _ } -> r | _ -> id in
  let is_parent (a : Model.agent) = match ws_of a.workspace_id with Some w -> not w.linked | None -> true in
  (* 1. 状態を更新する *)
  let present = Hashtbl.create 16 in
  let entries =
    List.map
      (fun (a : Model.agent) ->
        Hashtbl.replace present a.pane_id ();
        let p =
          match Hashtbl.find_opt t a.pane_id with
          | Some p -> p
          | None ->
              let last_active = if a.status = Model.Working then Some now else Fx.last_activity a in
              let p = { status = a.status; last_active; published = [] } in
              Hashtbl.replace t a.pane_id p;
              p
        in
        (* 最後に動いた時刻は、動いている間と、動き終わった瞬間に刻む *)
        if a.status = Model.Working || p.status = Model.Working then p.last_active <- Some now;
        p.status <- a.status;
        (a, p))
      agents
  in
  (* 2. ワークスペースとリポジトリごとに、いちばん新しい時刻を集める *)
  let recency_by key_of =
    let h = Hashtbl.create 8 in
    List.iter
      (fun ((a : Model.agent), p) ->
        let k = key_of a in
        Hashtbl.replace h k (newer (Option.join (Hashtbl.find_opt h k)) p.last_active))
      entries;
    fun k -> Option.join (Hashtbl.find_opt h k)
  in
  let ws_recency = recency_by (fun a -> a.Model.workspace_id) in
  let cluster_recency = recency_by (fun a -> cluster_of a.Model.workspace_id) in
  (* 3. herdr に指定するのと同じ規則で並べる: リポジトリの新しさ → 親を先に →
        ワークスペースの新しさ → ペインの新しさ *)
  let rank ((a : Model.agent), (p : pane)) =
    ( minute_key (cluster_recency (cluster_of a.workspace_id)),
      (if is_parent a then "1" else "0"),
      minute_key (ws_recency a.workspace_id),
      minute_key p.last_active,
      a.pane_id )
  in
  let ordered =
    List.sort
      (fun x y ->
        let c1, p1, w1, a1, i1 = rank x and c2, p2, w2, a2, i2 = rank y in
        match compare c2 c1 with
        | 0 -> (
            match compare p2 p1 with
            | 0 -> (
                match compare w2 w1 with
                | 0 -> ( match compare a2 a1 with 0 -> compare i1 i2 | n -> n)
                | n -> n)
            | n -> n)
        | n -> n)
      entries
  in
  (* 4. 見出し・字下げ・空行を決めて書き込む *)
  let arr = Array.of_list ordered in
  Array.iteri
    (fun i ((a : Model.agent), p) ->
      let cl = cluster_of a.workspace_id in
      let at j = if j < 0 || j >= Array.length arr then None else Some (fst arr.(j)) in
      let same_ws q = q.Model.workspace_id = a.workspace_id in
      let same_cluster q = cluster_of q.Model.workspace_id = cl in
      let first_of_ws = match at (i - 1) with None -> true | Some q -> not (same_ws q) in
      let first_of_cluster = match at (i - 1) with None -> true | Some q -> not (same_cluster q) in
      let last_of_cluster = match at (i + 1) with None -> true | Some q -> not (same_cluster q) in
      let info = ws_of a.workspace_id in
      let child = match info with Some w -> w.linked | None -> false in
      let header =
        if not first_of_ws then None
        else
          let label = match info with Some w -> w.label | None -> a.workspace_id in
          (* worktree はリポジトリの下にぶら下げる *)
          Some (if child then Model.indent 1 ^ "└─ " ^ label else label)
      in
      (* 親のチェックアウトが開いていない worktree だけ、リポジトリ名の行を自分で立てる *)
      let repo =
        if first_of_cluster && child then match info with Some w -> w.repo_name | None -> None else None
      in
      let l =
        {
          Model.depth = (if child then 2 else 1);
          header;
          repo;
          gap = last_of_cluster;
          wkey = minute_key (cluster_recency cl);
          skey =
            (if is_parent a then "1" else "0")
            ^ minute_key (ws_recency a.workspace_id)
            ^ minute_key p.last_active;
        }
      in
      let patch = Model.patch ~now a (Model.view ~now ~last_active:p.last_active a) l in
      if patch <> p.published then begin
        Fx.publish a.pane_id patch;
        p.published <- patch
      end)
    arr;
  (* 5. agent.list から消えた (エージェントが終了した / ペインが閉じた) ものは、表示を消して忘れる *)
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
