open! Core

type query =
  { num_cards : int
  ; bluff_called : bool
  ; cards_put_down : Card.t list
  }

val parse_query : Uri.t -> query option