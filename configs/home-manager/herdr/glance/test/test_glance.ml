open Herdr_glance

let ws ?(label = "dotfiles") ?repo_key ?repo_name ?(linked = false) id =
  (id, { Engine.label; repo_key; repo_name; linked })

let agent ?(pane = "w1:p1") ?(workspace = "w1") ?(agent = Some "claude")
    ?(title = Some "Implement OAuth scopes") status =
  { Model.pane_id = pane; workspace_id = workspace; agent; label = agent; status; title; session = Some "s1" }

(* テスト用のハンドラ: 時計は参照、書き込みは記録、会話記録は seed を返す *)
let run ?(seed : float option = None) ~(clock : float ref) f =
  let published = ref [] in
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
      Alcotest.(check bool) "indented with a zero-width space" true (String.starts_with ~prefix:(Model.indent 1) v);
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
  | Some (_, v) -> Alcotest.(check bool) "falls back to the agent name" true (String.ends_with ~suffix:"claude" v)
  | None -> Alcotest.fail "nothing shown"

(* --- グループ表示 --- *)

let test_groups () =
  let clock = ref t0 in
  let spaces = [ ws "w1"; ws ~label:"azi" "w2" ] in
  let agents = [ agent Model.Working; agent ~pane:"w2:p1" ~workspace:"w2" Model.Idle ] in
  let p = run ~clock (fun () -> Engine.sync (Engine.create ()) ~workspaces:spaces agents) in
  Alcotest.(check (option (option string))) "header on the first row of its workspace" (Some (Some "dotfiles"))
    (Some (value "w1:p1" "group" p));
  Alcotest.(check (option (option string))) "the other workspace gets its own" (Some (Some "azi"))
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
  Alcotest.(check (option string)) "worktree hangs under it" (Some (Model.indent 1 ^ "└─ feature-x"))
    (value "wc:p1" "group" p);
  Alcotest.(check bool) "same sort group" true (value "wp:p1" "wkey" p = value "wc:p1" "wkey" p);
  Alcotest.(check bool) "parent sorts first" true (value "wp:p1" "skey" p > value "wc:p1" "skey" p);
  Alcotest.(check bool) "no gap between the two" true (value "wp:p1" "gap" p = None);
  Alcotest.(check bool) "the worktree's row is indented deeper" true
    (match row "wc:p1" p with Some (_, v) -> String.starts_with ~prefix:(Model.indent 2) v | None -> false);
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
    (value "wc:p1" "group_parent" p)

let test_patch_shape () =
  let a = agent Model.Blocked in
  let l = { Model.depth = 1; header = None; repo = None; gap = false; wkey = "w"; skey = "s" } in
  let patch = Model.patch ~now:t0 a (Model.view ~now:t0 ~last_active:None a) l in
  Alcotest.(check (list string)) "covers every token" Model.all_tokens (List.map fst patch);
  Alcotest.(check int) "sets exactly one row token" 1
    (List.length (List.filter (fun (k, v) -> String.starts_with ~prefix:"row_" k && v <> None) patch))

let test_logo () =
  Alcotest.(check string) "claude" (Glyph.utf8 0xEC82) (Glyph.logo "Claude Code");
  Alcotest.(check string) "copilot" (Glyph.utf8 0xEC1E) (Glyph.logo "copilot");
  Alcotest.(check string) "others get the robot" (Glyph.utf8 0xF06A9) (Glyph.logo "opencode")

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
        ] );
      ( "layout",
        [
          Alcotest.test_case "one header and one gap per group" `Quick test_groups;
          Alcotest.test_case "members after the first carry neither" `Quick test_second_member_has_no_header;
          Alcotest.test_case "worktrees hang under their repository" `Quick test_worktree_nesting;
          Alcotest.test_case "an orphan worktree gets a repo row" `Quick test_orphan_worktree;
          Alcotest.test_case "patch shape" `Quick test_patch_shape;
          Alcotest.test_case "logos" `Quick test_logo;
        ] );
    ]
