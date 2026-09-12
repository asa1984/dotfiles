open Herdr_glance

let agent ?(agent = Some "claude") ?(title = Some "Implement OAuth scopes") status =
  { Model.pane_id = "w1:p1"; agent; label = agent; status; title; session = Some "s1" }

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

(* 最後に書いた内容のうち、値の入っているトークン *)
let shown published =
  match List.rev published with
  | (_, patch) :: _ -> (
      match List.filter_map (fun (k, v) -> Option.map (fun v -> (k, v)) v) patch with
      | [ x ] -> Some x
      | _ -> None)
  | [] -> None

let token p = Option.map fst (shown p)
let check_token msg expected p = Alcotest.(check (option string)) msg expected (token p)
let t0 = 1_800_000_000.

let test_working () =
  let e = Engine.create () and clock = ref t0 in
  let p = run ~clock (fun () -> Engine.sync e [ agent Model.Working ]) in
  check_token "token" (Some "row_working") p;
  (match shown p with
  | Some (_, v) ->
      Alcotest.(check bool) "starts with a spinner frame" true
        (Array.exists (fun g -> String.starts_with ~prefix:g v) Glyph.spinner);
      Alcotest.(check bool) "carries the title" true (Glyph.contains v "Implement OAuth scopes")
  | None -> Alcotest.fail "nothing shown");
  Alcotest.(check bool) "any_working" true (Engine.any_working e)

let test_spinner_advances () =
  let e = Engine.create () and clock = ref t0 in
  let p1 = run ~clock (fun () -> Engine.sync e [ agent Model.Working ]) in
  let same = run ~clock (fun () -> Engine.sync e [ agent Model.Working ]) in
  Alcotest.(check int) "no rewrite when nothing changed" 0 (List.length same);
  clock := t0 +. (Model.spinner_period *. 1.5);
  let p2 = run ~clock (fun () -> Engine.sync e [ agent Model.Working ]) in
  Alcotest.(check bool) "next frame" true (shown p1 <> shown p2)

let test_idle_tiers () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e [ agent Model.Working ]));
  clock := t0 +. 60.;
  check_token "fresh right after a turn" (Some "row_idle_fresh") (run ~clock (fun () -> Engine.sync e [ agent Model.Idle ]));
  Alcotest.(check bool) "no longer working" false (Engine.any_working e);
  clock := t0 +. 60. +. (20. *. 60.);
  check_token "plain after 20 minutes" (Some "row_idle") (run ~clock (fun () -> Engine.sync e [ agent Model.Idle ]));
  clock := t0 +. 60. +. (121. *. 60.);
  check_token "stale after two hours" (Some "row_idle_stale") (run ~clock (fun () -> Engine.sync e [ agent Model.Idle ]))

let test_first_seen_idle () =
  let clock = ref t0 in
  check_token "no evidence is neutral" (Some "row_idle")
    (run ~clock (fun () -> Engine.sync (Engine.create ()) [ agent Model.Idle ]));
  check_token "seeded from the transcript" (Some "row_idle_stale")
    (run ~seed:(Some (t0 -. (3. *. 3600.))) ~clock (fun () -> Engine.sync (Engine.create ()) [ agent Model.Idle ]))

let test_states () =
  let clock = ref t0 in
  List.iter
    (fun (status, expected) ->
      check_token expected (Some expected) (run ~clock (fun () -> Engine.sync (Engine.create ()) [ agent status ])))
    [ (Model.Blocked, "row_blocked"); (Model.Done, "row_done"); (Model.Unknown, "row_unknown") ]

let test_vanished_agent () =
  let e = Engine.create () and clock = ref t0 in
  ignore (run ~clock (fun () -> Engine.sync e [ agent Model.Idle ]));
  let p = run ~clock (fun () -> Engine.sync e []) in
  Alcotest.(check (list (pair string (list (pair string (option string))))))
    "every token cleared" [ ("w1:p1", Engine.clear_patch) ] p;
  let again = run ~clock (fun () -> Engine.sync e []) in
  Alcotest.(check int) "forgotten" 0 (List.length again)

let test_title_fallback () =
  let clock = ref t0 in
  match shown (run ~clock (fun () -> Engine.sync (Engine.create ()) [ agent ~title:(Some "  ") Model.Idle ])) with
  | Some (_, v) -> Alcotest.(check bool) "falls back to the agent name" true (String.ends_with ~suffix:"claude" v)
  | None -> Alcotest.fail "nothing shown"

let test_patch_shape () =
  let a = agent Model.Blocked in
  let patch = Model.patch ~now:t0 a (Model.view ~now:t0 ~last_active:None a) in
  Alcotest.(check (list string)) "covers every token" Model.all_tokens (List.map fst patch);
  Alcotest.(check int) "sets exactly one" 1 (List.length (List.filter (fun (_, v) -> v <> None) patch))

let test_logo () =
  Alcotest.(check string) "claude" (Glyph.utf8 0xEC82) (Glyph.logo "Claude Code");
  Alcotest.(check string) "copilot" (Glyph.utf8 0xEC1E) (Glyph.logo "copilot");
  Alcotest.(check string) "others get the robot" (Glyph.utf8 0xF06A9) (Glyph.logo "opencode")

let () =
  Alcotest.run "herdr-glance"
    [
      ( "engine",
        [
          Alcotest.test_case "working shows a spinner" `Quick test_working;
          Alcotest.test_case "spinner advances, no redundant writes" `Quick test_spinner_advances;
          Alcotest.test_case "idle tiers follow the last turn" `Quick test_idle_tiers;
          Alcotest.test_case "first-seen idle panes" `Quick test_first_seen_idle;
          Alcotest.test_case "blocked / done / unknown" `Quick test_states;
          Alcotest.test_case "vanished agents are cleared" `Quick test_vanished_agent;
          Alcotest.test_case "title falls back to the name" `Quick test_title_fallback;
        ] );
      ( "model",
        [
          Alcotest.test_case "patch sets one token" `Quick test_patch_shape;
          Alcotest.test_case "logos" `Quick test_logo;
        ] );
    ]
