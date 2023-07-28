open! Core

val chop_win_seq : (Card.t * int) list -> (Card.t * int) list

val calc_win_cycle
  :  me:Player.t
  -> game_state:Game_state.t
  -> (Card.t * int) list

val cards_to_provide
  :  player:Player.t
  -> game_state:Game_state.t
  -> Card.t list
