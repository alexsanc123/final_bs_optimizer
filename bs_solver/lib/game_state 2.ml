open! Core
open Jsonaf.Export

module T = struct
  type t =
    { mutable round_num : int
    ; player_count : int
    ; mutable pot : (int * Card.t) list
    ; all_players : All_players.t
    ; my_id : int
    }
  [@@deriving fields, sexp, jsonaf]
end

include T
include Sexpable.To_stringable (T)

let card_on_turn t =
  (* Uses a game state's round number to calculate the card needed to to
     provide. *)
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
  (* Assess all of the player's hand size's to see if the game has been
     won. *)
  Hashtbl.fold
    t.all_players
    ~init:false
    ~f:(fun ~key:player_id ~data:(player : Player.t) game_is_over ->
    match game_is_over with
    | true -> true
    | false ->
      (match player.hand_size = 0 with
       | true ->
         let message = "player" ^ Int.to_string player_id ^ "won the game" in
         print_endline message;
         true
       | false -> false))
;;

let is_my_turn t =
  (* Returns whether or not it is our turn.*)
  if t.round_num % t.player_count = t.my_id then true else false
;;

let whos_turn t =
  (* Returns the id of the player prompted to place cards. *)
  let player_id = t.round_num % t.player_count in
  Hashtbl.find_exn t.all_players player_id
;;

let clear_cards_after_showdown t ~(exclude : int list) =
  (*clears all cards after showdown except my player and the id of the player
    id of the exclude*)
  Hashtbl.iteri t.all_players ~f:(fun ~key:player_id ~data:player ->
    if player_id = t.my_id
       || List.exists exclude ~f:(fun ex -> ex = player_id)
    then ()
    else My_cards.clear_cards ~player)
;;

let test_game_state () =
  (*we dont know the position until the person with the ace of spades has
    acted*)
  let player_count = 5 in
  let my_pos = 1 in
  let my_cards = My_cards.init () in
  List.iter
    [ Card.Ace
    ; Card.Ace
    ; Card.Two
    ; Card.Four
    ; Card.Six
    ; Card.Ten
    ; Card.Queen
    ; Card.Six
    ; Card.Seven
    ; Card.Three
    ; Card.Five
    ]
    ~f:(fun card -> My_cards.add_card my_cards ~card);
  let all_players = Int.Table.create () in
  let _ =
    List.init player_count ~f:(fun player_id ->
      let cards =
        if my_pos = player_id then my_cards else My_cards.init ()
      in
      Hashtbl.set
        all_players
        ~key:player_id
        ~data:
          { Player.id = player_id
          ; hand_size =
              (if player_id < 52 % player_count
               then (52 / player_count) + 1
               else 52 / player_count)
          ; bluffs = 0
          ; cards
          ; calls = 0
          })
  in
  let game_state =
    { round_num = 0; player_count; pot = []; all_players; my_id = my_pos }
  in
  print_s
    [%message (Hashtbl.find_exn game_state.all_players my_pos : Player.t)];
  game_state
;;
