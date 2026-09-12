(* herdr の socket API。改行区切りの JSON で、サーバーは 1 接続につき 1 要求にだけ答えて切る。
   購読用の接続には、最初の要求の後は何も書いてはいけない (書くと切断される)。 *)

open Yojson.Safe.Util

exception Rpc_error of string

let source = "herdr-glance"

let socket_path () =
  match Sys.getenv_opt "HERDR_SOCKET_PATH" with
  | Some p when p <> "" -> p
  | _ ->
      let config =
        match Sys.getenv_opt "XDG_CONFIG_HOME" with
        | Some d when d <> "" -> d
        | _ -> Filename.concat (Sessions.home ()) ".config"
      in
      Filename.concat (Filename.concat config "herdr") "herdr.sock"

let request_line id meth params =
  Yojson.Safe.to_string (`Assoc [ ("id", `String id); ("method", `String meth); ("params", params) ]) ^ "\n"

let max_line = 16 * 1024 * 1024

let result_of_line line =
  let j = Yojson.Safe.from_string line in
  match member "error" j with `Null -> member "result" j | e -> raise (Rpc_error (Yojson.Safe.to_string e))

let call ~net ~path meth params =
  Eio.Switch.run @@ fun sw ->
  let flow = Eio.Net.connect ~sw net (`Unix path) in
  Eio.Flow.copy_string (request_line "glance" meth params) flow;
  result_of_line (Eio.Buf_read.line (Eio.Buf_read.of_flow flow ~max_size:max_line))

let str_of j k = match member k j with `String s -> Some s | _ -> None

let agent_of_json j =
  let str k = match member k j with `String s -> Some s | _ -> None in
  {
    Model.pane_id = member "pane_id" j |> to_string;
    workspace_id = member "workspace_id" j |> to_string;
    agent = str "agent";
    label = (match str "display_agent" with Some _ as s -> s | None -> str "agent");
    status = Model.status_of_string (Option.value (str "agent_status") ~default:"unknown");
    title = str "terminal_title_stripped";
    session = (match member "agent_session" j with `Assoc _ as s -> (match member "value" s with `String v -> Some v | _ -> None) | _ -> None);
  }

let agents ~net ~path = call ~net ~path "agent.list" (`Assoc []) |> member "agents" |> to_list |> List.map agent_of_json

let workspace_of_json j =
  let str k = match member k j with `String s -> Some s | _ -> None in
  let wt = member "worktree" j in
  ( member "workspace_id" j |> to_string,
    {
      Engine.label = Option.value (str "label") ~default:(member "workspace_id" j |> to_string);
      repo_key = (match wt with `Assoc _ -> str_of wt "repo_key" | _ -> None);
      repo_name = (match wt with `Assoc _ -> str_of wt "repo_name" | _ -> None);
      linked = (match wt with `Assoc _ -> (match member "is_linked_worktree" wt with `Bool b -> b | _ -> false) | _ -> false);
    } )

let workspaces ~net ~path =
  call ~net ~path "workspace.list" (`Assoc []) |> member "workspaces" |> to_list |> List.map workspace_of_json

(* サイドバーの並び順を、こちらが書いたキーで決める。サーバーが終わると消えるので接続ごとに入れ直す *)
let set_view ~net ~path =
  let by token order = `Assoc [ ("field", `Assoc [ ("token", `String token) ]); ("order", `String order) ] in
  ignore
    (call ~net ~path "agent.view.set"
       (`Assoc
         [ ("source", `String source); ("label", `String "glance");
           ("sort", `List [ by "wkey" "desc"; by "skey" "desc" ]) ]))

(* 前回の実行で書いたトークンが残っているペイン (エージェントが既にいないものの掃除用) *)
let panes_with_our_tokens ~net ~path =
  call ~net ~path "pane.list" (`Assoc [])
  |> member "panes" |> to_list
  |> List.filter_map (fun p ->
         match member "tokens" p with
         | `Assoc kv when List.exists (fun (k, _) -> List.mem k Model.all_tokens) kv -> Some (member "pane_id" p |> to_string)
         | _ -> None)

let report ~net ~path pane_id (patch : Fx.patch) =
  let tokens = `Assoc (List.map (fun (k, v) -> (k, match v with Some s -> `String s | None -> `Null)) patch) in
  ignore
    (call ~net ~path "pane.report_metadata"
       (`Assoc [ ("pane_id", `String pane_id); ("source", `String source); ("tokens", tokens) ]))

(* pane_id なしで購読できる種類だけを使う。pane.agent_status_changed はペインごとにしか
   購読できないので、状態の変化は agent.list の定期確認で拾う (main.ml)。
   pane.updated は自分の書き込みが跳ね返ってくるうえサーバーの応答が遅くなるので入れない。 *)
let kinds = [ "pane.agent_detected"; "pane.created"; "pane.closed"; "pane.exited"; "pane.focused" ]

(* イベントの中身は使わず、何か変わった合図としてだけ扱う (再送や間引きがあっても困らない)。
   接続が切れると End_of_file か Eio.Io で抜ける。 *)
let subscribe ~net ~path ~on_event =
  Eio.Switch.run @@ fun sw ->
  let flow = Eio.Net.connect ~sw net (`Unix path) in
  let subs = `List (List.map (fun k -> `Assoc [ ("type", `String k) ]) kinds) in
  Eio.Flow.copy_string (request_line "glance-sub" "events.subscribe" (`Assoc [ ("subscriptions", subs) ])) flow;
  let r = Eio.Buf_read.of_flow flow ~max_size:max_line in
  ignore (result_of_line (Eio.Buf_read.line r));
  let rec loop () =
    ignore (Eio.Buf_read.line r);
    on_event ();
    loop ()
  in
  loop ()
