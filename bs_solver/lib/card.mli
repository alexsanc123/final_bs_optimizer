open! Core

type t =
  | Ace
  | Two
  | Three
  | Four
  | Five
  | Six
  | Seven
  | Eight
  | Nine
  | Ten
  | Jack
  | Queen
  | King
[@@deriving sexp, compare, hash, equal]

val of_int : int -> t
val of_char : char -> t

include Hashable.S with type t := t
include Stringable.S with type t := t

val of_string : string -> t
