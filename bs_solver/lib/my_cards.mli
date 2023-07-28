open! Core

type t = int Card.Table.t [@@deriving sexp]

val init : unit -> t
val add_card : t -> card:Card.t -> unit
