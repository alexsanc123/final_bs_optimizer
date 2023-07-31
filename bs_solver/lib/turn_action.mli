open! Core

val lie_with_last_card
  :  win_cycle:(Card.t * int) list
  -> strategy:Strategy.t
  -> Strategy.t
