open! Core
open! In_channel

let declare_my_cards ~hand =
  let my_cards = My_cards.init () in
  List.iter hand ~f:(fun card -> My_cards.add_card my_cards ~card);
  my_cards
;;

let find_true_pos ~ace_pos ~pos ~num_players = (pos - ace_pos) % num_players

let game_init
  ~(hand : Card.t list)
  ~(ace_pos : int)
  ~(my_pos : int)
  ~(num_players : int)
  ()
  : Game_state.t
  =
  let my_cards = declare_my_cards ~hand in
  let all = Int.Table.create () in
  let _ =
    List.init num_players ~f:(fun player_id ->
      assert (num_players > 3);
      let cards =
        if my_pos = player_id then my_cards else My_cards.init ()
      in
      let true_pos = find_true_pos ~pos:player_id ~ace_pos ~num_players in
      Hashtbl.set
        all
        ~key:true_pos
        ~data:
          { Player.id = true_pos
          ; hand_size =
              (if my_pos < 52 % num_players
               then (52 / num_players) + 1
               else 52 / num_players)
          ; bluffs = 0
          ; calls = 0
          ; cards
          })
  in
  { Game_state.round_num = 0
  ; player_count = num_players
  ; pot = []
  ; all_players = all
  ; my_id = find_true_pos ~pos:my_pos ~ace_pos ~num_players
  }
;;

let bluff_recomendation ~game ~claim : string =
  let reccs = Call_actions.assess_calling_bluff ~game_state:game ~claim in
  let conflicting, conflicting_rec = reccs.conflicting in
  if conflicting
  then conflicting_rec
  else (
    let opp_to_win, opp_rec = reccs.almost_win in
    if opp_to_win
    then opp_rec
    else (
      let useful, use_rec = reccs.useful in
      if useful then use_rec else reccs.probability))
;;

let pot_consequences
  ~(game : Game_state.t)
  ~(who_lost : Player.t)
  ~(rest_of_pot : (int * Card.t) list)
  ~(players_not_in_pot : int list)
  ?(revealed_pot = [])
  ()
  =
  if who_lost.id = game.my_id
  then
    List.iteri (List.rev rest_of_pot) ~f:(fun index (pot_id, card) ->
      let actual_card = List.nth_exn revealed_pot index in
      match Card.equal actual_card card with
      | true -> My_cards.add_card who_lost.cards ~card
      | false ->
        let pot_player = Hashtbl.find_exn game.all_players pot_id in
        pot_player.bluffs <- pot_player.bluffs + 1;
        My_cards.add_card who_lost.cards ~card:actual_card)
  else
    List.iter rest_of_pot ~f:(fun (pot_id, card) ->
      if pot_id = game.my_id then My_cards.add_card who_lost.cards ~card);
  Game_state.clear_cards_after_showdown
    game
    ~exclude:(players_not_in_pot @ [ who_lost.id ]);
  game.pot <- []
;;

let showdown
  ~(game : Game_state.t)
  ~(acc : Player.t)
  ~(def : Player.t)
  ?(cards_revealed = [])
  ()
  =
  let num_cards_claimed, _ =
    List.fold game.pot ~init:(0, false) ~f:(fun (qty, satisfied) (id, _) ->
      if not satisfied
      then if id = def.id then qty + 1, satisfied else qty, true
      else qty, satisfied)
  in
  let players_not_in_pot =
    List.filter_map (Hashtbl.keys game.all_players) ~f:(fun id ->
      if List.exists game.pot ~f:(fun (pot_id, _) -> id = pot_id)
      then None
      else Some id)
  in
  let card_on_turn = Game_state.card_on_turn game in
  let claimed_of_pot, rest_of_pot =
    List.split_n game.pot num_cards_claimed
  in
  let revealed_cards =
    if def.id = game.my_id
    then List.map claimed_of_pot ~f:(fun (_, card) -> card)
    else cards_revealed
  in
  let who_lost =
    if List.for_all revealed_cards ~f:(fun card ->
         Card.equal card_on_turn card)
    then acc
    else def
  in
  who_lost.hand_size <- who_lost.hand_size + List.length game.pot;
  if who_lost.id = acc.id
  then (
    My_cards.restore_cards ~player:who_lost;
    List.iter revealed_cards ~f:(fun card ->
      My_cards.add_card who_lost.cards ~card))
  else (
    def.bluffs <- def.bluffs + 1;
    let cards_to_add =
      List.fold revealed_cards ~init:[] ~f:(fun to_add card ->
        let history, current = Hashtbl.find_exn who_lost.cards card in
        let difference = history - current in
        if difference > 0
        then (
          Hashtbl.set who_lost.cards ~key:card ~data:(history, current + 1);
          to_add)
        else to_add @ [ card ])
    in
    My_cards.restore_cards ~player:who_lost;
    List.iter cards_to_add ~f:(fun card_to_add ->
      My_cards.add_card who_lost.cards ~card:card_to_add));
  if who_lost.id = game.my_id
  then
    pot_consequences
      ()
      ~game
      ~who_lost
      ~rest_of_pot
      ~players_not_in_pot
      ~revealed_pot:cards_revealed
  else pot_consequences ~game ~who_lost ~rest_of_pot ~players_not_in_pot ()
;;

let my_moves game ~(num_cards : int) ~(cards_put_down : Card.t list) =
  let player = Game_state.whos_turn game in
  let cards_in_pot =
    List.map cards_put_down ~f:(fun card -> player.id, card)
  in
  game.pot <- cards_in_pot @ game.pot;
  player.hand_size <- player.hand_size - num_cards;
  List.iter cards_put_down ~f:(fun card ->
    My_cards.rm_my_card player.cards ~card ())
;;

let opp_moves game ~num_cards =
  let player = Game_state.whos_turn game in
  let card = Game_state.card_on_turn game in
  player.hand_size <- player.hand_size - num_cards;
  let added_cards = List.init num_cards ~f:(fun _ -> player.id, card) in
  game.pot <- added_cards @ game.pot;
  My_cards.update_after_move ~player ~move:(card, num_cards)
;;
