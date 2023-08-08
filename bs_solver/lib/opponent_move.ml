open! Core
open! Jsonaf.Export

type query =
  { num_cards : int
  ; bluff_called : bool
  }

let parse_query uri : query option =
  let open Option.Let_syntax in
  let%bind num_cards = Uri.get_query_param uri "num_cards" in
  let%bind bluff_called = Uri.get_query_param uri "bluff_called" in
  Some
    { num_cards = Int.of_string num_cards
    ; bluff_called = Bool.of_string bluff_called
    }
;;
