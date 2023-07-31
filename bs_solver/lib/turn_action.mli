open! Core

val lie_with_last_card
  :  win_cycle:(Card.t * int) list
  -> strategy:Strategy.t
  -> Strategy.t

val quantify_bluffs : strategy:Strategy.t -> int
val _evaluate_strategies : win_cycle:(Card.t * int) list -> Strategy.t

val _act_on_strategy
  :  strategy:Strategy.t
  -> card_to_provide:Card.t
  -> Card.t list
