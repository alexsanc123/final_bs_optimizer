open! Core
open Jsonaf.Export

type t = Player.t Int.Table.t [@@deriving sexp]

let t_of_jsonaf json =
  Int.Table.of_alist_exn ([%of_jsonaf: (int * Player.t) list] json)
;;

let jsonaf_of_t t = Hashtbl.to_alist t |> [%jsonaf_of: (int * Player.t) list]
