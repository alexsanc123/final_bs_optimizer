open! Core
open Async
module Server = Cohttp_async.Server
open! Backend

(* let world_state = World_state.init () *)
let world_state = World_state.test_world ()

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
       let game =
         Game_for_react.game_init
           ~hand
           ~my_pos:my_position
           ~ace_pos
           ~num_players
           ()
       in
       world_state.current_game <- Some game;
       world_state.player_count <- Some num_players;
       world_state.my_pos <- Some my_position;
       world_state.ace_pos <- Some ace_pos;
       world_state.whose_turn <- Some 0;
       world_state.card_on_turn <- Some Card.Ace;
       Server.respond_string "Valid Arguments")
  | "/opponent_move" ->
    Server.respond_string "Opponent has made a move." ~headers:header
  | "/my_move" -> Server.respond_string "I have made a move." ~headers:header
  | "/showdown" ->
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
