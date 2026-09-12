(* agent.list の 1 件から、サイドバーに何を書くかを決める純粋な部分 *)

type status = Idle | Working | Blocked | Done | Unknown

let status_of_string = function
  | "idle" -> Idle
  | "working" -> Working
  | "blocked" -> Blocked
  | "done" -> Done (* herdr 0.9 では「idle かつまだ見ていない」 *)
  | _ -> Unknown

type agent = {
  pane_id : string;
  workspace_id : string;
  agent : string option; (* 正規化されたエージェント ID ("claude" など) *)
  label : string option; (* 表示名 (display_agent があればそれ) *)
  status : status;
  title : string option; (* terminal_title_stripped: エージェントが今やっていること *)
  session : string option; (* agent_session.value: エージェント自身のセッション ID *)
}

(* idle を、最後に動いてからの時間で分ける *)
type tier = Fresh | Plain | Stale

let fresh_window = 15. *. 60.
let stale_after = 120. *. 60.

let tier ~now = function
  | None -> Plain (* 手がかりが無ければ中間として扱う *)
  | Some at ->
      let age = now -. at in
      if age < fresh_window then Fresh else if age >= stale_after then Stale else Plain

type view = V_working | V_blocked | V_done | V_idle of tier | V_unknown

let view ~now ~last_active a =
  match a.status with
  | Working -> V_working
  | Blocked -> V_blocked
  | Done -> V_done
  | Unknown -> V_unknown
  | Idle -> V_idle (tier ~now last_active)

(* herdr のサイドバーのスタイルはトークン名に結び付くので、状態ごとに別名のトークンを使う。
   今の状態のものに 1 行分を入れ、他は消す。config.toml の rows がそれぞれに色を付ける。 *)
let token_of_view = function
  | V_working -> "row_working"
  | V_blocked -> "row_blocked"
  | V_done -> "row_done"
  | V_idle Fresh -> "row_idle_fresh"
  | V_idle Plain -> "row_idle"
  | V_idle Stale -> "row_idle_stale"
  | V_unknown -> "row_unknown"

let row_tokens =
  [ "row_working"; "row_blocked"; "row_done"; "row_idle_fresh"; "row_idle"; "row_idle_stale"; "row_unknown" ]

(* group: ワークスペースの見出し / group_parent: worktree の親リポジトリ名 /
   gap: グループの区切りの空行 / wkey, skey: agent.view.set の並び替えキー *)
let all_tokens = row_tokens @ [ "group"; "group_parent"; "gap"; "wkey"; "skey" ]

let spinner_period = 0.1

let mark ~now = function
  | V_working -> Glyph.spinner.(int_of_float (now /. spinner_period) mod Array.length Glyph.spinner)
  | V_blocked -> Glyph.blocked
  | V_done -> Glyph.done_
  | V_idle Fresh -> Glyph.idle_fresh
  | V_idle Plain -> Glyph.idle
  | V_idle Stale -> Glyph.idle_stale
  | V_unknown -> Glyph.unknown

(* herdr はトークンの先頭の空白を削るので、字下げはゼロ幅スペースで守る。
   1 段あたりの空白の数はここで変える (ゼロ幅スペースは消さないこと)。 *)
let zwsp = "\u{200B}"
let indent_width = 1
let indent depth = if depth <= 0 then "" else zwsp ^ String.make (depth * indent_width) ' '

type layout = {
  depth : int; (* 行の字下げの深さ *)
  header : string option; (* この行の上に出すワークスペースの見出し *)
  repo : string option; (* さらにその上に出すリポジトリ名 (親が開いていない worktree のとき) *)
  gap : bool; (* グループの最後の行なら、下に空行を入れる *)
  wkey : string; (* 並び替え: リポジトリ単位の新しさ *)
  skey : string; (* 並び替え: その中での順序 *)
}

let line ~now a v =
  let name = match a.label with Some l -> l | None -> Option.value a.agent ~default:"agent" in
  let title = match a.title with Some t when String.trim t <> "" -> t | _ -> name in
  String.concat " " [ mark ~now v; Glyph.logo (Option.value a.agent ~default:""); title ]

let patch ~now a v l =
  let set = token_of_view v in
  List.map (fun k -> (k, if k = set then Some (indent l.depth ^ line ~now a v) else None)) row_tokens
  @ [
      ("group", l.header);
      ("group_parent", l.repo);
      ("gap", if l.gap then Some zwsp else None);
      ("wkey", Some l.wkey);
      ("skey", Some l.skey);
    ]
