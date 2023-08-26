open! Core
open Jsonaf.Export

module T = struct
  type t =
    { mutable current_game : Game_state.t option
    ; mutable player_count : int option
    ; mutable my_pos : int option
    ; mutable ace_pos : int option
    ; mutable whose_turn : int option
    ; mutable card_on_turn : Card.t option
    }
  [@@deriving fields, sexp, jsonaf]
end

include T
include Sexpable.To_stringable (T)

let init () : t =
  { current_game = None
  ; player_count = None
  ; my_pos = None
  ; ace_pos = None
  ; whose_turn = None
  ; card_on_turn = None
  }
;;




