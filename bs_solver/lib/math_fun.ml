open! Core

let rec factorial_of int ?(acc = Bignum.one) ?(until = Bignum.one) ()
  : Bignum.t
  =
  (* Calculate the factorial of a number, with or without a given stop
     condition. *)
  Bignum.(
    match int = until with
    | true -> acc
    | false ->
      if int = Bignum.one
      then acc
      else (
        let acc = acc * int in
        factorial_of (int - Bignum.one) ~until ~acc ()))
;;

let choose ~n ~k : Bignum.t =
  (* Calculates the number of ways to make k sized n derivatives. *)
  if n < k
  then Bignum.zero
  else if k = 0
  then Bignum.one
  else if n = k
  then Bignum.one
  else
    Bignum.(
      factorial_of (of_int n) ~until:(of_int n - of_int k) ()
      / factorial_of (of_int k) ())
;;

let winning_hands_helper
  ~unknown_cards
  ~desired_in_unknown
  ~hand_size
  ~desired_to_be_winning
  ~extra_desired_cards
  : Bignum.t
  =
  let desired_i_have = desired_to_be_winning + extra_desired_cards in
  let ways_to_sat_win_cond =
    choose ~n:desired_in_unknown ~k:desired_i_have
  in
  (* print_s [%message (ways_to_sat_win_cond : int)]; *)
  let ways_to_fill_rest =
    choose
      ~n:(unknown_cards - desired_in_unknown)
      ~k:(hand_size - desired_i_have)
  in
  (* print_s [%message (ways_to_fill_rest : int)]; *)
  Bignum.( * ) ways_to_sat_win_cond ways_to_fill_rest
;;

let rec summation ?(sum_var = 0) ~stop_cond ~sum_func ?(sum = Bignum.zero) ()
  : Bignum.t
  =
  (* print_s [%message (sum_var : int) (sum : int)]; *)
  if stop_cond sum_var
  then sum
  else (
    (* print_endline "ready to apply sum fun"; *)
    let new_sum = Bignum.( + ) sum (sum_func sum_var) in
    (* print_endline "applied sum fun"; *)
    let sum_var = sum_var + 1 in
    summation ~sum_var ~stop_cond ~sum_func ~sum:new_sum ())
;;

let count_all_winning_hands
  ~unknown_cards
  ~desired_in_unknown
  ~hand_size
  ~desired_to_be_winning
  =
  (* print_endline "Entered function"; *)
  let stop_cond sum_var =
    sum_var > hand_size - desired_to_be_winning (* andd a second cond*)
  in
  (* print_endline "Computed stop cond"; *)
  let sum_func sum_var =
    winning_hands_helper
      ~unknown_cards
      ~desired_in_unknown
      ~hand_size
      ~desired_to_be_winning
      ~extra_desired_cards:sum_var
  in
  (* print_endline "comp sum func"; print_s [%message (summation ~stop_cond
     ~sum_func () : int)]; *)
  summation ~stop_cond ~sum_func ()
;;

let prob_player_has_card
  ~(unknown_cards : int)
  ~(desired_in_unknown : int)
  ~(hand_size : int)
  ~(desired_to_be_winning : int)
  =
  (*Computes the probability player has x desired cards assuming he has y
    unknown card in hand an z unknown cards in play*)
  let count_of_winning_hands =
    count_all_winning_hands
      ~unknown_cards
      ~desired_in_unknown
      ~hand_size
      ~desired_to_be_winning
  in
  (* print_s [%message (choose ~n:unknown_cards ~k:hand_size : int)]; *)
  let count_of_all_hands = choose ~n:unknown_cards ~k:hand_size in
  (* print_s [%message (count_of_winning_hands : float)]; print_s [%message
     (count_of_all_hands : float)]; *)
  Bignum.to_float Bignum.(count_of_winning_hands / count_of_all_hands)
;;

(*******************************************************************)
(* Expect Tests for the math functions*)

let%expect_test "Test0 for prob player has card" =
  (*Not tested*)
  let result =
    prob_player_has_card
      ~unknown_cards:36
      ~desired_in_unknown:4
      ~hand_size:17
      ~desired_to_be_winning:1
  in
  print_s [%message (result : float)];
  [%expect {| (result 0.93419913419913425) |}]
;;

let%expect_test "Test1 for prob player has card" =
  (*Not tested*)
  let result =
    prob_player_has_card
      ~unknown_cards:44
      ~desired_in_unknown:3
      ~hand_size:10
      ~desired_to_be_winning:2
  in
  print_s [%message (result : float)];
  [%expect {| (result 0.12458471760797342) |}]
;;

(*not tested*)

let%expect_test "Test2 for prob player has card" =
  let result =
    prob_player_has_card
      ~unknown_cards:20
      ~desired_in_unknown:6
      ~hand_size:5
      ~desired_to_be_winning:3
  in
  print_s [%message (result : float)];
  [%expect {|(result 0.13132094943240455)|}]
;;

let%expect_test "Test3 for prob player has card" =
  let result =
    prob_player_has_card
      ~unknown_cards:4
      ~desired_in_unknown:2
      ~hand_size:2
      ~desired_to_be_winning:2
  in
  print_s [%message (result : float)];
  [%expect {|(result 0.16666666666666666)|}]
;;

let%expect_test "Test for count win hands function" =
  let result =
    count_all_winning_hands
      ~unknown_cards:10
      ~desired_in_unknown:4
      ~hand_size:3
      ~desired_to_be_winning:2
  in
  print_s [%message (result : Bignum.t)];
  [%expect {| (result 40) |}]
;;

let%expect_test "Test for Sum function" =
  let result =
    summation
      ~stop_cond:(fun int -> int > 10)
      ~sum_func:(fun int -> Bignum.(of_int int * of_int int))
      ()
  in
  print_s [%message (result : Bignum.t)];
  [%expect {| (result 385) |}]
;;

let%expect_test "Test 1 for choose function" =
  let result = choose ~n:10 ~k:3 in
  print_s [%message (result : Bignum.t)];
  [%expect {| (result 120) |}]
;;

let%expect_test "Test 2 for chose function" =
  let result = choose ~n:40 ~k:8 in
  print_s [%message (result : Bignum.t)];
  [%expect {| (result 76904685) |}]
;;

let%expect_test "Test 3 for chose function" =
  let result = choose ~n:1 ~k:1 in
  print_s [%message (result : Bignum.t)];
  [%expect {| (result 1) |}]
;;

let%expect_test "Test 4 for chose function" =
  let result = choose ~n:36 ~k:17 in
  print_s [%message (result : Bignum.t)];
  [%expect {| (result 8597496600) |}]
;;
