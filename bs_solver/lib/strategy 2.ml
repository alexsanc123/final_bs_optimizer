open! Core
open Jsonaf.Export

module T = struct
  type t = (Card.t * Card.t list) list [@@deriving sexp, compare, equal, jsonaf]
end

include T
include Sexpable.To_stringable (T)


let move_is_bluff (move : Card.t * Card.t list) : bool =
  (* Indicates whether there is a difference in cards put down and the card
     required to put down. *)
  let card_to_provide, cards_to_use = move in
  not
    (List.for_all cards_to_use ~f:(fun card ->
       Card.equal card card_to_provide))
;;

(* Expect tests for move is bluff. *)

let%expect_test "Test 1 for evaluating if a move is a bluff." =
  let move =
    Card.of_string "6", [ Card.of_string "6"; Card.of_string "A" ]
  in
  let is_bluff = move_is_bluff move in
  print_endline (Bool.to_string is_bluff);
  [%expect {|
    true
    |}]
;;

let%expect_test "Test 2 for evaluating if a move is a bluff." =
  let move =
    Card.of_string "J", [ Card.of_string "J"; Card.of_string "J" ]
  in
  let is_bluff = move_is_bluff move in
  print_endline (Bool.to_string is_bluff);
  [%expect {|
    false
    |}]
;;

let%expect_test "Test 1 for evaluating if a move is a bluff." =
  let move =
    Card.of_string "3", [ Card.of_string "2"; Card.of_string "7" ]
  in
  let is_bluff = move_is_bluff move in
  print_endline (Bool.to_string is_bluff);
  [%expect {|
    true
    |}]
;;
