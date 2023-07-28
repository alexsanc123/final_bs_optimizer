open! Core

module T = struct
  type t =
    { (* maybe have two cases: Me & Opponent*)
      id : int (* represents position in group as well *)
    ; mutable hand_size : int
    ; mutable bluffs_completed : int
    ; mutable cards : int Card.Table.t
        (*remember to initialize all ranks as 0 in hashtbl*)
    }
  [@@deriving sexp, fields]
end

include T
(* include Comparable.Make (T) include Hashable.Make (T) *)
