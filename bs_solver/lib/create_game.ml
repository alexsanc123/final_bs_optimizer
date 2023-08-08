open! Core
open! Jsonaf.Export

type query =
  { num_players : int
  ; my_position : int
  ; ace_pos : int
  ; hand : Card.t list
  }


let parse_query uri : query option =
  let open Option.Let_syntax in
  let%bind num_players = Uri.get_query_param uri "num_players" in
  let%bind my_position = Uri.get_query_param uri "my_position" in
  let%bind ace_pos = Uri.get_query_param uri "ace_pos" in
  let%bind hand = Uri.get_query_param uri "hand" in
  Some
    { num_players = Int.of_string num_players
    ; my_position = Int.of_string my_position
    ; ace_pos = Int.of_string ace_pos
    ; hand =
        String.fold ~init:[] hand ~f:(fun card_list_so_far card ->
          Card.of_char card :: card_list_so_far)
    }
;;
