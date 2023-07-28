open! Core

module T = struct
  type t = Player.t Int.Table.t [@@deriving sexp]
end

include T
(* include Hashable.Make (T) include
   Hashable.Make_plain_and_derive_hash_fold_t (T) *)
