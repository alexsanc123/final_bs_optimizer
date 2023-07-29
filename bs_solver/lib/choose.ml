open! Core

let rec factorial_of int ?(acc = 1) () =
  match int with
  | 1 -> acc
  | _ ->
    let acc = acc * int in
    factorial_of (int - 1) ~acc ()
;;

let choose ~n ~k =
  let result = 
  factorial_of n () / (factorial_of k () * factorial_of (n - k) ()) in 
  print_s[%message (result:int)];
  result
;;
