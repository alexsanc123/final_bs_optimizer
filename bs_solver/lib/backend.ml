open! Core
open! Jsonaf.Export

module World_state = struct
  type t =
    { mutable current_game : Game_state.t option
    ; mutable player_count : int option
    ; mutable my_pos : int option
    ; mutable ace_pos : int option
    ; mutable whose_turn : int option
    ; mutable card_on_turn : Card.t option
    }
  [@@deriving fields, sexp, jsonaf]

  let init () : t =
    { current_game = None
    ; player_count = None
    ; my_pos = None
    ; ace_pos = None
    ; whose_turn = None
    ; card_on_turn = None
    }
  ;;
end

module Game_info = struct
  type t =
    { num_players : int
    ; my_position : int
    ; ace_pos : int
    ; hand : Card.t list
    }
  [@@deriving fields]

  let parse_game_info uri : t option =
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
end

module Opponent_move = struct
  type t =
    { num_cards : int
    ; bluff_called : bool
    }
  [@@deriving fields]

  let parse_opp_move uri : t option =
    let open Option.Let_syntax in
    let%bind num_cards = Uri.get_query_param uri "num_cards" in
    let%bind bluff_called = Uri.get_query_param uri "bluff_called" in
    Some
      { num_cards = Int.of_string num_cards
      ; bluff_called = Bool.of_string bluff_called
      }
  ;;
end

module My_move = struct
  type t =
    { num_cards : int
    ; bluff_called : bool
    ; cards_put_down : Card.t list
    }
  [@@deriving fields]

  let parse_my_move uri : t option =
    let open Option.Let_syntax in
    let%bind num_cards = Uri.get_query_param uri "num_cards" in
    let%bind bluff_called = Uri.get_query_param uri "bluff_called" in
    let%bind cards_put_down = Uri.get_query_param uri "cards_put_down" in
    Some
      { num_cards = Int.of_string num_cards
      ; bluff_called = Bool.of_string bluff_called
      ; cards_put_down =
          String.fold
            ~init:[]
            cards_put_down
            ~f:(fun card_list_so_far card ->
            Card.of_char card :: card_list_so_far)
      }
  ;;
end
