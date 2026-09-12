(* エージェント自身が残す記録から、最後に動いた時刻を得る。herdr は「いつ動いたか」を
   持っていないので、このプロセスより前から開いているセッションの初期値に使う。 *)

let home () = Option.value (Sys.getenv_opt "HOME") ~default:"/"

(* Claude Code: ~/.claude/projects/<cwd を符号化した名前>/<セッション ID>.jsonl の更新時刻 *)
let claude session =
  let root = Filename.concat (home ()) ".claude/projects" in
  match Sys.readdir root with
  | exception Sys_error _ -> None
  | dirs ->
      Array.to_seq dirs
      |> Seq.find_map (fun d ->
             match Unix.stat (Filename.concat (Filename.concat root d) (session ^ ".jsonl")) with
             | st -> Some st.Unix.st_mtime
             | exception Unix.Unix_error _ -> None)

let last_activity (a : Model.agent) =
  match (a.agent, a.session) with
  | Some agent, Some session when Glyph.contains (String.lowercase_ascii agent) "claude" ->
      claude session
  | _ -> None
