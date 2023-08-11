open! Core
open! Jsonaf.Export

module World_state = struct
  type t =
    { mutable current_game : Game_state.t option
    ; mutable whose_turn : int option
    ; mutable card_on_turn : Card.t option
    ; mutable strategy : Strategy.t option
    ; mutable last_move : Card.t list option
    ; mutable game_log : string list option
    }
  [@@deriving fields, sexp, jsonaf]

  let init () : t =
    { current_game = None
    ; whose_turn = None
    ; card_on_turn = None
    ; strategy = None
    ; last_move = None
    ; game_log = None
    }
  ;;

  let test_world () : t =
    { current_game = Some (Game_state.test_game_state ())
    ; whose_turn = Some 0
    ; card_on_turn = Some Card.Ace
    ; strategy = Some []
    ; last_move = None
    ; game_log = None
    }
  ;;

  let clear t =
    t.current_game <- None;
    t.whose_turn <- None;
    t.card_on_turn <- None;
    t.strategy <- None;
    t.last_move <- None;
    t.game_log <- None
  ;;
end

module Game_info = struct
  type t =
    { num_players : int
    ; my_position : int
    ; ace_pos : int
    ; hand : Card.t list
    }
  [@@deriving fields, sexp]

  let parse_game_info uri : t option =
    let open Option.Let_syntax in
    let%bind num_players = Uri.get_query_param uri "num_players" in
    let%bind my_position = Uri.get_query_param uri "my_position" in
    let%bind ace_pos = Uri.get_query_param uri "ace_of_spades" in
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

  let invalid_arguments
    ~(num_players : int)
    ~(my_position : int)
    ~(ace_pos : int)
    ~(hand : Card.t list)
    : bool
    =
    let my_hand_size =
      if my_position < 52 % num_players
      then (52 / num_players) + 1
      else 52 / num_players
    in
    List.exists
      ~f:(fun result -> result)
      [ List.length hand <> my_hand_size
      ; num_players < 3
      ; my_position < 0
      ; my_position >= num_players
      ; ace_pos < 0
      ; ace_pos >= num_players
      ]
  ;;
end

module Opponent_move = struct
  type t = { num_cards : int } [@@deriving fields]

  let parse_opp_move uri : t option =
    let open Option.Let_syntax in
    let%bind num_cards = Uri.get_query_param uri "num_cards" in
    Some { num_cards = Int.of_string num_cards }
  ;;

  let invalid_arguments ~num_cards = num_cards < 0 || num_cards > 4
end

module Bluff_check = struct
  type t = { bluff_called : bool } [@@deriving fields]

  let parse_bluff uri : t option =
    let open Option.Let_syntax in
    let%bind bluff_called = Uri.get_query_param uri "bluff_called" in
    Some { bluff_called = Bool.of_string bluff_called }
  ;;

  let invalid_arguments ~caller_id ~game =
    let def = Game_state.whos_turn game in
    caller_id = def.id
  ;;
end

module My_move = struct
  type t =
    { num_cards : int
    ; cards_put_down : Card.t list
    }
  [@@deriving fields]

  let parse_my_move uri : t option =
    let open Option.Let_syntax in
    let%bind num_cards = Uri.get_query_param uri "num_cards" in
    let%bind cards_put_down = Uri.get_query_param uri "cards_put_down" in
    Some
      { num_cards = Int.of_string num_cards
      ; cards_put_down =
          String.fold
            ~init:[]
            cards_put_down
            ~f:(fun card_list_so_far card ->
            Card.of_char card :: card_list_so_far)
      }
  ;;

  let invalid_arguments
    ~(game : Game_state.t)
    ~(num_cards : int)
    ~(cards_put_down : Card.t list)
    =
    num_cards < 0
    || num_cards > 4
    ||
    let me = Hashtbl.find_exn game.all_players game.my_id in
    List.exists cards_put_down ~f:(fun card ->
      not (My_cards.do_i_have_enough me.cards ~card ()))
  ;;
end

module Opp_showdown = struct
  type t =
    { caller_id : int
    ; cards_revealed : Card.t list
    }
  [@@deriving fields]

  let parse_opp_showdown uri : t option =
    let open Option.Let_syntax in
    let%bind caller_id = Uri.get_query_param uri "caller_id" in
    let%bind cards_revealed = Uri.get_query_param uri "cards_revealed" in
    Some
      { caller_id = Int.of_string caller_id
      ; cards_revealed =
          String.fold
            ~init:[]
            cards_revealed
            ~f:(fun card_list_so_far card ->
            Card.of_char card :: card_list_so_far)
      }
  ;;

  let invalid_arguments ~(caller_id : int) ~(def : int) = caller_id = def
end

module My_showdown_won = struct
  type t = { caller_id : int } [@@deriving fields]

  let parse_my_showdown uri : t option =
    let open Option.Let_syntax in
    let%bind caller_id = Uri.get_query_param uri "caller_id" in
    Some { caller_id = Int.of_string caller_id }
  ;;

  let invalid_arguments ~(caller_id : int) ~(def : int) = caller_id = def
end

module My_showdown_lost = struct
  type t =
    { caller_id : int
    ; pot : Card.t list
    }
  [@@deriving fields]

  let parse_my_showdown uri : t option =
    let open Option.Let_syntax in
    let%bind caller_id = Uri.get_query_param uri "caller_id" in
    let%bind pot = Uri.get_query_param uri "pot" in
    Some
      { caller_id = Int.of_string caller_id
      ; pot =
          String.fold ~init:[] pot ~f:(fun card_list_so_far card ->
            card_list_so_far @ [ Card.of_char card ])
      }
  ;;

  let invalid_arguments ~(caller_id : int) ~(def : int) = caller_id = def
end

module Reveal_pot = struct
  type t = { pot : Card.t list } [@@deriving fields]

  let parse_pot uri : t option =
    let open Option.Let_syntax in
    let%bind pot = Uri.get_query_param uri "pot" in
    Some
      { pot =
          String.fold ~init:[] pot ~f:(fun card_list_so_far card ->
            card_list_so_far @ [ Card.of_char card ])
      }
  ;;
end
