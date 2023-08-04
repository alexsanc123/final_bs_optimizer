open! Core

val conflicting_claim
  :  game_state:Game_state.t
  -> claim:int * Card.t * int
  -> bool

val prob_no_lie
  :  game_state:Game_state.t
  -> claim:int * Card.t * int
  -> float

val probability_based_call
  :  game_state:Game_state.t
  -> claim:int * Card.t * int
  -> bool

val assess_calling_bluff
  :  game_state:Game_state.t
  -> claim:int * Card.t * int
  -> bool
