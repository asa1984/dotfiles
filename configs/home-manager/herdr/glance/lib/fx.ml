(* engine が外界に求めるもの。本番では Runtime.with_io が Eio と herdr の socket で、
   テストでは偽の時計と記録係で処理する。 *)

type patch = (string * string option) list

type _ Effect.t +=
  | Now : float Effect.t
  | Publish : string * patch -> unit Effect.t (* ペインにトークンを書く。None は消す *)
  | Last_activity : Model.agent -> float option Effect.t (* エージェント自身の記録から *)
  | Restore : (string * float) list Effect.t (* 前回の実行が残した「最後に動いた時刻」 *)
  | Persist : (string * float) list -> unit Effect.t (* それを書き戻す (間引きは受け手の仕事) *)

let now () = Effect.perform Now
let publish pane patch = Effect.perform (Publish (pane, patch))
let last_activity a = Effect.perform (Last_activity a)
let restore () = Effect.perform Restore
let persist entries = Effect.perform (Persist entries)
