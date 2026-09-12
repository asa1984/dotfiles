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

let agent_of_json j =
  let str k = match member k j with `String s -> Some s | _ -> None in
  {
    Model.pane_id = member "pane_id" j |> to_string;
    agent = str "agent";
    label = (match str "display_agent" with Some _ as s -> s | None -> str "agent");
    status = Model.status_of_string (Option.value (str "agent_status") ~default:"unknown");
    title = str "terminal_title_stripped";
    session = (match member "agent_session" j with `Assoc _ as s -> (match member "value" s with `String v -> Some v | _ -> None) | _ -> None);
  }

let agents ~net ~path = call ~net ~path "agent.list" (`Assoc []) |> member "agents" |> to_list |> List.map agent_of_json

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
