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
     | None -> Server.respond_string "Invalid arguments" ~headers:header
     | Some { num_players; my_position; ace_pos; hand } ->
       if Game_info.invalid_arguments
            ~num_players
            ~my_position
            ~hand
            ~ace_pos
       then Server.respond_string "Invalid arguments" ~headers:header
       else (
         let game =
           Game_for_react.game_init
             ~hand
             ~my_pos:my_position
             ~ace_pos
             ~num_players
             ()
         in
         let me = Hashtbl.find_exn game.all_players game.my_id in
         let win_cycle =
           Util_functions.calc_win_cycle ~me ~game_state:game
         in
         let strategy =
           Turn_action.evaluate_strategies ~win_cycle ~game_state:game
         in
         world_state.current_game <- Some game;
         world_state.player_count <- Some num_players;
         world_state.my_pos <- Some my_position;
         world_state.ace_pos <- Some ace_pos;
         world_state.whose_turn <- Some 0;
         world_state.card_on_turn <- Some Card.Ace;
         world_state.strategy <- Some strategy;
         Server.respond_string "Valid Arguments"))
  | "/opponent_move" ->
    let query = Opponent_move.parse_opp_move uri in
    (match query with
     | None ->
       Server.respond_string
         "Opponent has not made a move yet."
         ~headers:header
     | Some { num_cards } ->
       if Opponent_move.invalid_arguments ~num_cards
       then Server.respond_string "Invalid arguments"
       else (
         let game =
           match World_state.current_game world_state with
           | Some game_state -> game_state
           | _ -> failwith "Invalid game"
         in
         let player = Game_state.whos_turn game in
         let card = Game_state.card_on_turn game in
         let reccomendation =
           Game_for_react.bluff_reccomendation
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
         let me = Hashtbl.find_exn game.all_players game.my_id in
         let win_cycle =
           Util_functions.calc_win_cycle ~me ~game_state:game
         in
         let strategy =
           Turn_action.evaluate_strategies ~win_cycle ~game_state:game
         in
         world_state.strategy <- Some strategy;
         Server.respond_string "I have made a move." ~headers:header))
  | "/my_showdown" ->
    Server.respond_string "Showdown has been initiated." ~headers:header
  | "/opp_showdown" ->
    Server.respond_string "Showdown has been initiated." ~headers:header
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
