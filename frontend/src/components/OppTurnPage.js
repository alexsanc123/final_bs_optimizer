import React, { useState, useEffect } from "react";
import { Redirect } from "react-router-dom";
import FetchWorld from "../FetchWorld";

function OppTurnPage() {
  console.log("OppTurn Function Opened");

  const [world, setWorld] = useState(null);

  const [numCardsPutDown, setNumCardsPutDown] = useState("");
  const [anyCalled, setAnyCalled] = useState(false);
  const [whoCalled, setWhoCalled] = useState("");
  const [recommendation, setRecommendation] = useState(
    "No Recommendation Available"
  );
  const [cardsRevealed, setCardsRevealed] = useState("");

  const [qImOn, setQImOn] = useState(1);
  const [potRevealed, setPotRevealed] = useState(null);

  const [showdown, setShowdown] = useState(false);
  FetchWorld()
    .then((newWorld) => {
      if (newWorld === world) {
      } else {
        setWorld(newWorld);
      }
    })
    .catch((error) => console.log(error));

  if (world === null) {
    return (
      <div>
        <h1> Loading Page ...</h1>
      </div>
    );
  } else {
    const currentGame = world["current_game"];
    const playerCount = currentGame["player_count"];
    const whoseTurn = world["whose_turn"];
    const cardOnTurn = world["card_on_turn"];
    const roundNum = currentGame["round_num"];
    const pot = currentGame["pot"];
    const myId = currentGame["my_id"];
    const allPlayers = currentGame["all_players"];

    function sendCountUri() {
      
      let uri =
        "http://localhost:8181/" + "opponent_move?num_cards=" + numCardsPutDown;
      fetch(uri)
        .then(function (response) {
          console.log("sendCountUri!");
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          if (resp === "Rej") {
          } else {
            setQImOn(qImOn + 1);
          }
        })
        .catch((error) => console.error(error));
    }

    function sendAnyCalledUrl() {
      console.log("sendAnyCalledUrl!");
      let uri = "http://localhost:8181/" + "any_calls?any_calls=" + anyCalled;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          if (resp === "Rej") {
          }
          if (resp === "Ack") {
            setQImOn(qImOn + 1);
          } else {
            console.log("Refresh page");
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
            setQImOn(1);
          }
        })
        .catch((error) => console.error(error));
    }

    function sendWhoCalledUrl() {
      console.log("sendWhoCalledUrl!");
      let uri = "http://localhost:8181/" + "who_called?who_called=" + whoCalled;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          // fix
          if (resp === "Rej") {
          }
          if (resp === "Ack") {
            setQImOn(qImOn + 1);
          } else {
            setQImOn(1);
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
          }
        })
        .catch((error) => console.error(error));
    }

    function sendCardsRevealedUrl() {
      console.log("sendCardsRevealedUrl!");
      let uri =
        "http://localhost:8181/" + "cards_revealed?cards=" + cardsRevealed;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          // fix
          if (resp === "Rej") {
          }
          if (resp === "Ack") {
            setQImOn(qImOn + 1);
          } else {
            setQImOn(1);
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
          }
        })
        .catch((error) => console.error(error));
    }

    function sendPotRevealedUrl() {
      console.log("sendPotRevealedUrl!");
      let uri = "http://localhost:8181/" + "pot_revealed?pot=" + potRevealed;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          if (resp === "Rej") {
          } else {
            setQImOn(1);
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
          }
        })
        .catch((error) => console.error(error));
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
        sendCardsRevealedUrl();

      }
      if (qImOn === 4) {
        sendPotRevealedUrl();
      }
    }

    if (whoseTurn === myId) {
      console.log("OppTurn Function Closed");
      return <Redirect to="/myturn" />;
    } else {
      console.log("OppTurn Function Closed");
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
              disabled={!(qImOn === 3)}
            />
            <p />
            <label>Please Specify Pot Revealed?</label>
            <input
              type="text"
              id="new-todo-input"
              onChange={(e) => setCardsRevealed(e.target.value)}
              className="input input__lg"
              disabled={!(qImOn === 4)}
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
  }
}

export default OppTurnPage;
