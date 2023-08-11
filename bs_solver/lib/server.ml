open! Core
open Async
module Server = Cohttp_async.Server
open! Backend
open! Jsonaf.Export

module Message = struct
  type t = { message : string } [@@deriving fields, sexp, jsonaf]

  let string_to_json_msg string =
    let t = { message = string } in
    Jsonaf.to_string (t |> jsonaf_of_t)
  ;;
end

let world_state = World_state.init ()

(* let world_state = World_state.test_world () *)

let ack_json_string = Message.string_to_json_msg "Ack"
let rej_json_string = Message.string_to_json_msg "Rej"

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let header = Cohttp.Header.init_with "Access-Control-Allow-Origin" "*" in
  match Uri.path uri with
  | "/world_state" ->
    Server.respond_string
      (Jsonaf.to_string (world_state |> World_state.jsonaf_of_t))
      ~headers:header
  | "/create_game" ->
    World_state.clear world_state;
    let query = Game_info.parse_game_info uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { num_players; my_position; ace_pos; hand } ->
       let game_info =
         { Game_info.num_players; my_position; ace_pos; hand }
       in
       if Game_info.invalid_arguments
            ~num_players
            ~my_position
            ~hand
            ~ace_pos
       then (
         print_endline "Invalid";
         Server.respond_string rej_json_string ~headers:header)
       else (
         print_s [%message (game_info : Game_info.t)];
         let my_true_pos = (my_position - ace_pos) % num_players in
         let game_state =
           Game_for_react.game_init
             ~hand
             ~my_pos:my_position
             ~ace_pos
             ~num_players
             ()
         in
         let me = Hashtbl.find_exn game_state.all_players my_true_pos in
         let win_cycle = Util_functions.calc_win_cycle ~me ~game_state in
         let strategy =
           Turn_action.evaluate_strategies ~win_cycle ~game_state
         in
         world_state.current_game <- Some game_state;
         world_state.whose_turn <- Some 0;
         world_state.card_on_turn <- Some Card.Ace;
         world_state.strategy <- Some strategy;
         world_state.game_log
           <- Some
                [ "Game has been created with "
                  ^ Int.to_string num_players
                  ^ " players."
                ];
         print_s [%message (world_state : World_state.t)];
         Server.respond_string ack_json_string ~headers:header))
  | "/opponent_move" ->
    let query = Opponent_move.parse_opp_move uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { num_cards } ->
       if Opponent_move.invalid_arguments ~num_cards
       then (
         print_endline "Invalid";
         Server.respond_string rej_json_string ~headers:header)
       else (
         let game_log =
           match world_state.game_log with
           | Some game_log -> game_log
           | _ -> failwith "no game log"
         in
         let game =
           match world_state.current_game with
           | Some game_state -> game_state
           | _ -> failwith "Invalid game"
         in
         let player = Game_state.whos_turn game in
         let card = Game_state.card_on_turn game in
         Game_for_react.opp_moves game ~num_cards;
         let reccomendation =
           Game_for_react.bluff_recomendation
             ~game
             ~claim:(player.id, card, num_cards)
         in
         world_state.current_game <- Some game;
         let new_log =
           game_log
           @ [ "Player "
               ^ Int.to_string player.id
               ^ " just put "
               ^ Int.to_string num_cards
               ^ " cards into the pot."
             ]
         in
         world_state.game_log <- Some new_log;
         let json_string = Message.string_to_json_msg reccomendation in
         print_endline "Working";
         Server.respond_string json_string ~headers:header))
  | "/my_move" ->
    let query = My_move.parse_my_move uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { num_cards; cards_put_down } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let game_log =
         match world_state.game_log with
         | Some game_log -> game_log
         | _ -> failwith "no game log"
       in
       if My_move.invalid_arguments ~game ~num_cards ~cards_put_down
       then (
         print_endline "Invalid";
         Server.respond_string rej_json_string ~headers:header)
       else (
         Game_for_react.my_moves game ~num_cards ~cards_put_down;
         world_state.current_game <- Some game;
         world_state.last_move <- Some cards_put_down;
         let new_log =
           game_log
           @ [ "I just put "
               ^ Int.to_string num_cards
               ^ " cards into the pot."
             ]
         in
         world_state.game_log <- Some new_log;
         print_endline "Move Made";
         Server.respond_string ack_json_string ~headers:header))
  | "/check_bluff" ->
    let query = Bluff_check.parse_bluff uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { bluff_called } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let game_log =
         match world_state.game_log with
         | Some game_log -> game_log
         | _ -> failwith "no game log"
       in
       if bluff_called
       then (
         let def = Game_state.whos_turn game in
         if def.id = game.my_id
         then (
           print_s [%message (world_state.last_move : Card.t list option)];
           let is_lie =
             (match world_state.last_move with
              | Some cards_list -> cards_list
              | _ -> failwith "No last move")
             |> List.for_all ~f:(fun card_used ->
                  Card.equal card_used (Game_state.card_on_turn game))
             |> not
           in
           if is_lie
           then (
             let new_log =
               game_log
               @ [ "I just lost a showdown and recovered "
                   ^ Int.to_string (List.length game.pot)
                   ^ " cards from the pot."
                 ]
             in
             world_state.game_log <- Some new_log;
             let json_string = Message.string_to_json_msg "Showdown Lost" in
             Server.respond_string json_string ~headers:header)
           else (
             let new_log = game_log @ [ "I just won a showdown." ] in
             world_state.game_log <- Some new_log;
             let json_string = Message.string_to_json_msg "Showdown Won" in
             Server.respond_string json_string ~headers:header))
         else (
           let new_log =
             game_log
             @ [ "Someone just called player "
                 ^ Int.to_string (Game_state.whos_turn game).id
                 ^ "'s bluff."
               ]
           in
           world_state.game_log <- Some new_log;
           let json_string = Message.string_to_json_msg "Showdown" in
           Server.respond_string json_string ~headers:header))
       else (
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         let new_log =
          game_log
          @ [ "No one called player "
              ^ Int.to_string (Game_state.whos_turn game).id
              ^ "'s bluff."
            ]
        in
        world_state.game_log <- Some new_log;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         let json_string = Message.string_to_json_msg "No Showdown" in
         Server.respond_string json_string ~headers:header))
  | "/opp_showdown" ->
    let query = Opp_showdown.parse_opp_showdown uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { caller_id; cards_revealed } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players caller_id in
       let def = Game_state.whos_turn game in
       if Opp_showdown.invalid_arguments ~caller_id ~def:def.id
       then Server.respond_string rej_json_string ~headers:header
       else if caller_id = game.my_id
               && List.for_all cards_revealed ~f:(fun card ->
                    Card.equal card (Game_state.card_on_turn game))
       then (
         world_state.last_move <- Some cards_revealed;
         let json_string = Message.string_to_json_msg "Reveal pot" in
         Server.respond_string json_string ~headers:header)
       else (
         Game_for_react.showdown ~game ~acc ~def ~cards_revealed ();
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         let json_string = Message.string_to_json_msg "Next Turn" in
         Server.respond_string json_string ~headers:header))
  | "/reveal_pot" ->
    let query = Reveal_pot.parse_pot uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { pot } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players game.my_id in
       let def = Game_state.whos_turn game in
       if Opp_showdown.invalid_arguments ~caller_id:acc.id ~def:def.id
       then Server.respond_string rej_json_string
       else (
         let cards_revealed =
           match world_state.last_move with
           | Some cards -> cards
           | None -> failwith "No cards"
         in
         Game_for_react.showdown ~game ~acc ~def ~pot ~cards_revealed ();
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         Server.respond_string ack_json_string ~headers:header))
  | "/my_showdown_lost" ->
    let query = My_showdown_lost.parse_my_showdown uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { caller_id; pot } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players caller_id in
       let def = Hashtbl.find_exn game.all_players game.my_id in
       if Opp_showdown.invalid_arguments ~caller_id ~def:def.id
       then Server.respond_string rej_json_string
       else (
         Game_for_react.showdown ~game ~acc ~def ~pot ();
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         Server.respond_string ack_json_string ~headers:header))
  | "/my_showdown_won" ->
    let query = My_showdown_won.parse_my_showdown uri in
    (match query with
     | None -> Server.respond_string rej_json_string ~headers:header
     | Some { caller_id } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players caller_id in
       let def = Hashtbl.find_exn game.all_players game.my_id in
       if Opp_showdown.invalid_arguments ~caller_id ~def:def.id
       then Server.respond_string rej_json_string
       else (
         Game_for_react.showdown ~game ~acc ~def ();
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         Server.respond_string ack_json_string ~headers:header))
  | _ ->
    Server.respond_string ~status:`Not_found rej_json_string ~headers:header
;;

let start ~port =
  Stdlib.Printf.eprintf "Listening for HTTP on port %d\n" port;
  Stdlib.Printf.eprintf
    "Try 'curl http://localhost:%d/test?hello=xyz'\n%!"
    port;
  Server.create
    ~on_handler_error:`Raise
    (Async.Tcp.Where_to_listen.of_port port)
    handler
  >>= fun _ -> Deferred.never ()
;;
