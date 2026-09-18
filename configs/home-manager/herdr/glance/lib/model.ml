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
  cwd : string option; (* タイトルが場所しか言っていないかの判定に使う *)
  focused : bool; (* 今このペインを見ているか (done の取り下げに使う) *)
  showing : string option; (* 今そのペインに出ている row_* トークン (前回の実行の置き土産) *)
}

(* idle を、最後に動いてからの時間で分ける *)
type tier = Fresh | Plain | Stale

let fresh_window = 15. *. 60.
let stale_after = 120. *. 60.

let tier ~now = function
  | None -> Plain (* 手がかりが無ければ中間として扱う *)
  | Some at ->
      let age = now -. at in
      if age < fresh_window then Fresh
      else if age >= stale_after then Stale
      else Plain

type view = V_working | V_blocked | V_done | V_idle of tier | V_unknown

let view ~now ~last_active a =
  match a.status with
  | Working -> V_working
  | Blocked -> V_blocked
  | Done -> V_done
  | Unknown -> V_unknown
  | Idle -> V_idle (tier ~now last_active)

let idle_view ~now ~last_active = V_idle (tier ~now last_active)

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
  [
    "row_working";
    "row_blocked";
    "row_done";
    "row_idle_fresh";
    "row_idle";
    "row_idle_stale";
    "row_unknown";
  ]

(* group: ワークスペースの見出し / group_stale: 中身が全部古いときの見出し /
   group_parent: worktree の親リポジトリ名 / gap: グループの区切りの空行 /
   wkey, skey: agent.view.set の並び替えキー。
   herdr は 1 回の報告で 16 個までしか受け取らないので、増やすときは数に注意する。 *)
let all_tokens =
  row_tokens @ [ "group"; "group_stale"; "group_parent"; "gap"; "wkey"; "skey" ]

let spinner_period = 0.1

let mark ~now = function
  | V_working ->
      Glyph.spinner.(int_of_float (now /. spinner_period)
                     mod Array.length Glyph.spinner)
  | V_blocked -> Glyph.blocked
  | V_done -> Glyph.done_
  | V_idle Fresh -> Glyph.idle_fresh
  | V_idle Plain -> Glyph.idle
  | V_idle Stale -> Glyph.idle_stale
  | V_unknown -> Glyph.unknown

(* 字下げ。herdr はトークンの先頭の空白を削るので、ゼロ幅スペースで守る (これは消さないこと)。

   herdr はエージェント 1 件ぶんの行を、1 行目は 1 桁、2 行目以降は 3 桁の位置から描く
   (値の無い行は詰められるので、見出しの有無でどれが 1 行目になるかが変わる)。
   そこで、そろえたい行 (エージェントの行と worktree の見出し) が 1 行目に来たときだけ
   その差の 2 桁を足す。ワークスペースの見出しとリポジトリ名は必ず 1 行目なので足さない。

   出来上がりの桁:
     1  リポジトリ名 / ワークスペースの見出し
     3  エージェントの行
     4  worktree の見出し (└─)
     5  worktree の中のエージェントの行 *)
let zwsp = "\u{200B}"
let first_line_pad = 2 (* herdr の 1 行目と 2 行目以降の差 *)
let nest_width = 2 (* worktree ひと段ぶん *)

let lead ?(first = false) ?(align = false) n =
  let n = (if first && align then first_line_pad else 0) + n in
  if n <= 0 then "" else zwsp ^ String.make n ' '

(* 各行の字下げ。first はその行が herdr の言う 1 行目に当たるか *)
let lead_repo = ""

let lead_header ~first ~child =
  if child then lead ~first ~align:true 1 else lead ~first 0

let lead_row ~first ~child =
  lead ~first ~align:true (if child then nest_width else 0)

(* --- タイトルの整形 ------------------------------------------------------ *)

let trim s = String.trim s

(* Codex は答えを待つ間、タイトルの先頭で [ ! ] と [ . ] を 1 秒ごとに入れ替える。
   行の先頭の記号が同じことを言っているうえ、1 秒ごとに書き直す羽目になるので落とす。 *)
let strip_vendor_pulse title =
  let n = String.length title in
  if n < 3 || title.[0] <> '[' then title
  else
    match String.index_opt title ']' with
    | Some close when close < 6 ->
        let inside = trim (String.sub title 1 (close - 1)) in
        if inside = "!" || inside = "." || inside = "\u{00B7}" then
          trim (String.sub title (close + 1) (n - close - 1))
        else title
    | _ -> title

let home () = Option.value (Sys.getenv_opt "HOME") ~default:""

(* シェルがタイトルに書くときの綴り: ホームそのものは ~、その下は ~ を残す *)
let tilde dir =
  let h = home () in
  if h = "" then dir
  else if dir = h then "~"
  else if String.starts_with ~prefix:(h ^ "/") dir then
    "~" ^ String.sub dir (String.length h) (String.length dir - String.length h)
  else dir

let basename = Filename.basename

(* そのタイトルは、ペインの場所しか言っていないか。
   codex はタイトルを設定しないのでシェルのものがそのまま来る ("~/src/notes: zsh" など)。
   見出しが既に言っていることなので、代わりにエージェントの名前を出す。
   先頭が「フルパス + ': '」のときだけ落とす ("herdr: 設定を直す" のような本物は残す)。 *)
let names_directory ?(allow_basename = false) text cwd =
  text = cwd || text = tilde cwd || (allow_basename && text = basename cwd)

let location_only title cwd =
  if title = "" || cwd = "" then false
  else if names_directory ~allow_basename:true title cwd then true
  else
    match String.index_opt title ':' with
    | Some i when i > 0 && i + 1 < String.length title && title.[i + 1] = ' ' ->
        names_directory (String.sub title 0 i) cwd
    | _ -> false

(* 見出しが既に出している名前を、タイトルの先頭からも消す。
   区切りが続くときだけ、かつ何か残るときだけ ("billing · billing" は残す)。 *)
let separators = [ " · "; "・"; " | "; " » "; ": "; " - "; " — "; " – " ]

let trim_group_prefix title label =
  if label = "" || not (String.starts_with ~prefix:label title) then title
  else
    let rest =
      String.sub title (String.length label)
        (String.length title - String.length label)
    in
    match
      List.find_opt (fun s -> String.starts_with ~prefix:s rest) separators
    with
    | None -> title
    | Some s ->
        let tail =
          trim
            (String.sub rest (String.length s)
               (String.length rest - String.length s))
        in
        if tail = "" then title else tail

type layout = {
  child : bool; (* worktree の中のエージェントか (ひと段深くする) *)
  header : string option; (* この行の上に出すワークスペースの見出し (字下げは patch が付ける) *)
  header_stale : bool; (* 見出しも薄くするか (そのワークスペースが全部古いとき) *)
  repo : string option; (* さらにその上に出すリポジトリ名 (親が開いていない worktree のとき) *)
  group_label : string; (* 見出しが出している名前 (タイトルの重複を削るのに使う) *)
  gap : bool; (* グループの最後の行なら、下に空行を入れる *)
  wkey : string; (* 並び替え: リポジトリ単位の新しさ *)
  skey : string; (* 並び替え: その中での順序 *)
}

let title_of a ~group_label =
  let name =
    match a.label with
    | Some l -> l
    | None -> Option.value a.agent ~default:"agent"
  in
  let vendor =
    match a.agent with
    | Some id -> Option.value (Glyph.display_name id) ~default:name
    | None -> name
  in
  let raw =
    trim (strip_vendor_pulse (trim (Option.value a.title ~default:"")))
  in
  if raw = "" then vendor
  else if location_only raw (Option.value a.cwd ~default:"") then vendor
  else trim_group_prefix raw group_label

let line ~now a v ~group_label =
  String.concat " "
    [
      mark ~now v;
      Glyph.logo (Option.value a.agent ~default:"");
      title_of a ~group_label;
    ]

let patch ~now a v l =
  let set = token_of_view v in
  (* 行は上から リポジトリ名 → 見出し → エージェント の順で、無いものは詰まる *)
  let repo = Option.map (fun r -> lead_repo ^ r) l.repo in
  let header =
    Option.map
      (fun h -> lead_header ~first:(l.repo = None) ~child:l.child ^ h)
      l.header
  in
  let row =
    lead_row ~first:(l.repo = None && l.header = None) ~child:l.child
    ^ line ~now a v ~group_label:l.group_label
  in
  List.map (fun k -> (k, if k = set then Some row else None)) row_tokens
  @ [
      ("group", if l.header_stale then None else header);
      ("group_stale", if l.header_stale then header else None);
      ("group_parent", repo);
      ("gap", if l.gap then Some zwsp else None);
      ("wkey", Some l.wkey);
      ("skey", Some l.skey);
    ]
