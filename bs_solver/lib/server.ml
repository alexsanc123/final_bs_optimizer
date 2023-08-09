open! Core
open Async
module Server = Cohttp_async.Server
open! Backend

let world_state = World_state.init ()

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let header = Cohttp.Header.init_with "Access-Control-Allow-Origin" "*" in
  match Uri.path uri with
  | "/world_state" ->
    Server.respond_string
      (Jsonaf.to_string (world_state |> World_state.jsonaf_of_t))
      ~headers:header
  | "/create_game" ->
    let query = Game_info.parse_game_info uri in
    (match query with
     | None -> Server.respond_string "No game created" ~headers:header
     | Some { num_players; my_position; ace_pos; hand } ->
       if Game_info.invalid_arguments
            ~num_players
            ~my_position
            ~hand
            ~ace_pos
       then Server.respond_string "Invalid arguments" ~headers:header
       else (
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
         Server.respond_string "Game created"))
  | "/opponent_move" ->
    let query = Opponent_move.parse_opp_move uri in
    (match query with
     | None ->
       Server.respond_string "Opp hasnt made a move yet." ~headers:header
     | Some { num_cards } ->
       if Opponent_move.invalid_arguments ~num_cards
       then Server.respond_string "Invalid arguments"
       else (
         let game =
           match world_state.current_game with
           | Some game_state -> game_state
           | _ -> failwith "Invalid game"
         in
         let player = Game_state.whos_turn game in
         let card = Game_state.card_on_turn game in
         let reccomendation =
           Game_for_react.bluff_recomendation
             ~game
             ~claim:(player.id, card, num_cards)
         in
         Game_for_react.opp_moves game ~num_cards;
         world_state.current_game <- Some game;
         Server.respond_string reccomendation ~headers:header))
  | "/my_move" ->
    let query = My_move.parse_my_move uri in
    (match query with
     | None ->
       Server.respond_string "I have not made a move yet." ~headers:header
     | Some { num_cards; cards_put_down } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       if My_move.invalid_arguments ~game ~num_cards ~cards_put_down
       then Server.respond_string "Invalid arguments"
       else (
         Game_for_react.my_moves game ~num_cards ~cards_put_down;
         world_state.current_game <- Some game;
         world_state.last_move <- Some cards_put_down;
         Server.respond_string "I have made a move." ~headers:header))
  | "/check_bluff" ->
    let query = Bluff_check.parse_bluff uri in
    (match query with
     | None ->
       Server.respond_string
         "Showdown has not been threatened"
         ~headers:header
     | Some { bluff_called } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       if bluff_called
       then (
         let def = Game_state.whos_turn game in
         if def.id = game.my_id
         then (
           let is_lie =
             (match world_state.last_move with
              | Some cards_list -> cards_list
              | _ -> failwith "No last move")
             |> List.for_all ~f:(fun card_used ->
                  Card.equal card_used (Game_state.card_on_turn game))
           in
           if is_lie
           then
             Server.respond_string
               "My showdown lost, reveal the pot"
               ~headers:header
           else Server.respond_string "My showdown won" ~headers:header)
         else
           Server.respond_string
             "A showdown has been initiated"
             ~headers:header)
       else (
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         Server.respond_string "Move on to the next turn" ~headers:header))
  | "/opp_showdown" ->
    let query = Opp_showdown.parse_opp_showdown uri in
    (match query with
     | None ->
       Server.respond_string "Showdown info not received" ~headers:header
     | Some { caller_id; cards_revealed } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players caller_id in
       let def = Game_state.whos_turn game in
       if Opp_showdown.invalid_arguments ~caller_id ~def:def.id
       then Server.respond_string "Invalid arguments"
       else (
         Game_for_react.showdown ~game ~acc ~def ~cards_revealed ();
         game.round_num <- game.round_num + 1;
         world_state.current_game <- Some game;
         world_state.whose_turn <- Some (Game_state.whos_turn game).id;
         world_state.card_on_turn <- Some (Game_state.card_on_turn game);
         Server.respond_string
           "Opponent showdown has been completed."
           ~headers:header))
  | "/my_showdown_lost" ->
    let query = My_showdown_lost.parse_my_showdown uri in
    (match query with
     | None ->
       Server.respond_string "Showdown info not received" ~headers:header
     | Some { caller_id; pot } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players caller_id in
       let def = Hashtbl.find_exn game.all_players game.my_id in
       if Opp_showdown.invalid_arguments ~caller_id ~def:def.id
       then Server.respond_string "Invalid arguments"
       else (
         Game_for_react.showdown ~game ~acc ~def ~pot ();
         world_state.current_game <- Some game;
         Server.respond_string "Showdown has been completed" ~headers:header))
  | "/my_showdown_won" ->
    let query = My_showdown_won.parse_my_showdown uri in
    (match query with
     | None ->
       Server.respond_string "Showdown info not received" ~headers:header
     | Some { caller_id } ->
       let game =
         match World_state.current_game world_state with
         | Some game_state -> game_state
         | _ -> failwith "Invalid game"
       in
       let acc = Hashtbl.find_exn game.all_players caller_id in
       let def = Hashtbl.find_exn game.all_players game.my_id in
       if Opp_showdown.invalid_arguments ~caller_id ~def:def.id
       then Server.respond_string "Invalid arguments"
       else (
         Game_for_react.showdown ~game ~acc ~def ();
         world_state.current_game <- Some game;
         Server.respond_string "Showdown has been completed" ~headers:header))
  | _ ->
    Server.respond_string
      ~status:`Not_found
      "Route not found"
      ~headers:header
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
