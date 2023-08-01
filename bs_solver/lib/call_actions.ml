open! Core
open Util_functions

let conflicting_claim
  ~(game_state : Game_state.t)
  ~(claim : int * Card.t * int)
  =
  (*Assesses whether an opponent is lying based on the cards we have in our
    hand.*)
  let _, card, num_claimed = claim in
  let my_profile =
    Hashtbl.find_exn game_state.all_players game_state.my_id
  in
  let how_many_i_have = Hashtbl.find_exn my_profile.cards card in
  let available_cards = 4 - how_many_i_have in
  available_cards < num_claimed
;;

let check_opponent_win
  ~(game_state : Game_state.t)
  ~(claim : int * Card.t * int)
  =
  (*If an opponent's claim on their turn allows them to win the game, call
    bluff (GAME WOULD BE OVER IF THEY SUCCEEDED...) )*)
  let opponent_id = game_state.round_num % game_state.player_count in
  let opponent_profile =
    Hashtbl.find_exn game_state.all_players opponent_id
  in
  let opponent_hand_size = opponent_profile.hand_size in
  let _, _, num_claimed = claim in
  num_claimed - opponent_hand_size = 0
;;

let useful_call ~(game_state : Game_state.t) ~(claim : int * Card.t * int) =
  (*Assesses if calling a bluff would be incentivized regardlesss of the
    outcome, due to the claimed card being in the near future of our win
    cycle. ** Hardcoded threshold of "small pot" being 5 cards or less and
    "immediatley needed card" being within 4 win cycles.** *)
  let _, card_claimed, _ = claim in
  if List.length game_state.pot <= 5
  then (
    let my_profile =
      Hashtbl.find_exn game_state.all_players game_state.my_id
    in
    let win_cycle = calc_win_cycle ~me:my_profile ~game_state in
    let immediate_win_cycle, _ = List.split_n win_cycle 5 in
    let cards_we_need =
      List.filter_map immediate_win_cycle ~f:(fun (rank, how_many) ->
        match how_many with 0 -> Some rank | _ -> None)
    in
    List.exists cards_we_need ~f:(fun card_needed ->
      Card.compare card_needed card_claimed = 0))
  else false
;;

let prob_no_lie ~(game_state : Game_state.t) ~(claim : int * Card.t * int)
  : float
  =
  (*Relies on pure odds to assess whether or not we should call a bluff or
    not. Should return a bool! *)
  let who_claimed, card_claimed, num_claimed = claim in
  let known_cards_w_players, desired_cards_w_players =
    Hashtbl.fold
      game_state.all_players
      ~init:(0, 0)
      ~f:(fun ~key:_ ~data:player (tot_card_sum, tot_desired_sum) ->
      let player_known_cards, desired_qty =
        Hashtbl.fold
          player.cards
          ~init:(0, 0)
          ~f:(fun ~key:card ~data:qty (card_sum, desired_sum) ->
          let desired_sum =
            if Card.equal card card_claimed
            then desired_sum + qty
            else desired_sum
          in
          card_sum + qty, desired_sum)
      in
      player_known_cards + tot_card_sum, desired_qty + tot_desired_sum)
  in
  let known_from_pot, desired_from_pot =
    List.fold
      game_state.pot
      ~init:(0, 0)
      ~f:(fun (known_qty, desired_qty) (player_id, card) ->
      if player_id = game_state.my_id
      then (
        match Card.equal card card_claimed with
        | true -> known_qty + 1, desired_qty + 1
        | false -> known_qty + 1, desired_qty)
      else known_qty, desired_qty)
  in
  let all_known_cards, known_desired_qty =
    ( known_cards_w_players + known_from_pot
    , desired_cards_w_players + desired_from_pot )
  in
  let desired_in_unknown = 4 - known_desired_qty in
  let hand_size =
    (Hashtbl.find_exn game_state.all_players who_claimed).hand_size
    + num_claimed
  in
  let unknown_cards = 52 - all_known_cards in
  let probability =
    Math_fun.prob_player_has_card
      ~unknown_cards
      ~desired_in_unknown
      ~hand_size
      ~desired_to_be_winning:num_claimed
  in
  probability
;;

let probability_based_call
  ~(game_state : Game_state.t)
  ~(claim : int * Card.t * int)
  =
  (*actually need to implement the logic for the threshold based on how the
    game is going*)
  let probability = prob_no_lie ~game_state ~claim in
  print_endline
    ("Probability the opponent is lying: "
     ^ Float.to_string
         (100.0
          -. Float.round_significant
               ~significant_digits:4
               (probability *. 100.0))
     ^ "%");
  let threshold = 0.25 in
  Float.( <. ) probability threshold
;;

let assess_calling_bluff
  ~(game_state : Game_state.t)
  ~(claim : int * Card.t * int)
  =
  (*Runs through the different strategies to see if someone is bluffing or
    not. Strategy 1: If their claim conflicts woith the cards I currently
    have in my hand, call bluff. Strategy 2: If their claim causes them to
    win the game, call bluff. Strategy 3: If the pot is less than 5 and the
    card they are claiming is within the next 4 of my win cycle, call the
    bluff. *)
  if conflicting_claim ~game_state ~claim
  then (
    print_endline
      ("/n Probability the opponent is lying: " ^ Int.to_string 100 ^ "%");
    true)
  else if check_opponent_win ~game_state ~claim
  then (
    print_endline "/n Your opponent is about to win the game.";
    true)
  else if useful_call ~game_state ~claim
  then (
    print_endline
      "/n The pot is small and you need one of these cards in your win \
       cycle.";
    true)
  else probability_based_call ~game_state ~claim
;;
