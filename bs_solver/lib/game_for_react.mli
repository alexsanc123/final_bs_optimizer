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

val pot_consequences
  :  game:Game_state.t
  -> who_lost:Player.t
  -> rest_of_pot:(int * Card.t) list
  -> players_not_in_pot:int list
  -> ?revealed_pot:Card.t list
  -> unit
  -> unit

val opp_moves : Game_state.t -> num_cards:int -> unit

val showdown
  :  game:Game_state.t
  -> acc:Player.t
  -> def:Player.t
  -> ?cards_revealed:Card.t list
  -> unit
  -> unit

val my_moves
  :  Game_state.t
  -> num_cards:int
  -> cards_put_down:Card.t list
  -> unit
