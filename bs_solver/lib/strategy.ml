open! Core

module T = struct
  type t = (Card.t * Card.t list) list [@@deriving sexp, compare, equal]
end

include T
include Sexpable.To_stringable (T)

let move_is_bluff (move : Card.t * Card.t list) : bool =
  (*add test case*)
  let card_to_provide, cards_to_use = move in
  not
    (List.for_all cards_to_use ~f:(fun card ->
       Card.equal card card_to_provide))
;;
