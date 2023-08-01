open! Core

type t = int Card.Table.t [@@deriving sexp]

include Stringable.S with type t := t

val init : unit -> t
val do_i_have_enough : t -> card:Card.t -> ?how_much:int -> unit-> bool
val add_card : t -> card:Card.t -> unit
val rm_card : t -> card:Card.t -> ?how_much:int -> unit -> unit

