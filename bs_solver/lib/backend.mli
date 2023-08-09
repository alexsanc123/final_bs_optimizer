open! Core
open! Jsonaf.Export

module World_state : sig
  type t =
    { mutable current_game : Game_state.t option
    ; mutable player_count : int option
    ; mutable my_pos : int option
    ; mutable ace_pos : int option
    ; mutable whose_turn : int option
    ; mutable card_on_turn : Card.t option
    }
  [@@deriving fields, sexp, jsonaf]

  val init : unit -> t
end

module Game_info : sig
  type t =
    { num_players : int
    ; my_position : int
    ; ace_pos : int
    ; hand : Card.t list
    }
  [@@deriving fields]

  val parse_game_info : Uri.t -> t option
end

module Opponent_move : sig
  type t =
    { num_cards : int
    ; bluff_called : bool
    }
  [@@deriving fields]

  val parse_opp_move : Uri.t -> t option
end

module My_move : sig
  type t =
    { num_cards : int
    ; bluff_called : bool
    ; cards_put_down : Card.t list
    }
  [@@deriving fields]

  val parse_my_move : Uri.t -> t option
end
