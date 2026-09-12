(* サイドバーに出す Nerd Font のグリフ。どれも HackGen Console NF に入っている。
   claude と openai のロゴだけは Nerd Fonts 3.4 以降のもので、Symbols Nerd Font から出る。 *)

let utf8 cp =
  let b = Buffer.create 4 in
  Buffer.add_utf_8_uchar b (Uchar.of_int cp);
  Buffer.contents b

let done_ = utf8 0xF42E (* nf-oct-check *)
let blocked = utf8 0xF420 (* nf-oct-question *)
let idle_fresh = utf8 0xF0765 (* nf-md-circle *)
let idle = utf8 0xF0766 (* nf-md-circle_outline *)
let idle_stale = utf8 0xF4C3 (* nf-oct-dot *)
let unknown = utf8 0xF468 (* nf-oct-circle_slash *)

(* nf-md-circle_slice_1 .. 8: 円が 1/8 ずつ埋まっていく *)
let spinner = Array.init 8 (fun i -> utf8 (0xF0A9E + i))

let contains s sub =
  let n = String.length s and m = String.length sub in
  let rec go i = i + m <= n && (String.sub s i m = sub || go (i + 1)) in
  go 0

let logo agent =
  let a = String.lowercase_ascii agent in
  if contains a "claude" then utf8 0xEC82 (* nf-cod-claude *)
  else if contains a "codex" then utf8 0xEC81 (* nf-cod-openai *)
  else if contains a "copilot" then utf8 0xEC1E (* nf-cod-copilot *)
  else utf8 0xF06A9 (* nf-md-robot *)
