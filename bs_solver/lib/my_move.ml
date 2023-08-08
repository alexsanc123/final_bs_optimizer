open! Core
open! Jsonaf.Export

type query =
  { num_cards : int
  ; bluff_called : bool
  ; cards_put_down : Card.t list
  }

let parse_query uri : query option =
  let open Option.Let_syntax in
  let%bind num_cards = Uri.get_query_param uri "num_cards" in
  let%bind bluff_called = Uri.get_query_param uri "bluff_called" in
  let%bind cards_put_down = Uri.get_query_param uri "cards_put_down" in
  Some
    { num_cards = Int.of_string num_cards
    ; bluff_called = Bool.of_string bluff_called
    ; cards_put_down =
        String.fold ~init:[] cards_put_down ~f:(fun card_list_so_far card ->
          Card.of_char card :: card_list_so_far)
    }
;;
