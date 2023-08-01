open! Core

type t = (Card.t * Card.t list) list [@@deriving sexp, compare, equal]

include Stringable.S with type t := t
