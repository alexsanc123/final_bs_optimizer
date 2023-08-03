open! Core

module T = struct
  type t = Player.t Int.Table.t [@@deriving sexp]
end

include T
