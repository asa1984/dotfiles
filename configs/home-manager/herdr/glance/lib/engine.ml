(* agent.list のスナップショットを受けて、ペインごとの状態と並び・グループを決め、表示を書き換える *)

type workspace = {
  label : string;
  repo_key : string option; (* worktree グループの識別子 (同じリポジトリなら同じ値) *)
  repo_name : string option;
  linked : bool; (* リンクされた worktree か (親のチェックアウトなら false) *)
}

type pane = {
  mutable status : Model.status; (* 猶予を当てた後の状態 *)
  mutable last_active : float option; (* 最後に working だった時刻 *)
  mutable done_held : bool; (* 終わった印を、そのペインを見るまで出し続ける *)
  mutable blocked_held : bool; (* 質問の印を、また動き出すまで出し続ける *)
  mutable blocked_after_work : bool; (* その質問は作業中に出たものか (起動時の確認は保持しない) *)
  mutable published : Fx.patch; (* 最後に書いた内容。変わらなければ書かない *)
}

type t = {
  panes : (string, pane) Hashtbl.t;
  mutable restored : (string * float) list option;
      (* 前回の実行が残した時刻 (最初の sync で読む) *)
  mutable saved : (string * float) list; (* 最後に書き戻した内容 *)
}

let create () = { panes = Hashtbl.create 16; restored = None; saved = [] }

let any_working t =
  Hashtbl.fold (fun _ p acc -> acc || p.status = Model.Working) t.panes false

let clear_patch = List.map (fun k -> (k, None)) Model.all_tokens

(* working をやめた直後の短い間は、まだ working として見せる。
   herdr の検出が一瞬 idle に振れても行が瞬かない。質問 (blocked) は急ぐので対象外。 *)
let grace = 2.5

(* 並び替えキーは分単位。文字列比較がそのまま時刻の比較になるよう 0 埋めする *)
let minute_key = function
  | None -> String.make 12 '0'
  | Some at -> Printf.sprintf "%012d" (max 0 (int_of_float (at /. 60.)))

let newer a b =
  match (a, b) with
  | None, x | x, None -> x
  | Some x, Some y -> Some (Float.max x y)

(* 前回の実行が書いたトークンから、出していた状態を引き継ぐ *)
let showed_done (a : Model.agent) = a.showing = Some "row_done"
let showed_blocked (a : Model.agent) = a.showing = Some "row_blocked"

let seen_pane t ~now (a : Model.agent) =
  match Hashtbl.find_opt t.panes a.pane_id with
  | Some p -> (p, false)
  | None ->
      let restored =
        match t.restored with
        | Some m -> List.assoc_opt a.pane_id m
        | None -> None
      in
      let last_active =
        if a.status = Model.Working then Some now
        else
          match restored with Some _ as at -> at | None -> Fx.last_activity a
      in
      let p =
        {
          status = a.status;
          last_active;
          (* 前の常駐プロセスが出していた印は、こちらが引き継ぐ (switch のたびに消えないように) *)
          done_held = showed_done a && a.status <> Model.Working;
          blocked_held = showed_blocked a && a.status <> Model.Working;
          blocked_after_work = true;
          published = [];
        }
      in
      Hashtbl.replace t.panes a.pane_id p;
      (p, true)

(* herdr が言う状態と、こちらが覚えていることから、実際に出すものを決める *)
let display_of ~now (a : Model.agent) (p : pane) ~fresh =
  if a.status = Model.Working then p.last_active <- Some now;
  let since_working =
    match p.last_active with Some at -> now -. at | None -> infinity
  in
  let in_grace =
    (not fresh)
    && (a.status = Model.Idle || a.status = Model.Done)
    && since_working < grace
  in
  let status = if in_grace then Model.Working else a.status in
  (* working から idle/done に落ちた瞬間が、ひとつの作業の終わり *)
  if p.status = Model.Working && (status = Model.Idle || status = Model.Done)
  then p.done_held <- true;
  (* 質問は、答えて動き出すまで残す。ただし起動時の確認 (まだ一度も動いていない) は残さない *)
  if status = Model.Blocked then
    begin if not p.blocked_held then begin
      p.blocked_held <- true;
      p.blocked_after_work <- p.last_active <> None
    end
    end
  else if status = Model.Working || not p.blocked_after_work then
    p.blocked_held <- false;
  p.status <- status;
  (* 見たら、終わった印は下ろす *)
  if a.focused then p.done_held <- false;
  if status = Model.Working then begin
    p.done_held <- false;
    p.blocked_held <- false;
    Model.V_working
  end
  else if p.blocked_held then begin
    p.done_held <- false;
    Model.V_blocked
  end
  else if p.done_held then Model.V_done
  else if status = Model.Idle then
    Model.idle_view ~now ~last_active:p.last_active
  else Model.view ~now ~last_active:p.last_active a

let sync t ~(workspaces : (string * workspace) list) (agents : Model.agent list)
    =
  let now = Fx.now () in
  if t.restored = None then t.restored <- Some (Fx.restore ());
  let ws_of id = List.assoc_opt id workspaces in
  let cluster_of id =
    match ws_of id with Some { repo_key = Some r; _ } -> r | _ -> id
  in
  let is_parent (a : Model.agent) =
    match ws_of a.workspace_id with Some w -> not w.linked | None -> true
  in
  (* 1. 状態を更新し、出すものを決める *)
  let present = Hashtbl.create 16 in
  let entries =
    List.map
      (fun (a : Model.agent) ->
        Hashtbl.replace present a.pane_id ();
        let p, fresh = seen_pane t ~now a in
        let display = display_of ~now a p ~fresh in
        (a, p, display))
      agents
  in
  (* 2. ワークスペースとリポジトリごとに、いちばん新しい時刻を集める *)
  let recency_by key_of =
    let h = Hashtbl.create 8 in
    List.iter
      (fun ((a : Model.agent), (p : pane), _) ->
        let k = key_of a in
        Hashtbl.replace h k
          (newer (Option.join (Hashtbl.find_opt h k)) p.last_active))
      entries;
    fun k -> Option.join (Hashtbl.find_opt h k)
  in
  let ws_recency = recency_by (fun a -> a.Model.workspace_id) in
  let cluster_recency = recency_by (fun a -> cluster_of a.Model.workspace_id) in
  (* 3. herdr に渡すのと同じ文字列で並べる。同じ時刻のグループが混ざらないよう ID まで入れる:
        リポジトリの新しさ → 親を先に → ワークスペースの新しさ → ペインの新しさ *)
  let wkey_of (a : Model.agent) =
    let cl = cluster_of a.workspace_id in
    minute_key (cluster_recency cl) ^ "-" ^ cl
  in
  let skey_of (a : Model.agent) (p : pane) =
    String.concat "-"
      [
        (if is_parent a then "1" else "0")
        ^ minute_key (ws_recency a.workspace_id);
        a.workspace_id;
        minute_key p.last_active;
        a.pane_id;
      ]
  in
  let keyed =
    List.map (fun (a, p, d) -> (wkey_of a, skey_of a p, a, p, d)) entries
  in
  let ordered =
    List.sort
      (fun (w1, s1, _, _, _) (w2, s2, _, _, _) ->
        match compare w2 w1 with 0 -> compare s2 s1 | n -> n)
      keyed
  in
  let arr = Array.of_list ordered in
  let ws_of_entry (_, _, (a : Model.agent), _, _) = a.workspace_id in
  (* 4. 全部が古くなったワークスペースは、見出しも薄くする *)
  let stale_ws =
    let h = Hashtbl.create 8 in
    Array.iter
      (fun (_, _, (a : Model.agent), _, d) ->
        let all_stale = d = Model.V_idle Model.Stale in
        Hashtbl.replace h a.workspace_id
          (all_stale
          && Option.value (Hashtbl.find_opt h a.workspace_id) ~default:true))
      arr;
    fun id -> Option.value (Hashtbl.find_opt h id) ~default:false
  in
  (* 5. 同じリポジトリの worktree のうち、表示順で最後のものだけ └─ を使う *)
  let last_child =
    let h = Hashtbl.create 8 in
    Array.iter
      (fun (_, _, (a : Model.agent), _, _) ->
        match ws_of a.workspace_id with
        | Some w when w.linked ->
            Hashtbl.replace h (cluster_of a.workspace_id) a.workspace_id
        | _ -> ())
      arr;
    fun cl ws -> Hashtbl.find_opt h cl = Some ws
  in
  (* 6. 見出し・字下げ・空行を決めて書き込む *)
  Array.iteri
    (fun i (wkey, skey, (a : Model.agent), p, display) ->
      let cl = cluster_of a.workspace_id in
      let at j =
        if j < 0 || j >= Array.length arr then None else Some arr.(j)
      in
      let same_ws q = ws_of_entry q = a.workspace_id in
      let same_cluster q = cluster_of (ws_of_entry q) = cl in
      let first_of_ws =
        match at (i - 1) with None -> true | Some q -> not (same_ws q)
      in
      let first_of_cluster =
        match at (i - 1) with None -> true | Some q -> not (same_cluster q)
      in
      let last_of_cluster =
        match at (i + 1) with None -> true | Some q -> not (same_cluster q)
      in
      let info = ws_of a.workspace_id in
      let child = match info with Some w -> w.linked | None -> false in
      let label =
        match info with Some w -> w.label | None -> a.workspace_id
      in
      let header =
        if not first_of_ws then None
        else if child then
          (* worktree はリポジトリの下にぶら下げる。同じ親の最後のものだけ └─ *)
          Some ((if last_child cl a.workspace_id then "└─ " else "├─ ") ^ label)
        else Some label
      in
      (* 親のチェックアウトが開いていない worktree だけ、リポジトリ名の行を自分で立てる *)
      let repo =
        if first_of_cluster && child then
          match info with Some w -> w.repo_name | None -> None
        else None
      in
      let l =
        {
          Model.child;
          header;
          header_stale = header <> None && stale_ws a.workspace_id;
          repo;
          group_label = label;
          gap = last_of_cluster;
          wkey;
          skey;
        }
      in
      let patch = Model.patch ~now a display l in
      if patch <> p.published then begin
        Fx.publish a.pane_id patch;
        p.published <- patch
      end)
    arr;
  (* 7. agent.list から消えた (エージェントが終了した / ペインが閉じた) ものは、表示を消して忘れる *)
  let gone =
    Hashtbl.fold
      (fun id _ acc -> if Hashtbl.mem present id then acc else id :: acc)
      t.panes []
  in
  List.iter
    (fun id ->
      Fx.publish id clear_patch;
      Hashtbl.remove t.panes id)
    gone;
  (* 8. 「最後に動いた時刻」を書き戻す。次の起動でここから読み直す *)
  let stamps =
    Hashtbl.fold
      (fun id p acc ->
        match p.last_active with Some at -> (id, at) :: acc | None -> acc)
      t.panes []
    |> List.sort compare
  in
  if stamps <> t.saved then begin
    t.saved <- stamps;
    Fx.persist stamps
  end

let clear_panes ids = List.iter (fun id -> Fx.publish id clear_patch) ids

let clear_all t =
  Hashtbl.iter (fun id _ -> Fx.publish id clear_patch) t.panes;
  Hashtbl.reset t.panes
