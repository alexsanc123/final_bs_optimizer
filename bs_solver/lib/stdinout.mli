val loop_card_input : prompt:string -> string
val loop_num_input : prompt:string -> string

val loop_card_i_put_input
  :  prompt:string
  -> game_state:Game_state.t
  -> string

val loop_bool_input : prompt:string -> string
val loop_bluff_input : prompt:string -> bluffer_id:int -> my_id:int -> string
