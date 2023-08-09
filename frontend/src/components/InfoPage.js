import React, { useState, useEffect } from "react";
import {
  Route,
  Routes,
  useNavigate,
  useHistory,
  Redirect,
} from "react-router-dom";
import FetchWorld from "../FetchWorld";

function InfoPage(BrowserRouter, world_state) {
  const [currentGame, setCurrentGame] = useState(null);
  const [playerCount, setPlayerCount] = useState(null);
  const [whoseTurn, setWhoseTurn] = useState(null);
  const [cardOnTurn, setCardOnTurn] = useState(null);
  const [roundNum, setRoundNum] = useState(null);
  const [pot, setPot] = useState(null);
  const [myId, setMyId] = useState(null);
  const [allPlayers, setAllPlayers] = useState(null);
  function fetchGameState() {
    return FetchWorld()
      .then((world) => {
        let tmpCurrentGame = world["current_game"];
        console.log("FetchWorld f");
        setCurrentGame(tmpCurrentGame);
        setPlayerCount(tmpCurrentGame["player_count"]);
        setWhoseTurn(world["whose_turn"]);
        setCardOnTurn(world["card_on_turn"]);
        setRoundNum(tmpCurrentGame["round_num"]);
        setPot(tmpCurrentGame["pot"]);
        setMyId(tmpCurrentGame["my_id"]);
        setAllPlayers(tmpCurrentGame["all_players"]);
      })
      .catch((error) => console.log(error));
  }

  useEffect(() => {
    fetchGameState();
  }, []);
  // console.log(whoseTurn);
  if ((whoseTurn === myId)) {
    return <Redirect to="/myturn" />;
  } else {
    return <Redirect to="/oppturn" />;
  }
}

export default InfoPage;
