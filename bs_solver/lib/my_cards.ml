open! Core

type t = int Card.Table.t [@@deriving sexp]

let init () =
  let my_cards = Card.Table.create () in
  let _ =
    List.init 13 ~f:(fun card_index ->
      let rank = Card.of_int (card_index + 1) in
      Hashtbl.set my_cards ~key:rank ~data:0)
  in
  my_cards
;;

let add_card t ~(card : Card.t) =
  Hashtbl.set t ~key:card ~data:(Hashtbl.find_exn t card + 1)
;;

(* include Hashable.Make (T) include
   Hashable.Make_plain_and_derive_hash_fold_t (T) *)
