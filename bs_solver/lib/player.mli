open! Core

type t =
  { id : int
  ; mutable hand_size : int
  ; mutable bluffs : int
  ; mutable cards : int Card.Table.t
  }
[@@deriving sexp, fields]

include Stringable.S with type t := t
