open! Core
open! In_channel

let _ = Bs_solver.Choose.choose ~n:1000000 ~k:3

let _ =
  let game = Bs_solver.Game.game_init () in
  Bs_solver.Game.play_game ~game
;;
