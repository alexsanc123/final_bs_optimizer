open! Core
open! In_channel

let _ =
  let game = Bs_solver.Game.game_init () in
  Bs_solver.Game.play_game ~game
;;
