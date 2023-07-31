open! Core
open! In_channel

let _ =
  (* let game = Bs_solver.Game.game_init () in *)
  let game = Bs_solver.Game_state.test_game_state () in
  Bs_solver.Game.play_game ~game
;;
