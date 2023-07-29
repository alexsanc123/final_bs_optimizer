open! Core
open! In_channel

let _ = 
  let prob = Bs_solver.Math_fun.prob_player_has_card in 
  ignore prob;
  ()
;;

let _ =
  let game = Bs_solver.Game.game_init () in
  Bs_solver.Game.play_game ~game
;;
