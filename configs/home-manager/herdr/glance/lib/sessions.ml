(* 「最後に動いた時刻」の出どころ。herdr は状態しか持っていないので、
   1. 自分が前回の実行で書き残したもの (activity.json)
   2. エージェント自身の会話記録の末尾の timestamp
   の順に当たる。どちらも無ければ手がかり無しとして扱う。 *)

let home () = Option.value (Sys.getenv_opt "HOME") ~default:"/"

let state_dir () =
  let root =
    match Sys.getenv_opt "XDG_STATE_HOME" with
    | Some d when d <> "" -> d
    | _ -> Filename.concat (home ()) ".local/state"
  in
  Filename.concat root "herdr-glance"

let activity_file () = Filename.concat (state_dir ()) "activity.json"

(* --- 前回の実行が残した時刻 ---------------------------------------------- *)

let load_activity () =
  match Yojson.Safe.from_file (activity_file ()) with
  | `Assoc kv ->
      List.filter_map
        (fun (k, v) ->
          match v with
          | `Float f -> Some (k, f)
          | `Int i -> Some (k, float_of_int i)
          | _ -> None)
        kv
  | _ | (exception _) -> []

let rec mkdir_p dir =
  if dir <> "/" && dir <> "." && not (Sys.file_exists dir) then begin
    mkdir_p (Filename.dirname dir);
    try Unix.mkdir dir 0o755 with Unix.Unix_error (Unix.EEXIST, _, _) -> ()
  end

(* 落ちても壊れた JSON が残らないよう、別名で書いてから置き換える *)
let save_activity entries =
  let file = activity_file () in
  mkdir_p (Filename.dirname file);
  let tmp = file ^ ".tmp" in
  let oc = open_out tmp in
  Fun.protect
    ~finally:(fun () -> close_out oc)
    (fun () ->
      output_string oc
        (Yojson.Safe.to_string
           (`Assoc (List.map (fun (k, at) -> (k, `Float at)) entries))));
  Sys.rename tmp file

(* --- 会話記録の末尾 ------------------------------------------------------ *)

(* "2026-09-18T12:34:56.789Z" や "+09:00" 付きを epoch 秒に。閏秒は考えない *)
let days_from_civil y m d =
  let y = if m <= 2 then y - 1 else y in
  let era = (if y >= 0 then y else y - 399) / 400 in
  let yoe = y - (era * 400) in
  let mp = (m + 9) mod 12 in
  let doy = (((153 * mp) + 2) / 5) + d - 1 in
  let doe = (yoe * 365) + (yoe / 4) - (yoe / 100) + doy in
  (era * 146097) + doe - 719468

let int_at s pos len = int_of_string_opt (String.sub s pos len)

let parse_timestamp s =
  if String.length s < 19 then None
  else
    match
      ( int_at s 0 4,
        int_at s 5 2,
        int_at s 8 2,
        int_at s 11 2,
        int_at s 14 2,
        int_at s 17 2 )
    with
    | Some y, Some mo, Some d, Some h, Some mi, Some sec ->
        let base =
          float_of_int
            ((days_from_civil y mo d * 86400) + (h * 3600) + (mi * 60) + sec)
        in
        (* 末尾の時差。Z か無指定なら UTC *)
        let offset =
          let n = String.length s in
          let rec find i =
            if i < 19 then None
            else if s.[i] = '+' || s.[i] = '-' then Some i
            else find (i - 1)
          in
          match find (n - 1) with
          | Some i when n - i >= 6 -> (
              match (int_at s (i + 1) 2, int_at s (i + 4) 2) with
              | Some oh, Some om ->
                  let m = float_of_int ((oh * 3600) + (om * 60)) in
                  if s.[i] = '-' then -.m else m
              | _ -> 0.)
          | _ -> 0.
        in
        Some (base -. offset)
    | _ -> None

let tail_bytes = 256 * 1024

(* ファイルの末尾から、timestamp を持つ最後の行を探す。
   更新時刻は当てにならない (セッションを開き直すと timestamp の無い行が足される)。
   途中で切れた行は解析に失敗するだけなので読み飛ばす。 *)
let last_timestamp file =
  match open_in_bin file with
  | exception Sys_error _ -> None
  | ic ->
      Fun.protect
        ~finally:(fun () -> close_in_noerr ic)
        (fun () ->
          let size = in_channel_length ic in
          let len = min size tail_bytes in
          seek_in ic (size - len);
          let tail = really_input_string ic len in
          let lines = String.split_on_char '\n' tail in
          let rec back = function
            | [] -> None
            | line :: rest -> (
                match Yojson.Safe.from_string line with
                | `Assoc _ as j -> (
                    match Yojson.Safe.Util.member "timestamp" j with
                    | `String ts -> (
                        match parse_timestamp ts with
                        | Some _ as at -> at
                        | None -> back rest)
                    | _ -> back rest)
                | _ | (exception _) -> back rest)
          in
          back (List.rev lines))

let entries dir =
  match Sys.readdir dir with exception Sys_error _ -> [||] | names -> names

let mtime file =
  match Unix.stat file with
  | st -> Some st.Unix.st_mtime
  | exception Unix.Unix_error _ -> None

let at_of file =
  match last_timestamp file with Some _ as at -> at | None -> mtime file

(* Claude Code: ~/.claude/projects/<cwd を符号化した名前>/<セッション ID>.jsonl *)
let claude session =
  let root = Filename.concat (home ()) ".claude/projects" in
  Array.to_seq (entries root)
  |> Seq.find_map (fun d ->
      let file =
        Filename.concat (Filename.concat root d) (session ^ ".jsonl")
      in
      if Sys.file_exists file then at_of file else None)

(* Codex: ~/.codex/sessions/YYYY/MM/DD/rollout-<日時>-<セッション ID>.jsonl *)
let codex session =
  let root = Filename.concat (home ()) ".codex/sessions" in
  let dirs_under d = Array.to_seq (entries d) |> Seq.map (Filename.concat d) in
  dirs_under root |> Seq.concat_map dirs_under |> Seq.concat_map dirs_under
  |> Seq.find_map (fun file ->
      if Glyph.contains (Filename.basename file) session then at_of file
      else None)

let last_activity (a : Model.agent) =
  match (a.agent, a.session) with
  | Some agent, Some session -> (
      match String.lowercase_ascii agent with
      | "claude" -> claude session
      | "codex" -> codex session
      | _ -> None)
  | _ -> None
