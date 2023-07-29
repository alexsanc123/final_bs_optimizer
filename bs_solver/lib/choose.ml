open! Core

let rec factorial_of int ?(acc = 1) ?(until = 1) () =
  match int = until with
  | true -> acc
  | false ->
    (match int with
     | 1 -> acc
     | _ ->
       let acc = acc * int in
       factorial_of (int - 1) ~until ~acc ())
;;

let choose ~n ~k = factorial_of n ~until:(n - k) () / factorial_of k ()

(*------------------------------------------Expect
  Test------------------------------------------------*)

let%expect_test "Tests for choose function" =
  let result = choose ~n:10 ~k:3 in
  print_s [%message (result : int)];
  [%expect {|
    (result 120)
    |}]
;;

let%expect_test "Test 2 for chose function" =
  let result = choose ~n:40 ~k:8 in
  print_s [%message (result : int)];
  [%expect {|
    (result 76904685)
    |}]
;;

let%expect_test "Test 3 for chose function" =
  let result = choose ~n:1 ~k:1 in
  print_s [%message (result : int)];
  [%expect {|
    (result 1)
    |}]
;;
