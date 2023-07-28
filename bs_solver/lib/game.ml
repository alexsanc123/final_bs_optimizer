open! Core
open! In_channel

let declare_player_count () =
  print_endline "Please specify how many players are in the round ";
  let player_count = In_channel.input_line_exn stdin in
  Int.of_string player_count
;;

let declare_my_pos () =
  print_endline
    "Please specify your seating index at the table clockwise from the 0th \
     player (the player with the Ace of Spades): ";
  let my_pos = In_channel.input_line_exn stdin in
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
  let _ =
    List.init hand_size ~f:(fun _ ->
      print_endline
        "Please specify the Rank of the  card you received\n\
        \         e.g. 2 - representing the Two";
      let card_input_string = In_channel.input_line_exn stdin in
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
          ; bluffs_completed = 0
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

let my_moves game =
  let player = Game_state.whos_turn game in
  let win_cycle =
    Util_functions.calc_win_cycle ~me:player ~game_state:game
  in
  let strategy = Turn_action.lie_with_last_card ~win_cycle ~strategy:[] in
  print_s [%message (win_cycle : (Card.t * int) list)];
  print_s [%message (strategy : Strategy.t)];
  player.hand_size <- player.hand_size - 1;
  print_s [%message "Cards left after move: " (player.hand_size : int)];
  print_endline "I made a move"
;;

let bluff_recomendation _game =
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline "No recommendation functionality integrated";
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
;;

let showdown
  ~(game : Game_state.t)
  ~(acc : Player.t)
  ~(def : Player.t)
  ~cards_put_down
  =
  ignore game;
  ignore acc;
  ignore def;
  ignore cards_put_down;
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline "Showdown";
  print_endline
    "-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  let card_on_turn = Game_state.card_on_turn game in
  let revealed_cards =
    List.init cards_put_down ~f:(fun _ ->
      print_endline
        "Please specify the Rank of the  card revealed\n\
        \         e.g. 2 - representing the Two";
      let card_input_string = In_channel.input_line_exn stdin in
      let card = Card.of_string card_input_string in
      card)
  in
  let def_not_lying =
    List.for_all revealed_cards ~f:(fun card -> Card.equal card_on_turn card)
  in
  let who_lost = match def_not_lying with true -> acc | false -> def in
  who_lost.hand_size <- who_lost.hand_size + List.length game.pot;
  let _ =
    List.iter revealed_cards ~f:(fun card ->
      My_cards.add_card who_lost.cards ~card)
  in
  match def_not_lying, acc.id = game.my_id with
  | true, true ->
    let _, rest_of_pot = List.split_n game.pot cards_put_down in
    print_s [%message (rest_of_pot : (int * Card.t) list)];
    let _ =
      List.iter (List.rev rest_of_pot) ~f:(fun (_, card) ->
        print_endline
          "Please specify the Rank of the card revealed e.g. 2 - \
           representing the Two";
        print_s [%message "Card claimed" (card : Card.t)];
        let card_input_string = In_channel.input_line_exn stdin in
        let actual_card = Card.of_string card_input_string in
        match Card.equal actual_card card with
        | true -> ()
        | false ->
          def.bluffs_completed <- def.bluffs_completed + 1;
          My_cards.add_card acc.cards ~card)
    in
    ()
  | _, _ -> ()
;;

let bluff_called ~(game : Game_state.t) ~(player : Player.t) ~cards_put_down =
  bluff_recomendation game;
  print_s
    [%message
      "Has anyone called "
        (player.id : int)
        "bluff. Type false and the round will continue"];
  let any_calls = Bool.of_string (In_channel.input_line_exn stdin) in
  match any_calls with
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
        ~cards_put_down
    else (
      let caller_id = Int.of_string caller in
      showdown
        ~game
        ~acc:(Hashtbl.find_exn game.all_players caller_id)
        ~def:player
        ~cards_put_down)
  | false -> ()
;;

let opp_moves game =
  let player = Game_state.whos_turn game in
  let card = Game_state.card_on_turn game in
  print_s
    [%message "Please specify how many cards " (player.id : int) "put down"];
  let cards_put_down = Int.of_string (In_channel.input_line_exn stdin) in
  (*must be greater than zero*)
  player.hand_size <- player.hand_size - cards_put_down;
  let added_cards = List.init cards_put_down ~f:(fun _ -> player.id, card) in
  game.pot <- added_cards @ game.pot;
  print_s [%message (game.pot : (int * Card.t) list)];
  print_endline "Opp made a move";
  bluff_called ~game ~player ~cards_put_down;
  print_s [%message "Cards left after move: " (player.hand_size : int)]
;;

let rec play_game ~(game : Game_state.t) =
  print_endline "------------------------------------------------------";
  let player = Game_state.whos_turn game in
  let card_on_turn = Game_state.card_on_turn game in
  match Game_state.game_over game with
  | true -> end_processes game
  | false ->
    print_s
      [%message
        "It is player"
          (player.id : int)
          "turn to provide"
          (card_on_turn : Card.t)];
    let _ =
      match Game_state.is_my_turn game with
      | true -> my_moves game
      | false -> opp_moves game
    in
    game.round_num <- game.round_num + 1;
    play_game ~game
;;
