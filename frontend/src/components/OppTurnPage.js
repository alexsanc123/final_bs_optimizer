import React, { useState, useEffect } from "react";
import { Route, Routes, useNavigate, useHistory, Redirect } from "react-router-dom";
import FetchWorld from "../FetchWorld";

function OppTurnPage(BrowserRouter, world_state) {
  const [currentGame, setCurrentGame] = useState(null);
  const [playerCount, setPlayerCount] = useState(null);
  const [whoseTurn, setWhoseTurn] = useState(null);
  const [cardOnTurn, setCardOnTurn] = useState(null);
  const [roundNum, setRoundNum] = useState(null);
  const [pot, setPot] = useState(null);
  const [myId, setMyId] = useState(null);
  const [allPlayers, setAllPlayers] = useState(null);

  function fetchGameState() {
    setInterval(() => {
      console.log("setInterval f");
      return FetchWorld()
        .then((world) => {
          console.log("FetchWorld f");
          const currentGame = world["current_game"];
          setCurrentGame(currentGame);
          setPlayerCount(currentGame["player_count"]);
          setWhoseTurn(world["whose_turn"]);
          setCardOnTurn(world["card_on_turn"]);
          setRoundNum(currentGame["round_num"]);
          setPot(currentGame["pot"]);
          setMyId(currentGame["my_id"]);
          setAllPlayers(currentGame["all_players"]);
        })
        .catch((error) => console.log(error));
    }, 100);
  }

  useEffect(() => {
    fetchGameState();
  }, []);
  // console.log(whoseTurn);
  const [numCardsPutDown, setNumCardsPutDown] = useState("");
  const [anyCalled, setAnyCalled] = useState(false);
  const [whoCalled, setWhoCalled] = useState("");
  const [recommendation, setRecommendation] = useState(
    "No Recommendation Available"
  );
  const [cardsRevealed, setCardsRevealed] = useState("");

  const [qImOn, setQImOn] = useState(1);

  const [showdown, setShowdown] = useState(false);

  function sendCountUri() {
    console.log("sendCountUri!");
    let uri =
      "http://ec2-44-208-58-34.compute-1.amazonaws.com:8181/" +
      "opponent_move?num_cards=" +
      numCardsPutDown;
    fetch(uri)
      .then(function (response) {
        return response.json();
      })
      .then((data) => {
        console.log(data);
        if (data === "Invalid arguments") {
        } else {
          setQImOn(qImOn + 1);

          console.log(data);
        }
      })
      .catch((error) => console.error(error));
  }

  function sendAnyCalledUrl() {
    console.log("sendAnyCalledUrl!");
    setQImOn(qImOn + 1);
  }
  function sendWhoCalledUrl() {
    console.log("sendWhoCalledUrl!");
    setQImOn(qImOn + 1);
  }
  function sendCardsRevealedUrl() {
    console.log("sendCardsRevealedUrl!");
    setQImOn(qImOn + 1);
  }
  function sendPotRevealedUrl() {
    console.log("sendPotRevealedUrl!");
    setQImOn(qImOn + 1);
  }

  function handleSubmit(e) {
    e.preventDefault();
    // console.log("Button Pressed!");

    if (qImOn === 1) {
      sendCountUri();
    }
    if (qImOn === 2) {
      sendAnyCalledUrl();
    }
    if (qImOn === 3) {
      sendWhoCalledUrl();
    }
    if (qImOn === 4) {
      sendCardsRevealedUrl();
    }
    if (qImOn === 5) {
      sendPotRevealedUrl();
    }
  }
  if ((whoseTurn = myId)) {
    return <Redirect to="/mymove" />;
  }
  return (
    <>
      <h1>BS Optimizer</h1>
      <div>
        <p> Game Log ... </p>

        <p>Suggested Strategy</p>

        <p>{recommendation}</p>
      </div>
      <div>
        <h2>
          It is Player {whoseTurn}'s turn to place Down A(n) {cardOnTurn}
        </h2>
      </div>

      <form onSubmit={handleSubmit}>
        <label>Please Specify How many card were placed</label>
        <input
          type="text"
          id="new-todo-input"
          onChange={(e) => setNumCardsPutDown(e.target.value)}
          className="input input__lg"
          disabled={!(qImOn === 1)}
        />
        <p />
        <label>Has Anyone Called?</label>
        <input
          type="text"
          id="new-todo-input"
          onChange={(e) => setAnyCalled(e.target.value)}
          className="input input__lg"
          disabled={!(qImOn === 2)}
        />
        <p />
        <label>Please Specify who Called?</label>
        <input
          type="text"
          id="new-todo-input"
          onChange={(e) => setWhoCalled(e.target.value)}
          className="input input__lg"
          disabled={!(qImOn === 3)}
        />
        <p />
        <label>Please Specify Cards Revealed?</label>
        <input
          type="text"
          id="new-todo-input"
          onChange={(e) => setCardsRevealed(e.target.value)}
          className="input input__lg"
          disabled={!(qImOn === 4)}
        />
        <p />
        <label>Please Specify Pot Revealed?</label>
        <input
          type="text"
          id="new-todo-input"
          onChange={(e) => setCardsRevealed(e.target.value)}
          className="input input__lg"
          disabled={!(qImOn === 5)}
        />
        <p />
        <button type="submit" className="btn btn__primary btn__lg">
          submit
        </button>
      </form>

      <div></div>
    </>
  );
}

export default OppTurnPage;
