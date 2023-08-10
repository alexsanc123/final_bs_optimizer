open! Core
open! Util_functions

module Opp_rec = struct
  type t =
    { conflicting : bool * string
    ; almost_win : bool * string
    ; useful : bool * string
    ; probability : string
    }
  [@@deriving fields]
end

let conflicting_claim
  ~(game_state : Game_state.t)
  ~(claim : int * Card.t * int)
  =
  (* Assesses whether an opponent is lying based on the cards we have in our
     hand. Results in 100% probabilty the opponent is lying. *)
  let _, card, num_claimed = claim in
  let qty_i_have, _ =
    Hashtbl.find_exn
      (Hashtbl.find_exn game_state.all_players game_state.my_id).cards
      card
  in
  let available_cards = 4 - qty_i_have in
  available_cards < num_claimed
;;

let useful_call ~(game_state : Game_state.t) ~(claim : int * Card.t * int) =
  (* Assesses if calling a bluff would be incentivized regardlesss of the
     outcome, due to the claimed card being in the near future of our win
     cycle. *)
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
  (* Relies on choose function to assess the probability of an opponent's
     claim being the complete truth. *)
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
          ~f:(fun ~key:card ~data:(qty, _) (card_sum, desired_sum) ->
          let desired_sum =
            if Card.equal card card_claimed
            then desired_sum + qty
            else desired_sum
          in
          card_sum + qty, desired_sum)
      in
      player_known_cards + tot_card_sum, desired_qty + tot_desired_sum)
  in
  let all_known_cards, known_desired_qty =
    known_cards_w_players, desired_cards_w_players
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
  (* given the probability an opponent is telling the complete truth, output
     the probability that they are lying, calculate an appropriate threshold
     to call, & reccomend to call or not. *)
  let probability = prob_no_lie ~game_state ~claim in
  let prob_of_lie =
    Float.round_significant
      ~significant_digits:3
      ((1. -. probability) *. 100.0)
  in
  (* print_endline ("Probability the player is lying: " ^ Float.to_string
     prob_of_lie ^ "%"); *)
  (* (let player_bluffs = (Hashtbl.find_exn game_state.all_players
     who_claimed).bluffs in let pot_size = List.length game_state.pot in let
     my_hand_size = (Hashtbl.find_exn game_state.all_players
     game_state.my_id).hand_size in let num_smaller_hand_sizes = List.init
     game_state.player_count ~f:(fun id -> (Hashtbl.find_exn
     game_state.all_players id).hand_size) |> List.filter ~f:(fun size ->
     size < my_hand_size) |> List.length in let percent_opps_winning =
     num_smaller_hand_sizes // game_state.player_count *. 100.0 in let
     aggression = if Float.( >. ) percent_opps_winning 75.0 then 1.2 else 1.0
     in let threshold = Int.to_float (pot_size * 3) /. (aggression *.
     Int.to_float player_bluffs) in print_endline ("Probability threshold is:
     " ^ Float.to_string threshold);) *)
  (* (let strategy_without_lies = List.for_all strategy ~f:(fun move -> not
     (Strategy.move_is_bluff move)) in let threshold = if
     strategy_without_lies then 100.0 else 75.0 in) *)
  if Float.( >. ) prob_of_lie 75.0
  then
    "Reccomendation: call your opponent's bluff. Probability the player is \
     lying: "
    ^ Float.to_string prob_of_lie
    ^ "%"
  else
    "Reccomendation: do not call your opponent's bluff. Probability the \
     player is lying: "
    ^ Float.to_string prob_of_lie
    ^ "%"
;;

let assess_calling_bluff
  ~(game_state : Game_state.t)
  ~(claim : int * Card.t * int)
  : Opp_rec.t
  =
  (*Runs through the different strategies to see if someone is bluffing or
    not. Strategy 1: If their claim conflicts woith the cards I currently
    have in my hand, call bluff. Strategy 2: If their claim causes them to
    win the game, call bluff. Strategy 3: If the pot is less than 5 and the
    card they are claiming is within the next 4 of my win cycle, call the
    bluff. *)
  let opp_id, _, _ = claim in
  let opp = Hashtbl.find_exn game_state.all_players opp_id in
  { conflicting =
      ( conflicting_claim ~game_state ~claim
      , "Probability the opponent is lying: 100%" )
  ; almost_win = opp.hand_size = 0, "Your opponent is about to win the game."
  ; useful =
      ( useful_call ~game_state ~claim
      , "The pot is small and you need one of these cards in your win cycle."
      )
  ; probability = probability_based_call ~game_state ~claim
  }
;;

let assess_bluff ~(game_state : Game_state.t) ~(claim : int * Card.t * int) =
  (*for command line tool sicne i messed up the one above lol *)
  let opp_id, _, _ = claim in
  let opp = Hashtbl.find_exn game_state.all_players opp_id in
  if conflicting_claim ~game_state ~claim
  then (
    print_endline "Probability the opponent is lying: 100%";
    true)
  else if opp.hand_size = 0
  then (
    print_endline "Your opponent is about to win the game.";
    true)
  else if useful_call ~game_state ~claim
  then (
    print_endline
      "The pot is small and you need one of these cards to complete your \
       cycle.";
    true)
  else (
    let probability = prob_no_lie ~game_state ~claim in
    let prob_of_lie =
      Float.round_significant
        ~significant_digits:3
        ((1. -. probability) *. 100.0)
    in
    print_s [%message "Prob that player is lyying" (prob_of_lie : float)];
    Float.( >. ) prob_of_lie 75.0)
;;

(* let check_opponent_win ~(game_state : Game_state.t) ~(claim : int * Card.t
   * int) = (*If an opponent's claim on their turn allows them to win the
   game, call bluff (GAME WOULD BE OVER IF THEY SUCCEEDED...) )*) (*assumes
   players hand has already been decremented*) let opponent_id =
   game_state.round_num % game_state.player_count in let opponent_profile =
   Hashtbl.find_exn game_state.all_players opponent_id in let
   opponent_hand_size = opponent_profile.hand_size in let _, _, num_claimed =
   claim in num_claimed - opponent_hand_size = 0 ;; *)
