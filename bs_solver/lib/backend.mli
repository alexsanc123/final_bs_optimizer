open! Core
open! Jsonaf.Export

module World_state : sig
  type t =
    { mutable current_game : Game_state.t option
    ; mutable whose_turn : int option
    ; mutable card_on_turn : Card.t option
    ; mutable strategy : Strategy.t option
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

  val invalid_arguments
    :  num_players:int
    -> my_position:int
    -> ace_pos:int
    -> hand:Card.t list
    -> bool
end

module Opponent_move : sig
  type t = { num_cards : int } [@@deriving fields]

  val parse_opp_move : Uri.t -> t option
  val invalid_arguments : num_cards:int -> bool
end

module My_move : sig
  type t =
    { num_cards : int
    ; cards_put_down : Card.t list
    }
  [@@deriving fields]

  val parse_my_move : Uri.t -> t option

  val invalid_arguments
    :  game:Game_state.t
    -> num_cards:int
    -> cards_put_down:Card.t list
    -> bool
end

module Opp_showdown : sig
  type t =
    { caller_id : int
    ; cards_revealed : Card.t list
    }
  [@@deriving fields]

  val parse_opp_showdown : Uri.t -> t option
  val invalid_arguments : caller_id:int -> def:int -> bool
end

module My_showdown : sig
  type t = { caller_id : int } [@@deriving fields]

  val parse_my_showdown : Uri.t -> t option
  val invalid_arguments : caller_id:int -> def:int -> bool
end
