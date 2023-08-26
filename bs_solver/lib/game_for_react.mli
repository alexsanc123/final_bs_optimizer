open! Core

val find_true_pos : ace_pos:int -> pos:int -> num_players:int -> int

val game_init
  :  hand:Card.t list
  -> ace_pos:int
  -> my_pos:int
  -> num_players:int
  -> unit
  -> Game_state.t

val bluff_recomendation
  :  game:Game_state.t
  -> claim:int * Card.t * int
  -> string

val opp_moves : Game_state.t -> num_cards:int -> unit

val showdown
  :  game:Game_state.t
  -> acc:Player.t
  -> def:Player.t
  -> ?cards_revealed:Card.t list
  -> ?pot:Card.t list
  -> unit
  -> unit

val my_moves
  :  Game_state.t
  -> num_cards:int
  -> cards_put_down:Card.t list
  -> unit
