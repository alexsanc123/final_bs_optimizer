open! Core

module T = struct
  type t = (int * int) Card.Table.t [@@deriving sexp]
end

include T
include Sexpable.To_stringable (T)

let init () =
  let my_cards = Card.Table.create () in
  let _ =
    List.init 13 ~f:(fun card_index ->
      let rank = Card.of_int (card_index + 1) in
      Hashtbl.set my_cards ~key:rank ~data:(0, 0))
  in
  my_cards
;;

let do_i_have_enough t ~(card : Card.t) ?(how_much = 1) () =
  (* Ensures a card claim can be valid based on my current hand. *)
  let _, current = Hashtbl.find_exn t card in
  current >= how_much
;;

let add_card t ~(card : Card.t) =
  let history, current = Hashtbl.find_exn t card in
  Hashtbl.set t ~key:card ~data:(history + 1, current + 1)
;;

let rm_card t ~(card : Card.t) ?(how_much = 1) () =
  let history, current = Hashtbl.find_exn t card in
  match do_i_have_enough t ~card ~how_much () with
  | true -> Hashtbl.set t ~key:card ~data:(history, current - how_much)
  | false -> failwith ("insufficient card count" ^ Card.to_string card)
;;

let clear_cards ~(player : Player.t) =
  (* Processes for when a player does not recover the pot. *)
  Hashtbl.iteri player.cards ~f:(fun ~key:card ~data:(_, current) ->
    let new_val = if current = 0 then 0, 0 else current, current in
    Hashtbl.set player.cards ~key:card ~data:new_val)
;;

let restore_cards ~(player : Player.t) =
  (* In the event a player recovered a pot they contributed to, restores all
     of the cards we knew about*)
  Hashtbl.iteri player.cards ~f:(fun ~key:card ~data:(history, _) ->
    Hashtbl.set player.cards ~key:card ~data:(history, history))
;;

let update_after_move ~(player : Player.t) ~(move : Card.t * int) =
  let _, num_put_down = move in
  Hashtbl.iteri player.cards ~f:(fun ~key:card ~data:(history, current) ->
    let difference = current - num_put_down in
    let new_val =
      if difference < 0 then history, 0 else history, difference
    in
    Hashtbl.set player.cards ~key:card ~data:new_val)
;;

(* include Hashable.Make (T) include
   Hashable.Make_plain_and_derive_hash_fold_t (T) *)
