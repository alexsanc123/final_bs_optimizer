open! Core

type t =
{ mutable current_game : Game_state.t option
; mutable player_count : int option
; mutable my_pos : int option
; mutable ace_pos : int option
; mutable whose_turn : int option
; mutable card_on_turn : Card.t option
}
[@@deriving fields, sexp, jsonaf]

include Stringable.S with type t := t

val init : unit -> t

