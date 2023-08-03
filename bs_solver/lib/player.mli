open! Core

type t =
  { id : int
  ; mutable hand_size : int
  ; mutable bluffs : int
  ; mutable cards : (int * int) Card.Table.t
  ; mutable calls : int
  }
[@@deriving sexp, fields]

include Stringable.S with type t := t
