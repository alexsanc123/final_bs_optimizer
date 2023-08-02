open! Core

module T = struct
  type t = int Card.Table.t [@@deriving sexp]
end

include T
include Sexpable.To_stringable (T)

let init () =
  let my_cards = Card.Table.create () in
  let _ =
    List.init 13 ~f:(fun card_index ->
      let rank = Card.of_int (card_index + 1) in
      Hashtbl.set my_cards ~key:rank ~data:0)
  in
  my_cards
;;

let do_i_have_enough t ~(card : Card.t) ?(how_much = 1) () =
  Hashtbl.find_exn t card >= how_much
;;

let add_card t ~(card : Card.t) =
  Hashtbl.set t ~key:card ~data:(Hashtbl.find_exn t card + 1)
;;

let rm_card t ~(card : Card.t) ?(how_much = 1) () =
  match do_i_have_enough t ~card ~how_much () with
  | true -> Hashtbl.set t ~key:card ~data:(Hashtbl.find_exn t card - how_much)
  | false -> failwith ("insufficient card count" ^ Card.to_string card)
;;

let clear_cards ~(player:Player.t) = 
  player.cards <- init ()
;;

(* include Hashable.Make (T) include
   Hashable.Make_plain_and_derive_hash_fold_t (T) *)
