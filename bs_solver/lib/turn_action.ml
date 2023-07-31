open! Core
open Util_functions

let rec lie_with_last_card
  ~(win_cycle : (Card.t * int) list)
  ~(strategy : Strategy.t)
  : Strategy.t
  =
  match win_cycle with
  | [] -> strategy
  | _ ->
    let hd_win_cycle, rest_win = List.split_n win_cycle 1 in
    let card, how_many = List.hd_exn hd_win_cycle in
    (match how_many with
     | 0 ->
       let rest_win_length = List.length rest_win in
       let beg_rest_win, tl_rest_win =
         List.split_n rest_win (rest_win_length - 1)
       in
       let last_card, qty = List.hd_exn tl_rest_win in
       (match qty with
        | 1 ->
          let strategy = strategy @ [ card, [ last_card ] ] in
          lie_with_last_card ~win_cycle:(chop_win_seq beg_rest_win) ~strategy
        | _ ->
          let strategy = strategy @ [ card, [ last_card ] ] in
          let new_win_cycle = beg_rest_win @ [ last_card, qty - 1 ] in
          lie_with_last_card
            ~win_cycle:(chop_win_seq new_win_cycle)
            ~strategy)
     | _ ->
       let cards_to_provide = List.init how_many ~f:(fun _ -> card) in
       let strategy = strategy @ [ card, cards_to_provide ] in
       lie_with_last_card ~win_cycle:(chop_win_seq rest_win) ~strategy)
;;

let quantify_bluffs ~(strategy : Strategy.t) =
  let bluffs_on_turn =
    List.map strategy ~f:(fun (card_needed, what_to_use_list) ->
      List.exists what_to_use_list ~f:(fun card_to_use ->
        Card.compare card_needed card_to_use <> 0))
  in
  let bluffs_list =
    List.filter bluffs_on_turn ~f:(fun bluff_or_not -> bluff_or_not)
  in
  List.length bluffs_list
;;

let _evaluate_strategies ~(win_cycle : (Card.t * int) list) : Strategy.t =
  (*Uses our predetermined scoring heuristics to evaluate the least risky
    strategy.*)
  let strategies =
    [ lie_with_last_card ~win_cycle ~strategy:[]
      (*add more functionality for different strategies here*)
    ]
  in
  let scored_strategies =
    List.map strategies ~f:(fun strategy ->
      let score = quantify_bluffs ~strategy * 2 in
      (*add any other additional scoring with increased functionality*)
      strategy, score)
  in
  let best_strategy =
    List.min_elt
      scored_strategies
      ~compare:(fun (_, score_one) (_, score_two) ->
      Int.compare score_one score_two)
  in
  match best_strategy with Some (strat, _) -> strat | _ -> []
;;

let _act_on_strategy ~(strategy : Strategy.t) ~(card_to_provide : Card.t)
  : Card.t list
  =
  (*Given a strategy and the card were supposed to output for, returns a list
    of the cards to use.*)
  let _, list_of_cards_to_use =
    List.hd_exn
      (List.filter strategy ~f:(fun (card, _) ->
         Card.compare card card_to_provide = 0))
  in
  list_of_cards_to_use
;;

(***********************************************************************************)
(*Expect tests for using the strategy to lie with the last card.*)

let%expect_test "Test 1 for lying with the last card." =
  let win_cycle =
    [ Card.of_string "4", 3
    ; Card.of_string "9", 1
    ; Card.of_string "A", 0
    ; Card.of_string "6", 0
    ; Card.of_string "J", 0
    ; Card.of_string "3", 1
    ; Card.of_string "8", 0
    ; Card.of_string "K", 1
    ; Card.of_string "5", 1
    ; Card.of_string "T", 1
    ]
  in
  let strategy = [] in
  let lie_w_last = lie_with_last_card ~win_cycle ~strategy in
  List.iter lie_w_last ~f:(fun (card_to_provide, card_to_use_list) ->
    print_s [%message (card_to_provide : Card.t)];
    List.iter card_to_use_list ~f:(fun card_to_use ->
      print_s [%message (card_to_use : Card.t)]));
  [%expect
    {|
    (card_to_provide Four)
    (card_to_use Four)
    (card_to_use Four)
    (card_to_use Four)
    (card_to_provide Nine)
    (card_to_use Nine)
    (card_to_provide Ace)
    (card_to_use Ten)
    (card_to_provide Six)
    (card_to_use Five)
    (card_to_provide Jack)
    (card_to_use King)
    (card_to_provide Three)
    (card_to_use Three)
    |}]
;;

let%expect_test "Test 2 for lying with the last card." =
  let win_cycle =
    [ Card.of_string "6", 1
    ; Card.of_string "Q", 0
    ; Card.of_string "5", 3
    ; Card.of_string "J", 2
    ; Card.of_string "4", 0
    ; Card.of_string "T", 1
    ; Card.of_string "3", 2
    ; Card.of_string "9", 1
    ]
  in
  let strategy = [] in
  let lie_w_last = lie_with_last_card ~win_cycle ~strategy in
  List.iter lie_w_last ~f:(fun (card_to_provide, card_to_use_list) ->
    print_s [%message (card_to_provide : Card.t)];
    List.iter card_to_use_list ~f:(fun card_to_use ->
      print_s [%message (card_to_use : Card.t)]));
  [%expect
    {|
    (card_to_provide Six)
    (card_to_use Six)
    (card_to_provide Queen)
    (card_to_use Nine)
    (card_to_provide Five)
    (card_to_use Five)
    (card_to_use Five)
    (card_to_use Five)
    (card_to_provide Jack)
    (card_to_use Jack)
    (card_to_use Jack)
    (card_to_provide Four)
    (card_to_use Three)
    (card_to_provide Ten)
    (card_to_use Ten)
    (card_to_provide Three)
    (card_to_use Three)
    |}]
;;

(* Expect tests for quantifying bluffs. *)

let%expect_test "Test 1 for quanitfying bluffs." =
  let win_cycle =
    [ Card.of_string "4", 3
    ; Card.of_string "9", 1
    ; Card.of_string "A", 0
    ; Card.of_string "6", 0
    ; Card.of_string "J", 0
    ; Card.of_string "3", 1
    ; Card.of_string "8", 0
    ; Card.of_string "K", 1
    ; Card.of_string "5", 1
    ; Card.of_string "T", 1
    ]
  in
  let strategy = [] in
  let lie_w_last = lie_with_last_card ~win_cycle ~strategy in
  let how_many_bluffs = quantify_bluffs ~strategy:lie_w_last in
  print_endline (Int.to_string how_many_bluffs);
  [%expect {|
    3
    |}]
;;

let%expect_test "Test 2 for quantifying bluffs." =
  let win_cycle =
    [ Card.of_string "6", 1
    ; Card.of_string "Q", 0
    ; Card.of_string "5", 3
    ; Card.of_string "J", 2
    ; Card.of_string "4", 0
    ; Card.of_string "T", 1
    ; Card.of_string "3", 2
    ; Card.of_string "9", 1
    ]
  in
  let strategy = [] in
  let lie_w_last = lie_with_last_card ~win_cycle ~strategy in
  let how_many_bluffs = quantify_bluffs ~strategy:lie_w_last in
  print_endline (Int.to_string how_many_bluffs);
  [%expect {|
    2
    |}]
;;
