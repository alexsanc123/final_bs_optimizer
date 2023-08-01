open! Core

type t = int Card.Table.t [@@deriving sexp]

include Stringable.S with type t := t

val init : unit -> t
val add_card : t -> card:Card.t -> unit
