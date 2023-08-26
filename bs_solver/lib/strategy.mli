open! Core

type t = (Card.t * Card.t list) list
[@@deriving sexp, compare, equal, jsonaf]

include Stringable.S with type t := t

val move_is_bluff : Card.t * Card.t list -> bool
