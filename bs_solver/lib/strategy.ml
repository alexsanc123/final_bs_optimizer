open! Core

module T = struct
  type t = (Card.t * Card.t list) list [@@deriving sexp, compare, equal]
end

include T
include Sexpable.To_stringable (T)
