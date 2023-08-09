open! Core

val game_init
  :  hand:Card.t list
  -> ace_pos:int
  -> my_pos:int
  -> num_players:int
  -> unit
  -> Game_state.t

val opp_moves : Game_state.t -> num_cards:int -> unit

val bluff_reccomendation
  :  game:Game_state.t
  -> claim:int * Card.t * int
  -> string

val my_moves
  :  Game_state.t
  -> num_cards:int
  -> cards_put_down:Card.t list
  -> unit
