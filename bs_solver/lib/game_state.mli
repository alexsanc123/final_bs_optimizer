open! Core

type t =
  { mutable round_num : int
  ; player_count : int
  ; mutable pot : (int * Card.t) list (* accumulated cards*)
  ; all_players : All_players.t
  ; my_id : int
  }
[@@deriving fields, sexp]

val card_on_turn : t -> Card.t
val game_over : t -> bool
val is_my_turn : t -> bool
val whos_turn : t -> Player.t
