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

let my_moves game =
  let player = Game_state.whos_turn game in
  let win_cycle =
    Util_functions.calc_win_cycle ~me:player ~game_state:game
  in
  let strategy = Turn_action.lie_with_last_card ~win_cycle ~strategy:[] in
  let win_cycle_as_string =
    List.fold win_cycle ~init:"" ~f:(fun string_so_far (rank, how_many) ->
      string_so_far
      ^ Card.to_string rank
      ^ "-"
      ^ Int.to_string how_many
      ^ ", ")
  in
  print_endline
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline
    ("\n The rest of your win cycle contains: " ^ win_cycle_as_string);
  let strategy_as_string =
    List.fold
      strategy
      ~init:""
      ~f:(fun string_so_far (card_to_provide, cards_to_use) ->
      string_so_far
      ^ Card.to_string card_to_provide
      ^ "-"
      ^ "("
      ^ List.fold cards_to_use ~init:"" ~f:(fun cards_so_far rank ->
          cards_so_far ^ Card.to_string rank ^ ", ")
      ^ "), ")
  in
  print_endline
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline
    ("\n The strategy for the remainder of the game: " ^ strategy_as_string);
  player.hand_size <- player.hand_size - 1;
  print_endline ("Cards left after move: " ^ Int.to_string player.hand_size);
  print_endline "I made a move."
;;

let bluff_recomendation ~game ~claim =
  print_endline
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  let should_i_call =
    Call_actions.assess_calling_bluff ~game_state:game ~claim
  in
  if should_i_call
  then print_endline "Reccomendation: Call your opponent's bluff."
  else print_endline "Reccomendation: Do not call your opponent's bluff.";
  print_endline
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
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
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline "Showdown";
  print_endline
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
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
  if who_lost.id = def.id then def.bluffs <- def.bluffs + 1 else ();
  let _ =
    List.iter revealed_cards ~f:(fun card ->
      My_cards.add_card who_lost.cards ~card)
  in
  match def_not_lying, acc.id = game.my_id with
  | true, true ->
    let _, rest_of_pot = List.split_n game.pot cards_put_down in
    let pot_as_string =
      List.fold game.pot ~init:"" ~f:(fun string_so_far (who_put, rank) ->
        string_so_far
        ^ Card.to_string rank
        ^ " - Player "
        ^ Int.to_string who_put
        ^ ", ")
    in
    print_endline
      "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
    print_endline ("\n The rest of the pot contains: " ^ pot_as_string);
    let _ =
      List.iter (List.rev rest_of_pot) ~f:(fun (pot_id, card) ->
        print_endline
          "Please specify the Rank of the card revealed e.g. 2 - \
           representing the Two";
        print_endline ("Card claimed: " ^ Card.to_string card);
        let card_input_string = In_channel.input_line_exn stdin in
        let actual_card = Card.of_string card_input_string in
        match Card.equal actual_card card with
        | true -> ()
        | false ->
          let pot_player = Hashtbl.find_exn game.all_players pot_id in
          pot_player.bluffs <- pot_player.bluffs + 1;
          My_cards.add_card acc.cards ~card)
    in
    ()
  | _, _ -> ()
;;

let bluff_called ~(game : Game_state.t) ~(player : Player.t) ~cards_put_down =
  bluff_recomendation
    ~game
    ~claim:(player.id, Game_state.card_on_turn game, cards_put_down);
  print_endline
    ("\n Has anyone called Player "
     ^ Int.to_string player.id
     ^ "'s bluff? Type true and a showdown will occur. Type false and the \
        game will continue.");
  let any_calls = Bool.of_string (In_channel.input_line_exn stdin) in
  match any_calls with
  | true ->
    print_endline
      ("Has anyone called Player "
       ^ Int.to_string player.id
       ^ "'s bluff? If so, type their player id in. If not, type 'me' if \
          you would like to call your opponent's bluff.");
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
  print_endline
    ("Please specify how many cards player "
     ^ Int.to_string player.id
     ^ " put down:");
  let cards_put_down = Int.of_string (In_channel.input_line_exn stdin) in
  (*must be greater than zero*)
  player.hand_size <- player.hand_size - cards_put_down;
  let added_cards = List.init cards_put_down ~f:(fun _ -> player.id, card) in
  game.pot <- added_cards @ game.pot;
  let pot_as_string =
    List.fold game.pot ~init:"" ~f:(fun string_so_far (who_put, rank) ->
      string_so_far
      ^ Card.to_string rank
      ^ " - Player "
      ^ Int.to_string who_put
      ^ ", ")
  in
  print_endline
    "\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*";
  print_endline ("\n The pot contains: " ^ pot_as_string);
  print_endline "An opponent has made a move.";
  bluff_called ~game ~player ~cards_put_down;
  print_endline ("Cards left after move: " ^ Int.to_string player.hand_size)
;;

let rec play_game ~(game : Game_state.t) =
  print_endline "\n ------------------------------------------------------";
  let player = Game_state.whos_turn game in
  let card_on_turn = Game_state.card_on_turn game in
  match Game_state.game_over game with
  | true -> end_processes game
  | false ->
    print_endline
      ("\n It is player "
       ^ Int.to_string player.id
       ^ "'s turn to provide a(n) "
       ^ Card.to_string card_on_turn
       ^ ".");
    let _ =
      match Game_state.is_my_turn game with
      | true -> my_moves game
      | false -> opp_moves game
    in
    game.round_num <- game.round_num + 1;
    play_game ~game
;;
