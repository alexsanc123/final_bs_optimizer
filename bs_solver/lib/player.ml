open! Core
open Jsonaf.Export

type 'a card_table = 'a Card.Table.t [@@deriving sexp]

let card_table_of_jsonaf (type a) (a_of_jsonaf : Jsonaf.t -> a) json =
  [%of_jsonaf: (Card.t * a) list] json |> Card.Table.of_alist_exn
;;

let jsonaf_of_card_table (type a) (jsonaf_of_a : a -> Jsonaf.t) t =
  [%jsonaf_of: (Card.t * a) list] (Hashtbl.to_alist t)
;;

module T = struct
  type t =
    { (* maybe have two cases: Me & Opponent*)
      id : int (* represents position in group as well *)
    ; mutable hand_size : int
    ; mutable bluffs : int
    ; mutable cards : (int * int) card_table
    ; mutable calls : int
        (*remember to initialize all ranks as 0 in hashtbl*)
    }
  [@@deriving sexp, fields, jsonaf]
end

include T
include Sexpable.To_stringable (T)
