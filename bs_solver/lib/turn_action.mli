open! Util_functions

val conflicting_claim : game_state:Game_state.t -> claim:Card.t * int -> bool

val check_opponent_win
  :  game_state:Game_state.t
  -> claim:Card.t * int
  -> bool

val useful_call : game_state:Game_state.t -> claim:Card.t * int -> bool
val card_probability : game_state:Game_state.t -> claim:Card.t * int -> bool

val assess_calling_bluff
  :  game_state:Game_state.t
  -> claim:Card.t * int
  -> bool

val lie_with_last_card
  :  win_cycle:(Card.t * int) list
  -> strategy:Strategy.t
  -> Strategy.t

val necessary_bluff : game_state:Game_state.t -> (Card.t * int) list

val unecessary_bluff
  :  game_state:Game_state.t
  -> card:Card.t
  -> (Card.t * int) list

val my_turn_action
  :  game_state:Game_state.t
  -> card:Card.t
  -> (Card.t * int) list

val lie_with_last_card
  :  win_cycle:(Card.t * int) list
  -> strategy:Strategy.t
  -> Strategy.t
