open! Core

type t =
  { id : int
  ; mutable hand_size : int
  ; mutable bluffs_completed : int
  ; mutable cards : int Card.Table.t
  }
[@@deriving sexp, fields]
