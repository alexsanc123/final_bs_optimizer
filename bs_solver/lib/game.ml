open! Core
open! In_channel

let declare_player_count () =
  let prompt = "Please specify how many players are in the round " in
  let player_count = Stdinout.loop_num_input ~prompt in
  (* print_endline "Please specify how many players are in the round "; let
     player_count = In_channel.input_line_exn stdin in *)
  Int.of_string player_count
;;

let declare_my_pos () =
  let prompt =
    "Please specify your seating index at the table clockwise from the 0th \
     player (the player with the Ace of Spades): "
  in
  let my_pos = Stdinout.loop_num_input ~prompt in
  Int.of_string my_pos
;;

let declare_my_cards ~my_pos ~player_count =
  let hand_size =
    if my_pos < 52 % player_count
    then (52 / player_count) + 1
    else 52 / player_count
  in
  (* print_s[%message (hand_size:int)]; *)
  let my_cards = My_cards.init () in
  let prompt =
    "Please specify the Rank of the  card you received\n\
    \         e.g. 2 - representing the Two"
  in
  let _ =
    List.init hand_size ~f:(fun _ ->
      let card_input_string = Stdinout.loop_card_input ~prompt in
      let card = Card.of_string card_input_string in
      My_cards.add_card my_cards ~card)
  in
  my_cards
;;

let game_init () =
  (*we dont know the position until the person with the ace of spades has
    acted*)
  let player_count = declare_player_count () in
  let my_pos = declare_my_pos () in
  let my_cards = declare_my_cards ~my_pos ~player_count in
  let all_players = Int.Table.create () in
  let _ =
    List.init player_count ~f:(fun player_id ->
      assert (player_count > 0);
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
          })
  in
  let game_state =
    { Game_state.round_num = 0
    ; player_count
    ; pot = []
    ; all_players
    ; my_id = my_pos
    }
  in
  (* print_s [%message (game_state : Game_state.t)]; *)
  game_state
;;

let end_processes game =
  ignore game;
  print_endline "Wow game is over"
;;

let bluff_recomendation ~game ~claim =
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline "Recommendation";
  let should_i_call =
    Call_actions.assess_calling_bluff ~game_state:game ~claim
  in
  print_s [%message (should_i_call : bool)];
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
;;

let showdown
  ~(game : Game_state.t)
  ~(acc : Player.t)
  ~(def : Player.t)
  ~num_cards_claimed
  =
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline "Showdown";
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  let prompt =
    "Please specify the Rank of the card revealed e.g. 2 - representing the \
     Two"
  in
  let card_on_turn = Game_state.card_on_turn game in
  let _, rest_of_pot = List.split_n game.pot num_cards_claimed in
  print_s [%message (rest_of_pot : (int * Card.t) list)];
  let revealed_cards =
    List.init num_cards_claimed ~f:(fun _ ->
      let card_input_string = Stdinout.loop_card_input ~prompt in
      let card = Card.of_string card_input_string in
      card)
  in
  let def_not_lying =
    List.for_all revealed_cards ~f:(fun card -> Card.equal card_on_turn card)
  in
  let who_lost = match def_not_lying with true -> acc | false -> def in
  who_lost.hand_size <- who_lost.hand_size + num_cards_claimed;
  if who_lost.id = def.id then def.bluffs <- def.bluffs + 1 else ();
  List.iter revealed_cards ~f:(fun card ->
    My_cards.add_card who_lost.cards ~card);
  who_lost.hand_size <- who_lost.hand_size + List.length rest_of_pot;
  if who_lost.id = game.my_id
  then
    List.iter (List.rev rest_of_pot) ~f:(fun (pot_id, card) ->
      print_s [%message "Card claimed" (card : Card.t)];
      let card_input_string = Stdinout.loop_card_input ~prompt in
      let actual_card = Card.of_string card_input_string in
      match Card.equal actual_card card with
      | true -> My_cards.add_card who_lost.cards ~card
      | false ->
        let pot_player = Hashtbl.find_exn game.all_players pot_id in
        pot_player.bluffs <- pot_player.bluffs + 1;
        My_cards.add_card who_lost.cards ~card)
  else
    List.iter rest_of_pot ~f:(fun (pot_id, card) ->
      if pot_id = game.my_id then My_cards.add_card who_lost.cards ~card)
;;

let bluff_called
  ~(game : Game_state.t)
  ~(player : Player.t)
  ~num_cards_claimed
  =
  bluff_recomendation
    ~game
    ~claim:(player.id, Game_state.card_on_turn game, num_cards_claimed);
  print_s
    [%message
      "Has anyone called "
        (player.id : int)
        "bluff. Type false and the round will continue"];
  let any_calls = Bool.of_string (In_channel.input_line_exn stdin) in
  match any_calls with (*bluff called when you turn and opp might call you. Dont call your own bluff*)
  | true ->
    print_s
      [%message
        "Has anyone called "
          (player.id : int)
          "bluff. Type 'me' if you would like to call"];
    let caller = In_channel.input_line_exn stdin in
    if String.equal (String.lowercase caller) "me"
    then
      showdown
        ~game
        ~acc:(Hashtbl.find_exn game.all_players game.my_id)
        ~def:player
        ~num_cards_claimed
    else (
      let caller_id = Int.of_string caller in
      showdown
        ~game
        ~acc:(Hashtbl.find_exn game.all_players caller_id)
        ~def:player
        ~num_cards_claimed)
  | false -> ()
;;

let my_moves game =
  let player = Game_state.whos_turn game in
  let win_cycle =
    Util_functions.calc_win_cycle ~me:player ~game_state:game
  in
  let strategy = Turn_action.lie_with_last_card ~win_cycle ~strategy:[] in
  print_s [%message (win_cycle : (Card.t * int) list)];
  print_s [%message (strategy : Strategy.t)];
  let count_prompt =
    "Please specify the num of cards you would like to put down on your turn"
  in
  let card_prompt = "please specify the card you would like to put down" in
  let count = Int.of_string (Stdinout.loop_num_input ~prompt:count_prompt) in
  let cards_put_down =
    List.init count ~f:(fun _ ->
      ( player.id
      , Card.of_string (Stdinout.loop_card_i_put_input ~prompt:card_prompt ~game_state:game) ))
  in
  game.pot <- cards_put_down @ game.pot;
  player.hand_size <- player.hand_size - count;
  bluff_called ~game ~player ~num_cards_claimed:count;
  print_endline ("Cards left after move: " ^ Int.to_string player.hand_size);
  print_endline "I made a move"
;;

let opp_moves game =
  let player = Game_state.whos_turn game in
  let card = Game_state.card_on_turn game in
  let prompt =
    "Please specify how many cards Player "
    ^ Int.to_string player.id
    ^ " put down"
  in
  let num_cards_claimed = Int.of_string (Stdinout.loop_num_input ~prompt) in
  player.hand_size <- player.hand_size - num_cards_claimed;
  let added_cards =
    List.init num_cards_claimed ~f:(fun _ -> player.id, card)
  in
  game.pot <- added_cards @ game.pot;
  print_s [%message (game.pot : (int * Card.t) list)];
  print_endline "Opp made a move";
  bluff_called ~game ~player ~num_cards_claimed;
  print_s [%message "Cards left after move: " (player.hand_size : int)]
;;

let rec play_game ~(game : Game_state.t) =
  print_endline "------------------------------------------------------";
  let player = Game_state.whos_turn game in
  let card_on_turn = Game_state.card_on_turn game in
  match Game_state.game_over game with
  | true -> end_processes game
  | false ->
    let prompt =
      "It is Player "
      ^ Int.to_string player.id
      ^ " turn to provide the card: "
      ^ Card.to_string (card_on_turn : Card.t)
    in
    print_endline prompt;
    let _ =
      match Game_state.is_my_turn game with
      | true -> my_moves game
      | false -> opp_moves game
    in
    game.round_num <- game.round_num + 1;
    play_game ~game
;;
