open! Core

val lie_with_last_card
  :  win_cycle:(Card.t * int) list
  -> strategy:Strategy.t
  -> Strategy.t

val count_bluffs : strategy:Strategy.t -> int

val evaluate_strategies
  :  win_cycle:(Card.t * int) list
  -> game_state:Game_state.t
  -> Strategy.t

val _act_on_strategy
  :  strategy:Strategy.t
  -> card_to_provide:Card.t
  -> Card.t list
