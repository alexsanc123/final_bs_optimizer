open! Core
open Async
open! In_channel

let game_command =
  Command.basic
    ~summary:"beep boop"
    [%map_open.Command
      let () = return () in
      fun () ->
        (* let game = Bs_solver.Game.game_init () in *)
        let game = Bs_solver.Game_state.test_game_state () in
        Bs_solver.Game.play_game ~game]
;;

let server_command =
  Command.async_or_error
    ~summary:"server beep boop"
    [%map_open.Command
      let () = return () in
      fun () ->
        let open Deferred.Or_error.Let_syntax in
        let%bind () = Bs_solver.Server.start ~port:8181 in
        Deferred.Or_error.return ()]
;;

let command =
  Command.group
    ~summary:"group beep boop"
    [ "play-game", game_command; "server", server_command ]
;;

let () = Command_unix.run command
