open! Core

module T = struct
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
end

include T
include Comparable.Make (T)
include Sexpable.To_stringable (T)
include Hashable.Make (T)

(* include Hashable.Make_plain_and_derive_hash_fold_t (T) *)
let of_int int =
  (*This might need to start at 0, to account for matching with id and round
    starting at 0*)
  match int with
  | 1 -> Ace
  | 2 -> Two
  | 3 -> Three
  | 4 -> Four
  | 5 -> Five
  | 6 -> Six
  | 7 -> Seven
  | 8 -> Eight
  | 9 -> Nine
  | 10 -> Ten
  | 11 -> Jack
  | 12 -> Queen
  | 13 -> King
  | _ -> failwith "invalid int"
;;

let of_char char =
  match Char.uppercase char with
  | 'A' -> Ace
  | '1' -> Ace
  | '2' -> Two
  | '3' -> Three
  | '4' -> Four
  | '5' -> Five
  | '6' -> Six
  | '7' -> Seven
  | '8' -> Eight
  | '9' -> Nine
  | 'T' -> Ten
  | 'J' -> Jack
  | 'Q' -> Queen
  | 'K' -> King
  | _ -> failwith "invalid char"
;;

let of_string string = of_char (String.get string 0)
