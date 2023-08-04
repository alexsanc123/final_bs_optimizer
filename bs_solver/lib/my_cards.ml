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
  (* does my player have enough cards for this claim*)
  let _, current = Hashtbl.find_exn t card in
  current >= how_much
;;

let add_card t ~(card : Card.t) =
  let history, current = Hashtbl.find_exn t card in
  Hashtbl.set t ~key:card ~data:(history + 1, current + 1)
;;

let rm_my_card t ~(card : Card.t) ?(how_much = 1) () =
  (*removes card from my player*)
  let history, current = Hashtbl.find_exn t card in
  match do_i_have_enough t ~card ~how_much () with
  | true ->
    Hashtbl.set t ~key:card ~data:(history - how_much, current - how_much)
  | false -> failwith ("insufficient card count" ^ Card.to_string card)
;;

let clear_cards ~(player : Player.t) =
  (* Processes for when a player does not recover the pot. *)
  let table_keys = Hashtbl.keys player.cards in
  List.iter table_keys ~f:(fun card ->
    let _, current = Hashtbl.find_exn player.cards card in
    let new_val = if current = 0 then 0, 0 else current, current in
    Hashtbl.set player.cards ~key:card ~data:new_val)
;;

let restore_cards ~(player : Player.t) =
  (*restores a players hand to history if recovers pot*)
  let table_keys = Hashtbl.keys player.cards in
  List.iter table_keys ~f:(fun card ->
    let history, _ = Hashtbl.find_exn player.cards card in
    Hashtbl.set player.cards ~key:card ~data:(history, history))
;;

let update_after_move ~(player : Player.t) ~(move : Card.t * int) =
  (*decrements current after move while keeping history*)
  let _, num_put_down = move in
  let table_keys = Hashtbl.keys player.cards in
  List.iter table_keys ~f:(fun card ->
    let history, current = Hashtbl.find_exn player.cards card in
    let new_current = current - num_put_down in
    let new_val =
      if new_current < 0 then history, 0 else history, new_current
    in
    Hashtbl.set player.cards ~key:card ~data:new_val)
;;

let to_string t =
  Hashtbl.fold
    t
    ~init:""
    ~f:(fun ~key:card ~data:(history, current) built_string ->
    match history, current with
    | 0, 0 -> built_string
    | _, _ ->
      [%string
        "%{built_string}%{card#Card} - (h: %{history#Int}, c: \
         %{current#Int})"])
;;

(* include Hashable.Make (T) include
   Hashable.Make_plain_and_derive_hash_fold_t (T) *)
