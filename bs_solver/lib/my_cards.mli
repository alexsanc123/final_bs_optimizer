open! Core

type t = (int * int) Card.Table.t [@@deriving sexp]

include Stringable.S with type t := t

val init : unit -> t
val do_i_have_enough : t -> card:Card.t -> ?how_much:int -> unit -> bool
val add_card : t -> card:Card.t -> unit
val rm_my_card : t -> card:Card.t -> ?how_much:int -> unit -> unit
val clear_cards : player:Player.t -> unit
val restore_cards : player:Player.t -> unit
val update_after_move : player:Player.t -> move:Card.t * int -> unit
val to_string : t -> string
