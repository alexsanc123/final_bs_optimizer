open! Core
open Async
module Server = Cohttp_async.Server

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let header = Cohttp.Header.init_with "Access-Control-Allow-Origin" "*" in
  match Uri.path uri with
  | "/game_state" ->
    Server.respond_string
      (Jsonaf.to_string
         (Game_state.test_game_state () |> Game_state.jsonaf_of_t)) ~headers:header
  | _ -> Server.respond_string ~status:`Not_found "Route not found" ~headers:header
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
