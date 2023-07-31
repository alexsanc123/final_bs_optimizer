open! Core

let card_on_turn num =
  match num % 13 with
  | 0 -> (Ace : Card.t)
  | 1 -> Two
  | 2 -> Three
  | 3 -> Four
  | 4 -> Five
  | 5 -> Six
  | 6 -> Seven
  | 7 -> Eight
  | 8 -> Nine
  | 9 -> Ten
  | 10 -> Jack
  | 11 -> Queen
  | 12 -> King
  | _ -> failwith "Invalid round!"
;;

let chop_win_seq sequence : (Card.t * int) list =
  (*Given a win sequence, if we dont have cards at the end of our win
    sequence, just eliminate that part.*)
  let seq, _ =
    List.fold
      sequence
      ~init:([], [])
      ~f:(fun (built, pending) (rank, count) ->
      match count with
      | 0 -> built, pending @ [ rank, count ]
      | _ -> built @ pending @ [ rank, count ], [])
  in
  seq
;;

let my_next_turn ~(me : Player.t) ~(game_state : Game_state.t) =
  ((game_state.round_num / game_state.player_count * game_state.player_count)
   + me.id)
  % game_state.player_count
;;

let calc_win_cycle ~(me : Player.t) ~(game_state : Game_state.t) =
  (* id should start at 0 if round starts at 1 *)
  (*Calculates the list of the cards we need to provide according to the
    cards we have in our hand.*)
  let current_turn = my_next_turn ~me ~game_state in
  let full_cycle =
    List.init 13 ~f:(fun cycle_count ->
      let rank =
        card_on_turn (current_turn + (game_state.player_count * cycle_count))
      in
      rank, Hashtbl.find_exn me.cards rank)
  in
  chop_win_seq full_cycle
;;

let cards_to_provide ~(player : Player.t) ~(game_state : Game_state.t) =
  (* Functionaly to calculate a list of the cards one needs to provide
     throughout the next 13 rounds of the game. id should start at 0 if round
     starts at 1 *)
  let current_turn = game_state.round_num + player.id in
  List.init 13 ~f:(fun cycle_count ->
    card_on_turn (current_turn + (game_state.player_count * cycle_count)))
;;

(******************************************************************************************)

let%expect_test "Test 1 for calculating cards to provide." =
  let player =
    { Player.id = 3
    ; hand_size = 10
    ; bluffs_completed = 2
    ; cards = Card.Table.create ()
    }
  in
  let game_state =
    { Game_state.round_num = 0
    ; player_count = 5
    ; pot = []
    ; all_players = Int.Table.create ()
    ; my_id = 3
    }
  in
  cards_to_provide ~player ~game_state
  |> List.iter ~f:(fun card -> print_endline (Card.to_string card));
  [%expect
    {|
  Four
  Nine
  Ace
  Six
  Jack
  Three
  Eight
  King
  Five
  Ten
  Two
  Seven
  Queen|}]
;;

let%expect_test "Test 2 for calculating cards to provide." =
  let player =
    { Player.id = 2
    ; hand_size = 15
    ; bluffs_completed = 1
    ; cards = Card.Table.create ()
    }
  in
  let game_state =
    { Game_state.round_num = 0
    ; player_count = 3
    ; pot = []
    ; all_players = Int.Table.create ()
    ; my_id = 2
    }
  in
  cards_to_provide ~player ~game_state
  |> List.iter ~f:(fun card -> print_endline (Card.to_string card));
  [%expect
    {|
  Three
  Six
  Nine
  Queen
  Two
  Five
  Eight
  Jack
  Ace
  Four
  Seven
  Ten
  King|}]
;;

let%expect_test "Test 3 for calculating cards to provide." =
  let player =
    { Player.id = 5
    ; hand_size = 12
    ; bluffs_completed = 0
    ; cards = Card.Table.create ()
    }
  in
  let game_state =
    { Game_state.round_num = 0
    ; player_count = 6
    ; pot = []
    ; all_players = Int.Table.create ()
    ; my_id = 5
    }
  in
  cards_to_provide ~player ~game_state
  |> List.iter ~f:(fun card -> print_endline (Card.to_string card));
  [%expect
    {|
  Six
  Queen
  Five
  Jack
  Four
  Ten
  Three
  Nine
  Two
  Eight
  Ace
  Seven
  King|}]
;;
