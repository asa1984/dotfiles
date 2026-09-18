(* サイドバーに出す記号。エージェントのロゴと状態の記号は herdr-agent-icons
   (pkgs/herdr-agent-icons、herdr-radar が配っている専用フォント) の私用領域から出す。
   ghostty は font-codepoint-map で U+E1A0-U+E1B6 と U+E1C0-U+E1C5 をこの face に振っている。

   Nerd Font の記号 (✓ ○ など) を借りないのは、HackGen に無いものが CJK フォントに
   落ちて全角で描かれるため。専用フォントなら幅も大きさも揃う。 *)

let utf8 cp =
  let b = Buffer.create 4 in
  Buffer.add_utf_8_uchar b (Uchar.of_int cp);
  Buffer.contents b

(* 状態の記号。idle の 3 段階は形でも見分けられるよう別の字にしている
   (radar は同じ輪を色だけで分ける) *)
let done_ = utf8 0xE1C0
let blocked = utf8 0xE1C1
let idle = utf8 0xE1C2
let unknown = utf8 0xE1C3
let idle_fresh = utf8 0xE1C4
let idle_stale = utf8 0xE1C5

(* 点字のスピナー (⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏)。Unicode の点字で、HackGen には無いため
   ghostty が別のフォントで補う。 *)
let spinner =
  Array.map utf8
    [|
      0x280B;
      0x2819;
      0x2839;
      0x2838;
      0x283C;
      0x2834;
      0x2826;
      0x2827;
      0x2807;
      0x280F;
    |]

let contains s sub =
  let n = String.length s and m = String.length sub in
  let rec go i = i + m <= n && (String.sub s i m = sub || go (i + 1)) in
  go 0

(* herdr が正規化したエージェント ID (detect::agent_label) と、フォントの符号位置・表示名。
   フォントに無いもの (droid, muse など) はロボットの記号に落とす。 *)
let vendors =
  [
    ("claude", 0xE1A0, "Claude Code");
    ("codex", 0xE1A1, "Codex");
    ("opencode", 0xE1A2, "OpenCode");
    ("omp", 0xE1A3, "OhMyPosh");
    ("cline", 0xE1A4, "Cline");
    ("mastracode", 0xE1A5, "Mastra");
    ("kimi", 0xE1A6, "Kimi");
    ("kilo", 0xE1A7, "Kilo");
    ("maki", 0xE1A8, "Maki");
    ("pi", 0xE1A9, "Pi");
    ("hermes", 0xE1AA, "Hermes");
    ("cursor", 0xE1AB, "Cursor");
    ("copilot", 0xE1AC, "Copilot");
    ("deepseek", 0xE1AD, "DeepSeek");
    ("gemini", 0xE1AE, "Gemini");
    ("gpt", 0xE1AF, "GPT");
    ("qwen", 0xE1B0, "Qwen");
    ("grok", 0xE1B1, "Grok");
    ("agy", 0xE1B2, "Antigravity");
    ("kiro", 0xE1B3, "Kiro");
    ("amp", 0xE1B4, "Amp");
    ("devin", 0xE1B5, "Devin");
    ("qodercli", 0xE1B6, "Qoder");
  ]

let robot = utf8 0xF06A9 (* nf-md-robot *)

(* herdr は正規化した ID を送ってくるが、取りこぼしたときのために部分一致でも拾う *)
let vendor agent =
  let a = String.lowercase_ascii agent in
  match List.find_opt (fun (id, _, _) -> id = a) vendors with
  | Some v -> Some v
  | None -> List.find_opt (fun (id, _, _) -> contains a id) vendors

let logo agent =
  match vendor agent with Some (_, cp, _) -> utf8 cp | None -> robot

(* タイトルが場所しか言っていないときに代わりに出す名前。知らないエージェントには無い *)
let display_name agent =
  match vendor agent with Some (_, _, name) -> Some name | None -> None
