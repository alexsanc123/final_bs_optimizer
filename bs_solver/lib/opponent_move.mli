open! Core

type query =
  { num_cards : int
  ; bluff_called : bool
  }

val parse_query : Uri.t -> query option
