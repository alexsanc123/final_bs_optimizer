open! Core

val choose : n:int -> k:int -> int

val prob_player_has_card
  :  unknown_cards:int
  -> unknown_cards_in_hand:int
  -> desired_cards_needed:int
  -> float

val count_all_winning_hands
  :  unknown_cards:int
  -> desired_in_unknown:int
  -> hand_size:int
  -> desired_to_be_winning:int
  -> int

val prob_player_has_card
:  unknown_cards:int
-> desired_in_unknown:int
-> hand_size:int
-> desired_to_be_winning:int
-> float