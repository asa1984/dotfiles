(* engine が外界に求めるもの。本番では Runtime.with_io が Eio と herdr の socket で、
   テストでは偽の時計と記録係で処理する。 *)

type patch = (string * string option) list

type _ Effect.t +=
  | Now : float Effect.t
  | Publish : string * patch -> unit Effect.t (* ペインにトークンを書く。None は消す *)
  | Last_activity : Model.agent -> float option Effect.t (* エージェント自身の記録から *)

let now () = Effect.perform Now
let publish pane patch = Effect.perform (Publish (pane, patch))
let last_activity a = Effect.perform (Last_activity a)
