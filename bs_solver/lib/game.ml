open! Core
open! In_channel

let declare_player_count () =
  let prompt = "Please specify how many players are in the round " in
  let player_count = Stdinout.loop_num_input ~prompt in
  (* print_endline "Please specify how many players are in the round "; let
     player_count = In_channel.input_line_exn stdin in *)
  Int.of_string player_count
;;

let declare_my_pos_r_dealer () =
  let prompt =
    "Please specify your seating index at the table clockwise from the 0th \
     player (the player left of dealer): "
  in
  let my_pos = Stdinout.loop_num_input ~prompt in
  Int.of_string my_pos
;;

let declare_ace_of_spades_pos () =
  let prompt =
    "Please specify the seating index of the player w the Ace of spades: "
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

let find_true_pos ~ace_pos ~pos ~player_count =
  (pos - ace_pos) % player_count
;;

let game_init () =
  (*we dont know the position until the person with the ace of spades has
    acted*)
  let player_count = declare_player_count () in
  let my_pos = declare_my_pos_r_dealer () in
  let ace_pos = declare_ace_of_spades_pos () in
  let my_cards = declare_my_cards ~my_pos ~player_count in
  let all_players = Int.Table.create () in
  let _ =
    List.init player_count ~f:(fun player_id ->
      assert (player_count > 3);
      let cards =
        if my_pos = player_id then my_cards else My_cards.init ()
      in
      let true_pos = find_true_pos ~pos:player_id ~ace_pos ~player_count in
      Hashtbl.set
        all_players
        ~key:true_pos
        ~data:
          { Player.id = true_pos
          ; hand_size =
              (if my_pos < 52 % player_count
               then (52 / player_count) + 1
               else 52 / player_count)
          ; bluffs = 0
          ; calls = 0
          ; cards
          })
  in
  let game_state =
    { Game_state.round_num = 0
    ; player_count
    ; pot = []
    ; all_players
    ; my_id = find_true_pos ~pos:my_pos ~ace_pos ~player_count
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
  let message = "Should I Call: " ^ Bool.to_string should_i_call in
  print_endline message;
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
  let claimed_of_pot, rest_of_pot =
    List.split_n game.pot num_cards_claimed
  in
  (* print_s [%message (rest_of_pot : (int * Card.t) list)]; *)
  let revealed_cards =
    if def.id = game.my_id
    then List.map claimed_of_pot ~f:(fun (_, card) -> card)
    else
      List.init num_cards_claimed ~f:(fun _ ->
        let card_input_string = Stdinout.loop_card_input ~prompt in
        let card = Card.of_string card_input_string in
        card)
  in
  let who_lost =
    if List.for_all revealed_cards ~f:(fun card ->
         Card.equal card_on_turn card)
    then acc
    else def
  in
  who_lost.hand_size <- who_lost.hand_size + List.length game.pot;
  if who_lost.id = acc.id
  then (
    My_cards.restore_cards ~player:who_lost;
    List.iter revealed_cards ~f:(fun card ->
      My_cards.add_card who_lost.cards ~card))
  else (
    def.bluffs <- def.bluffs + 1;
    let cards_to_add =
      List.fold revealed_cards ~init:[] ~f:(fun to_add card ->
        let history, current = Hashtbl.find_exn who_lost.cards card in
        let difference = history - current in
        if difference > 0
        then (
          Hashtbl.set who_lost.cards ~key:card ~data:(history, current + 1);
          to_add)
        else to_add @ [ card ])
    in
    My_cards.restore_cards ~player:who_lost;
    List.iter cards_to_add ~f:(fun card_to_add ->
      My_cards.add_card who_lost.cards ~card:card_to_add));
  if who_lost.id = game.my_id
  then
    List.iter (List.rev rest_of_pot) ~f:(fun (pot_id, card) ->
      let message =
        "Player "
        ^ Int.to_string pot_id
        ^ " claimed "
        ^ Card.to_string card
        ^ " \n What card did they put down?"
      in
      print_endline message;
      let card_input_string = Stdinout.loop_card_input ~prompt in
      let actual_card = Card.of_string card_input_string in
      match Card.equal actual_card card with
      | true -> My_cards.add_card who_lost.cards ~card
      | false ->
        let pot_player = Hashtbl.find_exn game.all_players pot_id in
        pot_player.bluffs <- pot_player.bluffs + 1;
        My_cards.add_card who_lost.cards ~card:actual_card)
  else
    List.iter rest_of_pot ~f:(fun (pot_id, card) ->
      if pot_id = game.my_id then My_cards.add_card who_lost.cards ~card);
  Game_state.clear_cards_after_showdown game ~exclude:who_lost.id;
  game.pot <- []
;;

let check_bluff_called
  ~(game : Game_state.t)
  ~(player : Player.t)
  ~num_cards_claimed
  =
  if not (player.id = game.my_id)
  then
    bluff_recomendation
      ~game
      ~claim:(player.id, Game_state.card_on_turn game, num_cards_claimed);
  let prompt =
    "Has anyone called Player "
    ^ Int.to_string player.id
    ^ "'s bluff. Type false and the round will continue"
  in
  let any_calls = Bool.of_string (Stdinout.loop_bool_input ~prompt) in
  any_calls
;;

let bluff_called
  ~(game : Game_state.t)
  ~(player : Player.t)
  ~num_cards_claimed
  =
  let prompt =
    "Type in the id of the player who called the bluff or 'me' if you \
     called bluff"
  in
  let caller =
    Stdinout.loop_bluff_input ~prompt ~bluffer_id:player.id ~my_id:game.my_id
  in
  let caller_id =
    match caller with "me" -> game.my_id | _ -> Int.of_string caller
  in
  showdown
    ~game
    ~acc:(Hashtbl.find_exn game.all_players caller_id)
    ~def:player
    ~num_cards_claimed
;;

let my_moves game =
  let player = Game_state.whos_turn game in
  let win_cycle =
    Util_functions.calc_win_cycle ~me:player ~game_state:game
  in
  let strategy =
    Turn_action.evaluate_strategies ~win_cycle ~game_state:game
  in
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
      , Card.of_string
          (Stdinout.loop_card_i_put_input
             ~prompt:card_prompt
             ~game_state:game) ))
  in
  game.pot <- cards_put_down @ game.pot;
  player.hand_size <- player.hand_size - count;
  let any_calls =
    check_bluff_called ~game ~player ~num_cards_claimed:count
  in
  match any_calls with
  | true -> bluff_called ~game ~player ~num_cards_claimed:count
  | false ->
    ();
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
  (* print_s [%message (game.pot : (int * Card.t) list)]; *)
  print_endline "Opp made a move";
  let any_calls = check_bluff_called ~game ~player ~num_cards_claimed in
  match any_calls with
  | true ->
    My_cards.update_after_move ~player ~move:(card, num_cards_claimed);
    bluff_called ~game ~player ~num_cards_claimed
  | false ->
    My_cards.update_after_move ~player ~move:(card, num_cards_claimed)
;;

let rec play_game ~(game : Game_state.t) =
  print_endline
    "------------------------------------------------------------------------------";
  print_endline
    "------------------------------------------------------------------------------";
  let player = Game_state.whos_turn game in
  let card_on_turn = Game_state.card_on_turn game in
  match Game_state.game_over game with
  | true -> end_processes game
  | false ->
    let prompt1 =
      "It is Player "
      ^ Int.to_string player.id
      ^ " turn to provide the card: "
      ^ Card.to_string (card_on_turn : Card.t)
    in
    print_endline prompt1;
    if player.id = game.my_id
    then ()
    else (
      let prompt2 =
        "We know Player "
        ^ Int.to_string player.id
        ^ " has cards: "
        ^ My_cards.to_string player.cards
      in
      print_endline prompt2);
    let _ =
      match Game_state.is_my_turn game with
      | true -> my_moves game
      | false -> opp_moves game
    in
    game.round_num <- game.round_num + 1;
    print_endline ("Cards left after move: " ^ Int.to_string player.hand_size);
    play_game ~game
;;
