open! Core

type query =
  { num_players : int
  ; my_position : int
  ; ace_pos : int
  ; hand : Card.t list
  }

val parse_query : Uri.t -> query option
