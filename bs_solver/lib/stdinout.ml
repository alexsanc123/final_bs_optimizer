open! Core
open! In_channel

let rec stdin_reprompt
  ~(prompt : string)
  ~(form_checker : string -> bool)
  ?(looped = false)
  ?(added_prompt = "")
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

(* let alphabet = "tjqka" *)
let card_chars = "123456789tjqka"

let card_form_checker input =
  match String.length input with
  | 1 ->
    if String.contains card_chars (Char.lowercase (String.get input 0))
    then true
    else false
  | _ -> false
;;

let card_i_put_form_checker input ~(my_player : Player.t) =
  let valid_input = card_form_checker input in
  match valid_input with
  | true ->
    let card = Card.of_string input in
    (match My_cards.do_i_have_enough my_player.cards ~card () with
     | true ->
       My_cards.rm_my_card my_player.cards ~card ();
       true
     | false -> false)
  | false -> false
;;

let num_form_checker input =
  match String.length input with
  | 0 -> false
  | _ ->
    let num = Int.of_string_opt input in
    (match num with Some _ -> true | None -> false)
;;

let bool_form_checker input =
  match String.lowercase input with
  | "t" -> true
  | "true" -> true
  | "yes" -> true
  | "y" -> true
  | "f" -> true
  | "no" -> true
  | "n" -> true
  | "false" -> true
  | _ -> false
;;

let bluff_form_checker input ~(bluffer_id : int) ~(my_id : int) =
  if String.equal "me" input
  then not (bluffer_id = my_id)
  else num_form_checker input && bluffer_id <> Int.of_string input
;;

let loop_card_input ~prompt =
  stdin_reprompt ~prompt ~form_checker:card_form_checker ()
;;

let loop_num_input ~prompt =
  stdin_reprompt ~prompt ~form_checker:num_form_checker ()
;;

let loop_card_i_put_input ~prompt ~(game_state : Game_state.t) =
  let my_player = Hashtbl.find_exn game_state.all_players game_state.my_id in
  stdin_reprompt
    ~prompt
    ~form_checker:(card_i_put_form_checker ~my_player)
    ()
;;

let loop_bool_input ~prompt =
  match stdin_reprompt ~prompt ~form_checker:bool_form_checker () with
  | "t" -> "true"
  | "f" -> "false"
  | "yes" -> "true"
  | "no" -> "false"
  | "y" -> "true"
  | "n" -> "false"
  | answer -> answer
;;

let loop_bluff_input ~prompt ~(bluffer_id : int) ~(my_id : int) =
  stdin_reprompt
    ~prompt
    ~form_checker:(bluff_form_checker ~bluffer_id ~my_id)
    ()
;;
