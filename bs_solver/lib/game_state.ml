open! Core

type t =
  { mutable round_num : int
  ; player_count : int
  ; mutable pot : (int * Card.t) list
  ; all_players : All_players.t
  ; my_id : int
  }
[@@deriving fields, sexp]

let card_on_turn t =
  match (t.round_num + 1) % 13 with
  | 1 -> (Ace : Card.t)
  | 2 -> Two
  | 3 -> Three
  | 4 -> Four
  | 5 -> Five
  | 6 -> Six
  | 7 -> Seven
  | 8 -> Eight
  | 9 -> Nine
  | 10 -> Ten
  | 11 -> Jack
  | 12 -> Queen
  | 0 -> King
  | _ -> failwith "Invalid round!"
;;

let game_over t =
  Hashtbl.fold
    t.all_players
    ~init:false
    ~f:(fun ~key:player_id ~data:(player : Player.t) game_is_over ->
      match game_is_over with
      | true -> true
      | false ->
        (match player.hand_size = 0 with
         | true ->
           print_s [%message "player" (player_id : int) "won the game"];
           true
         | false -> false))
;;

let is_my_turn t =
  (* we should actually start round on 0*)
  if t.round_num % t.player_count = t.my_id then true else false
;;

let whos_turn t =
  let player_id = t.round_num % t.player_count in
  (* print_s [%message "Its player" (player_id : int) "turn"]; *)
  Hashtbl.find_exn t.all_players player_id
;;
