open! Core
open! Jsonaf.Export

module World_state : sig
  type t =
    { mutable current_game : Game_state.t option
    ; mutable whose_turn : int option
    ; mutable card_on_turn : Card.t option
    ; mutable strategy : Strategy.t option
    ; mutable last_move : Card.t list option
    }
  [@@deriving fields, sexp, jsonaf]

  val init : unit -> t
  val test_world : unit -> t
  val clear : t -> unit
end

module Game_info : sig
  type t =
    { num_players : int
    ; my_position : int
    ; ace_pos : int
    ; hand : Card.t list
    }
  [@@deriving fields, sexp]

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

module Bluff_check : sig
  type t = { bluff_called : bool } [@@deriving fields]

  val parse_bluff : Uri.t -> t option
  val invalid_arguments : caller_id:int -> game:Game_state.t -> bool
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

module My_showdown_won : sig
  type t = { caller_id : int } [@@deriving fields]

  val parse_my_showdown : Uri.t -> t option
  val invalid_arguments : caller_id:int -> def:int -> bool
end

module My_showdown_lost : sig
  type t =
    { caller_id : int
    ; pot : Card.t list
    }
  [@@deriving fields]

  val parse_my_showdown : Uri.t -> t option
  val invalid_arguments : caller_id:int -> def:int -> bool
end

module Reveal_pot : sig
  type t = { pot : Card.t list } [@@deriving fields]

  val parse_pot : Uri.t -> t option
end
