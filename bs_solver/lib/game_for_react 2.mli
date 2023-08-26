open! Core

val game_init
  :  hand:Card.t list
  -> ace_pos:int
  -> my_pos:int
  -> num_players:int
  -> unit -> Game_state.t
