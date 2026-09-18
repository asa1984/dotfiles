open Herdr_glance

let ws ?(label = "dotfiles") ?repo_key ?repo_name ?(linked = false) id =
  (id, { Engine.label; repo_key; repo_name; linked })

let agent ?(pane = "w1:p1") ?(workspace = "w1") ?(agent = Some "claude")
    ?(title = Some "Implement OAuth scopes") ?(cwd = Some "/Users/x/src/dotfiles") ?(focused = false)
    ?(showing : string option) status =
  {
    Model.pane_id = pane;
    workspace_id = workspace;
    agent;
    label = agent;
    status;
    title;
    session = Some "s1";
    cwd;
    focused;
    showing;
  }

(* テスト用のハンドラ: 時計は参照、書き込みは記録、会話記録は seed を返す。
   保存した時刻は restored から読ませ、書き戻しは persisted に記録する *)
let persisted = ref []

let run ?(seed : float option = None) ?(restored = []) ~(clock : float ref) f =
  let published = ref [] in
  persisted := [];
  Effect.Deep.try_with f ()
    {
      effc =
        (fun (type a) (eff : a Effect.t) ->
          match eff with
          | Fx.Now -> Some (fun (k : (a, _) Effect.Deep.continuation) -> Effect.Deep.continue k !clock)
          | Fx.Publish (pane, patch) ->
              Some
                (fun k ->
                  published := (pane, patch) :: !published;
                  Effect.Deep.continue k ())
          | Fx.Last_activity _ -> Some (fun k -> Effect.Deep.continue k seed)
          | Fx.Restore -> Some (fun k -> Effect.Deep.continue k restored)
          | Fx.Persist entries ->
              Some
                (fun k ->
                  persisted := entries;
                  Effect.Deep.continue k ())
          | _ -> None);
    };
  List.rev !published

(* あるペインに最後に書かれた内容 *)
let last pane published =
  List.fold_left (fun acc (p, patch) -> if p = pane then Some patch else acc) None published

let value pane key published = Option.bind (last pane published) (fun patch -> List.assoc key patch)

let row pane published =
  match last pane published with
  | None -> None
  | Some patch -> (
      match List.filter (fun (k, v) -> String.starts_with ~prefix:"row_" k && v <> None) patch with
      | [ (k, Some v) ] -> Some (k, v)
      | _ -> None)

let token pane published = Option.map fst (row pane published)
let check_token msg expected p = Alcotest.(check (option string)) msg expected (token "w1:p1" p)
let t0 = 1_800_000_000.
let one = [ ws "w1" ]

let test_working () =
  let e = Engine.create () and clock = ref t0 in
  let p = run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]) in
  check_token "token" (Some "row_working") p;
  (match row "w1:p1" p with
  | Some (_, v) ->
      Alcotest.(check bool) "indented with a zero-width space" true
        (String.starts_with ~prefix:(Model.lead_row ~first:false ~child:false) v);
      Alcotest.(check bool) "carries a spinner frame" true
        (Array.exists (fun g -> Glyph.contains v g) Glyph.spinner);
      Alcotest.(check bool) "carries the title" true (Glyph.contains v "Implement OAuth scopes")
  | None -> Alcotest.fail "nothing shown");
  Alcotest.(check bool) "any_working" true (Engine.any_working e)

let test_spinner_advances () =
  let e = Engine.create () and clock = ref t0 in
  let p1 = run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]) in
  let same = run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]) in
  Alcotest.(check int) "no rewrite when nothing changed" 0 (List.length same);
  clock := t0 +. (Model.spinner_period *. 1.5);
  let p2 = run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]) in
  Alcotest.(check bool) "next frame" true (row "w1:p1" p1 <> row "w1:p1" p2)

let test_idle_tiers () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]));
  clock := t0 +. 60.;
  (* 作業の直後は done を出し続けるので、idle の段階を見るには一度見たことにする *)
  let agent ?(pane = "w1:p1") status = agent ~pane ~focused:true status in
  check_token "fresh right after a turn" (Some "row_idle_fresh")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]));
  clock := t0 +. 60. +. (20. *. 60.);
  check_token "plain after 20 minutes" (Some "row_idle")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]));
  clock := t0 +. 60. +. (121. *. 60.);
  check_token "stale after two hours" (Some "row_idle_stale")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]))

let test_first_seen_idle () =
  let clock = ref t0 in
  check_token "no evidence is neutral" (Some "row_idle")
    (run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:one [ agent Model.Idle ]));
  check_token "seeded from the transcript" (Some "row_idle_stale")
    (run ~seed:(Some (t0 -. (3. *. 3600.))) ~clock (fun () ->
         Engine.sync (Engine.create ()) ~workspaces:one [ agent Model.Idle ]))

let test_states () =
  let clock = ref t0 in
  List.iter
    (fun (status, expected) ->
      check_token expected (Some expected)
        (run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:one [ agent status ])))
    [ (Model.Blocked, "row_blocked"); (Model.Done, "row_done"); (Model.Unknown, "row_unknown") ]

(* --- 状態の保持 --- *)

let test_done_held_until_seen () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]));
  clock := t0 +. 60.;
  check_token "a finished turn shows done" (Some "row_done")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]));
  clock := t0 +. 3600.;
  (* 変わらない間は書き直さないので、「何も書かれない」= done のまま *)
  Alcotest.(check int) "and keeps showing it" 0
    (List.length (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ])));
  check_token "until the pane is looked at" (Some "row_idle")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent ~focused:true Model.Idle ]))

let test_blocked_held_until_answered () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]));
  clock := t0 +. 10.;
  check_token "a question shows" (Some "row_blocked")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Blocked ]));
  clock := t0 +. 20.;
  Alcotest.(check int) "and survives herdr calling it idle" 0
    (List.length (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent ~focused:true Model.Idle ])));
  clock := t0 +. 30.;
  check_token "answering it starts work again" (Some "row_working")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]))

let test_startup_prompt_not_held () =
  let e = Engine.create () and clock = ref t0 in
  check_token "a question before any work shows" (Some "row_blocked")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Blocked ]));
  clock := t0 +. 10.;
  check_token "but is not held once answered" (Some "row_idle")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]))

let test_grace () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]));
  (* スピナーは 1 秒でひと回りするので、丸 1 秒ずらすと同じ絵になる。半端な時刻で見る *)
  clock := t0 +. 0.5;
  check_token "a blip stays working" (Some "row_working")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]));
  clock := t0 +. 3.;
  check_token "a real turn end gets through" (Some "row_done")
    (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]))

let test_adopts_published_marks () =
  let clock = ref t0 in
  check_token "done left by the last run is kept" (Some "row_done")
    (run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:one [ agent ~showing:"row_done" Model.Idle ]));
  check_token "so is a question" (Some "row_blocked")
    (run ~clock (fun () ->
         Engine.sync (Engine.create ()) ~workspaces:one [ agent ~showing:"row_blocked" Model.Idle ]))

(* --- 最後に動いた時刻の保存 --- *)

let test_activity_round_trip () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Working ]));
  Alcotest.(check (list (pair string (float 0.001)))) "the stamp is written out" [ ("w1:p1", t0) ] !persisted;
  (* 別のプロセスとして立ち上げ直しても、保存した時刻から段階が決まる *)
  clock := t0 +. (200. *. 60.);
  check_token "restored as stale" (Some "row_idle_stale")
    (run ~restored:[ ("w1:p1", t0) ] ~clock (fun () ->
         Engine.sync (Engine.create ()) ~workspaces:one [ agent ~focused:true Model.Idle ]))

let test_vanished_agent () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e ~workspaces:one [ agent Model.Idle ]));
  let p = run ~clock (fun () -> Engine.sync e ~workspaces:one []) in
  Alcotest.(check (option (list (pair string (option string))))) "every token cleared"
    (Some Engine.clear_patch) (last "w1:p1" p);
  Alcotest.(check int) "forgotten" 0 (List.length (run ~clock (fun () -> Engine.sync e ~workspaces:one [])))

let test_title_fallback () =
  let clock = ref t0 in
  match
    row "w1:p1"
      (run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:one [ agent ~title:(Some "  ") Model.Idle ]))
  with
  | Some (_, v) -> Alcotest.(check bool) "falls back to the agent name" true (String.ends_with ~suffix:"Claude Code" v)
  | None -> Alcotest.fail "nothing shown"

(* --- グループ表示 --- *)

let test_groups () =
  let clock = ref t0 in
  let spaces = [ ws "w1"; ws ~label:"azi" "w2" ] in
  let agents = [ agent Model.Working; agent ~pane:"w2:p1" ~workspace:"w2" Model.Idle ] in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:spaces agents) in
  Alcotest.(check (option (option string))) "header on the first row of its workspace"
    (Some (Some "dotfiles"))
    (Some (value "w1:p1" "group" p));
  Alcotest.(check (option (option string))) "the other workspace gets its own"
    (Some (Some "azi"))
    (Some (value "w2:p1" "group" p));
  Alcotest.(check bool) "a gap closes each group" true
    (value "w1:p1" "gap" p <> None && value "w2:p1" "gap" p <> None);
  Alcotest.(check bool) "the busier workspace sorts first" true
    (value "w1:p1" "wkey" p > value "w2:p1" "wkey" p)

let test_second_member_has_no_header () =
  let clock = ref t0 in
  let agents = [ agent Model.Working; agent ~pane:"w1:p2" Model.Idle ] in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:one agents) in
  Alcotest.(check (option string)) "only the first row carries the header" None (value "w1:p2" "group" p);
  Alcotest.(check bool) "the gap sits on the last row" true
    (value "w1:p1" "gap" p = None && value "w1:p2" "gap" p <> None)

(* herdr が描く列: エージェント 1 件ぶんの 1 行目は 1 桁、2 行目以降は 3 桁の字下げの後に値が続く *)
let column ~first v =
  let v = if String.starts_with ~prefix:Model.zwsp v then String.sub v 3 (String.length v - 3) else v in
  let rec spaces i = if i < String.length v && v.[i] = ' ' then spaces (i + 1) else i in
  (if first then 1 else 3) + spaces 0

let test_rows_line_up () =
  let clock = ref t0 in
  let agents = [ agent Model.Working; agent ~pane:"w1:p2" Model.Idle ] in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:one agents) in
  let col pane first = match row pane p with Some (_, v) -> column ~first v | None -> -1 in
  (* p1 は見出しの下の 2 行目、p2 は見出しが無いので 1 行目になる *)
  Alcotest.(check int) "rows of one workspace share a column" (col "w1:p1" false) (col "w1:p2" true);
  Alcotest.(check int) "at herdr's own continuation column" 3 (col "w1:p1" false);
  match value "w1:p1" "group" p with
  | Some h -> Alcotest.(check int) "the header stays at the margin" 1 (column ~first:true h)
  | None -> Alcotest.fail "no header"

let test_worktree_nesting () =
  let clock = ref t0 in
  let spaces =
    [ ws ~label:"repo" ~repo_key:"R" ~repo_name:"repo" "wp";
      ws ~label:"feature-x" ~repo_key:"R" ~repo_name:"repo" ~linked:true "wc" ]
  in
  (* 子のほうが新しくても、親のチェックアウトが先に並ぶ *)
  let agents = [ agent ~pane:"wp:p1" ~workspace:"wp" Model.Idle; agent ~pane:"wc:p1" ~workspace:"wc" Model.Working ] in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:spaces agents) in
  Alcotest.(check (option string)) "repo header" (Some "repo") (value "wp:p1" "group" p);
  Alcotest.(check (option string)) "worktree hangs under it" (Some (Model.lead_header ~first:true ~child:true ^ "└─ feature-x"))
    (value "wc:p1" "group" p);
  Alcotest.(check bool) "same sort group" true (value "wp:p1" "wkey" p = value "wc:p1" "wkey" p);
  Alcotest.(check bool) "parent sorts first" true (value "wp:p1" "skey" p > value "wc:p1" "skey" p);
  Alcotest.(check bool) "no gap between the two" true (value "wp:p1" "gap" p = None);
  Alcotest.(check bool) "the worktree's row is indented deeper" true
    (match row "wc:p1" p with
    | Some (_, v) -> String.starts_with ~prefix:(Model.lead_row ~first:false ~child:true) v
    | None -> false);
  Alcotest.(check (option string)) "no synthesised repo row when the parent is open" None
    (value "wp:p1" "group_parent" p)

let test_orphan_worktree () =
  let clock = ref t0 in
  let spaces = [ ws ~label:"feature-x" ~repo_key:"R" ~repo_name:"repo" ~linked:true "wc" ] in
  let p =
    run ~clock (fun () ->
        Engine.sync (Engine.create ()) ~workspaces:spaces [ agent ~pane:"wc:p1" ~workspace:"wc" Model.Idle ])
  in
  Alcotest.(check (option string)) "repo name gets a row of its own" (Some "repo")
    (value "wc:p1" "group_parent" p);
  Alcotest.(check (option string)) "the worktree header is its second line" (Some (Model.lead_header ~first:false ~child:true ^ "└─ feature-x"))
    (value "wc:p1" "group" p)

let test_sort_keys_carry_ids () =
  let clock = ref t0 in
  (* 時刻が同じ (どちらも動いていない) 2 つのワークスペース *)
  let spaces = [ ws "w1"; ws ~label:"azi" "w2" ] in
  let agents = [ agent Model.Idle; agent ~pane:"w2:p1" ~workspace:"w2" Model.Idle ] in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:spaces agents) in
  Alcotest.(check bool) "different workspaces get different keys" true
    (value "w1:p1" "wkey" p <> value "w2:p1" "wkey" p);
  Alcotest.(check bool) "the workspace id is in the key" true
    (match value "w1:p1" "skey" p with Some k -> Glyph.contains k "w1" | None -> false)

let test_stale_group_header () =
  let clock = ref t0 in
  let p =
    run ~restored:[ ("w1:p1", t0 -. (200. *. 60.)) ] ~clock (fun () ->
        Engine.sync (Engine.create ()) ~workspaces:one [ agent ~focused:true Model.Idle ])
  in
  Alcotest.(check (option string)) "an all-stale workspace moves its header" None (value "w1:p1" "group" p);
  Alcotest.(check bool) "to the dimmer token" true (value "w1:p1" "group_stale" p <> None)

let test_worktree_corners () =
  let clock = ref t0 in
  let spaces =
    [ ws ~label:"repo" ~repo_key:"R" ~repo_name:"repo" "wp";
      ws ~label:"feature-x" ~repo_key:"R" ~repo_name:"repo" ~linked:true "wa";
      ws ~label:"feature-y" ~repo_key:"R" ~repo_name:"repo" ~linked:true "wb" ]
  in
  let agents =
    [ agent ~pane:"wp:p1" ~workspace:"wp" Model.Idle;
      agent ~pane:"wa:p1" ~workspace:"wa" Model.Idle;
      agent ~pane:"wb:p1" ~workspace:"wb" Model.Idle ]
  in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:spaces agents) in
  let headers =
    List.filter_map (fun pane -> value pane "group" p) [ "wp:p1"; "wa:p1"; "wb:p1" ]
  in
  Alcotest.(check int) "one ├─ among the worktrees" 1
    (List.length (List.filter (fun h -> Glyph.contains h "├─") headers));
  Alcotest.(check int) "and one └─ for the last" 1
    (List.length (List.filter (fun h -> Glyph.contains h "└─") headers))

(* --- タイトルの整形 --- *)

let title_shown ?(group_label = "dotfiles") a =
  Model.title_of a ~group_label

let test_title_cleanup () =
  (* 「場所しか言っていない」判定は ~ の綴りを見るので、実際の HOME の下で試す *)
  let cwd = Filename.concat (Option.value (Sys.getenv_opt "HOME") ~default:"/tmp") "src/dotfiles" in
  let a = agent ~cwd:(Some cwd) Model.Idle in
  Alcotest.(check string) "codex's pulse is dropped" "Action Required"
    (title_shown { a with title = Some "[ ! ] Action Required" });
  Alcotest.(check string) "a bare path becomes the agent's name" "Claude Code"
    (title_shown { a with title = Some "~/src/dotfiles" });
  Alcotest.(check string) "so does the shell's default title" "Claude Code"
    (title_shown { a with title = Some (cwd ^ ": zsh") });
  Alcotest.(check string) "and the bare directory name codex leaves" "Claude Code"
    (title_shown { a with title = Some "dotfiles" });
  Alcotest.(check string) "the header's name is not repeated" "OAuth スコープの実装"
    (title_shown { a with title = Some "dotfiles · OAuth スコープの実装" });
  Alcotest.(check string) "a real title is left alone" "dotfiles を直す"
    (title_shown { a with title = Some "dotfiles を直す" })

let test_patch_shape () =
  let a = agent Model.Blocked in
  let l =
    {
      Model.child = false;
      header = None;
      header_stale = false;
      repo = None;
      group_label = "dotfiles";
      gap = false;
      wkey = "w";
      skey = "s";
    }
  in
  let patch = Model.patch ~now:t0 a (Model.view ~now:t0 ~last_active:None a) l in
  Alcotest.(check (list string)) "covers every token" Model.all_tokens (List.map fst patch);
  Alcotest.(check int) "sets exactly one row token" 1
    (List.length (List.filter (fun (k, v) -> String.starts_with ~prefix:"row_" k && v <> None) patch))

let test_logo () =
  (* 専用フォント (pkgs/herdr-agent-icons) の私用領域 *)
  Alcotest.(check string) "claude" (Glyph.utf8 0xE1A0) (Glyph.logo "claude");
  Alcotest.(check string) "opencode" (Glyph.utf8 0xE1A2) (Glyph.logo "opencode");
  Alcotest.(check string) "cursor" (Glyph.utf8 0xE1AB) (Glyph.logo "cursor");
  Alcotest.(check string) "unknown agents get the robot" Glyph.robot (Glyph.logo "something-else");
  Alcotest.(check (option string)) "and no name to stand in with" None (Glyph.display_name "something-else")

let () =
  Alcotest.run "herdr-glance"
    [
      ( "state",
        [
          Alcotest.test_case "working shows a spinner" `Quick test_working;
          Alcotest.test_case "spinner advances, no redundant writes" `Quick test_spinner_advances;
          Alcotest.test_case "idle tiers follow the last turn" `Quick test_idle_tiers;
          Alcotest.test_case "first-seen idle panes" `Quick test_first_seen_idle;
          Alcotest.test_case "blocked / done / unknown" `Quick test_states;
          Alcotest.test_case "vanished agents are cleared" `Quick test_vanished_agent;
          Alcotest.test_case "title falls back to the name" `Quick test_title_fallback;
          Alcotest.test_case "done is held until the pane is seen" `Quick test_done_held_until_seen;
          Alcotest.test_case "blocked is held until answered" `Quick test_blocked_held_until_answered;
          Alcotest.test_case "a startup prompt is not held" `Quick test_startup_prompt_not_held;
          Alcotest.test_case "a detection blip keeps working" `Quick test_grace;
          Alcotest.test_case "marks left by the last run are adopted" `Quick test_adopts_published_marks;
          Alcotest.test_case "activity survives a restart" `Quick test_activity_round_trip;
        ] );
      ( "layout",
        [
          Alcotest.test_case "one header and one gap per group" `Quick test_groups;
          Alcotest.test_case "members after the first carry neither" `Quick test_second_member_has_no_header;
          Alcotest.test_case "rows line up despite herdr's first-line indent" `Quick test_rows_line_up;
          Alcotest.test_case "worktrees hang under their repository" `Quick test_worktree_nesting;
          Alcotest.test_case "an orphan worktree gets a repo row" `Quick test_orphan_worktree;
          Alcotest.test_case "sort keys carry ids" `Quick test_sort_keys_carry_ids;
          Alcotest.test_case "an all-stale workspace fades its header" `Quick test_stale_group_header;
          Alcotest.test_case "worktree corners" `Quick test_worktree_corners;
          Alcotest.test_case "titles are tidied" `Quick test_title_cleanup;
          Alcotest.test_case "patch shape" `Quick test_patch_shape;
          Alcotest.test_case "logos" `Quick test_logo;
        ] );
    ]
