open! Core
open! In_channel

let rec stdin_reprompt
  ~(prompt : string)
  ~(form_checker : string -> bool)
  ?(looped = false)
  ?(added_prompt = "Invalid Input Form: ")
  ()
  =
  let new_prompt = if looped then added_prompt ^ prompt else prompt in
  print_endline new_prompt;
  let input = In_channel.input_line_exn stdin in
  match form_checker input with
  | true -> input
  | false ->
    print_endline "x-x-x-x-x-x-x-x-x-x-Invalid Input-x-x-x-x-x-x-x-x-x-x-x-x";
    stdin_reprompt ~prompt ~form_checker ~looped:true ~added_prompt ()
;;

let alphabet = "tjqka"
let digits = "1234567890"

let card_form_checker input =
  match String.length input with
  | 1 ->
    if String.contains alphabet (Char.lowercase (String.get input 0))
    then true
    else false
  | _ -> false
;;

let num_form_checker input =
  match String.length input with
  | 0 -> false
  | _ ->
    let num = Int.of_string_opt input in
    (match num with Some _ -> true | None -> false)
;;
