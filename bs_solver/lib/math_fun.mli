open! Core

val choose : n:int -> k:int -> Bignum.t

val count_all_winning_hands
  :  unknown_cards:int
  -> desired_in_unknown:int
  -> hand_size:int
  -> desired_to_be_winning:int
  -> Bignum.t

val prob_player_has_card
  :  unknown_cards:int
  -> desired_in_unknown:int
  -> hand_size:int
  -> desired_to_be_winning:int
  -> float
