import { Redirect } from "react-router-dom";
import PlayingCardsList from "./PlayingCardsList";
import React, { useState, useEffect, useRef } from "react";
import FetchWorld from "../FetchWorld";
import {
  RadioGroup,
  Radio,
  Button,
  ButtonGroup,
  Card,
  Elevation,
} from "@blueprintjs/core";

function renderImg(card) {
  return <img class="card" src={PlayingCardsList[card]} />;
}

function renderCard(card) {
  const m = {
    Ace: "1c",
    Two: "2h",
    Three: "3s",
    Four: "4d",
    Five: "5c",
    Six: "6h",
    Seven: "7s",
    Eight: "8d",
    Nine: "9c",
    Ten: "10h",
    Jack: "js",
    Queen: "qd",
    King: "kh",
  };

  return renderImg(m[card]);
}

function renderCards(cards) {
  const renderedCards = cards.map(card => renderCard(card));
  return <div style={{display: 'flex', width: "100%", justifyContent:'center', alignItems: 'center', gap:"1rem"}}>{renderedCards}</div>
}



function MyTurnPage() {
  // console.log("OppTurn Function Opened");

  const [world, setWorld] = useState(null);

  const [numCardsPutDown, setNumCardsPutDown] = useState("");
  const [anyCalled, setAnyCalled] = useState(false);
  const [whoCalled, setWhoCalled] = useState("");
  const [recommendation, setRecommendation] = useState(
    "No Recommendation Available"
  );
  const [cardsPutDown, setCardsPutDown] = useState("");
  const [cardsRevealed, setCardsRevealed] = useState("");

  const [qImOn, setQImOn] = useState(1);
  const [potRevealed, setPotRevealed] = useState(null);
  const [showdownWon, setShowDownWon] = useState(true);

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
    // const playerCount = currentGame["player_count"];
    const strategy = world["strategy"].map(
      ([cardToProvide, ...cardsRecommended]) =>
        cardToProvide + " turn: [" + cardsRecommended + "];   "
    );
    const whoseTurn = world["whose_turn"];
    const cardOnTurn = world["card_on_turn"];
    const cardsToUse = world["cards_to_use"];
    const qtyCardsToUse = cardsToUse.length;
    console.log(qtyCardsToUse);
    
    // const roundNum = currentGame["round_num"];
    // const pot = currentGame["pot"];
    const myId = currentGame["my_id"];
    // const allPlayers = currentGame["all_players"];

    function sendCountAndCardsPutDownUri() {
      let uri =
        "http://localhost:8181/" +
        "my_move?num_cards=" +
        numCardsPutDown +
        "&cards_put_down=" +
        cardsPutDown;
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
            setRecommendation(resp);
            setQImOn(qImOn + 1);
          }
        })
        .catch((error) => console.error(error));
    }

    function sendAnyCalledUrl() {
      console.log("sendAnyCalledUrl!");
      let uri =
        "http://localhost:8181/" + "check_bluff?bluff_called=" + anyCalled;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          if (resp === "Showdown Won") {
            setShowDownWon(true);
            setQImOn(qImOn + 1);
          }
          if (resp === "Showdown Lost") {
            setShowDownWon(false);
            setQImOn(qImOn + 1);
          }
          if (resp === "No Showdown") {
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

    function sendWhoCalled() {
      console.log("sendWhoCalledUrl!");
      let uri =
        "http://localhost:8181/" +
        "my_showdown?caller_id=" +
        whoCalled +
        "&cards_revealed=" +
        cardsRevealed;
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
          if (resp === "Reveal Pot") {
            setQImOn(qImOn + 1);
          }
          if (resp === "Next Turn") {
            setQImOn(1);
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
          }
        })
        .catch((error) => console.error(error));
    }

    function sendCallerIdUrl() {
      console.log("sendPotRevealedUrl!");
      let uri =
        "http://localhost:8181/" + "my_showdown_won?caller_id=" + whoCalled;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          if (resp === "Rej") {
          }
          if (resp == "Ack") {
            setQImOn(1);
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
            setShowDownWon(false);
          }
        })
        .catch((error) => console.error(error));
    }

    function sendCallerIdAndPotRevealedUrl() {
      console.log("sendPotRevealedUrl!");
      let uri =
        "http://localhost:8181/" +
        "my_showdown_lost?caller_id=" +
        whoCalled +
        "&pot=" +
        potRevealed;
      fetch(uri)
        .then(function (response) {
          return response.json();
        })
        .then((data) => {
          const resp = data["message"];
          console.log(resp);
          if (resp === "Rej") {
          }
          if (resp == "Ack") {
            setQImOn(5);
            setNumCardsPutDown("");
            setAnyCalled("");
            setWhoCalled("");
            setRecommendation("No Recommendation Available");
            setShowDownWon(false);
          }
        })
        .catch((error) => console.error(error));
    }

    function handleSubmit(e) {
      e.preventDefault();
      // console.log("Button Pressed!");

      if (qImOn === 1) {
        sendCountAndCardsPutDownUri();
      }
      if (qImOn === 2) {
        sendAnyCalledUrl();
      }
      if (qImOn === 3) {
        if (showdownWon) {
          sendCallerIdUrl();
        } else {
          sendCallerIdAndPotRevealedUrl();
        }
      }
    }
    if (whoseTurn !== myId) {
      // console.log("OppTurn Function Closed");
      return <Redirect to="/oppturn" />;
    } else {
      // console.log("OppTurn Function Closed");
      return (
        <>
          <head>
            <link
              href="path/to/node_modules/@blueprintjs/icons/lib/css/blueprint-icons.css"
              rel="stylesheet"
            />
            <title >BS Optimizer</title>
            <link rel="stylesheet" href="App.css"></link>
          </head>
          <h1 className="bs">BS Optimizer</h1>
          <Card
            className="game-log"
            interactive={true}
            elevation={Elevation.TWO}
          >
            {world["game_log"]}
          </Card>
          <Card
            className="rec-log"
            interactive={true}
            elevation={Elevation.TWO}
          >
            <p>Recommendation: </p>
            <p className="rec-txt">{recommendation}</p>
          </Card>
          <div>
            <h2>
              It is Player {whoseTurn}'s turn to place down a(n) {cardOnTurn}
            </h2>
          </div>
          <div className="App">
            <div>
            <p className="text-box"> Game Log ... </p>
          </div>
          <div>
          <p className="text-box">It's our turn to place down a(n) {cardOnTurn}</p>
            <div>{renderCard(cardOnTurn[0])}</div>
          </div>
          <div>
          <p className="text-box">Recommended cards to use: </p>
           <div>
            {renderCards(cardsToUse)}</div> 
          </div>

            <form onSubmit={handleSubmit}>
              <div class="page-column">
                <div>
                  <label className="text-box">
                    Please specify how many cards we placed:{" "}
                  </label>
                  <div
                    // onChange={(e) => setNumCardsPutDown(e.target.value)}
                    className="button-row"
                  >
                    <Button
                      intent="success"
                      text="1"
                      value="1"
                      onClick={(e) =>
                        qImOn === 1 ? setNumCardsPutDown(e.target.value) : {}
                      }
                      active={numCardsPutDown === "1"}
                      disabled={!(qImOn === 1) && !(numCardsPutDown == 1)}
                    />
                    <Button
                      intent="success"
                      text="2"
                      value="2"
                      onClick={(e) =>
                        qImOn === 1 ? setNumCardsPutDown(e.target.value) : {}
                      }
                      active={numCardsPutDown === "2"}
                      disabled={!(qImOn === 1) && !(numCardsPutDown == 2)}
                    />
                    <Button
                      intent="success"
                      text="3"
                      value="3"
                      onClick={(e) =>
                        qImOn === 1 ? setNumCardsPutDown(e.target.value) : {}
                      }
                      active={numCardsPutDown === "3"}
                      disabled={!(qImOn === 1) && !(numCardsPutDown == 3)}
                    />
                    <Button
                      intent="success"
                      text="4"
                      value="4"
                      onClick={(e) =>
                        qImOn === 1 ? setNumCardsPutDown(e.target.value) : {}
                      }
                      active={numCardsPutDown === "4"}
                      disabled={!(qImOn === 1) && !(numCardsPutDown == 4)}
                    />
                  </div>

                  <h2 />
                  <label className="text-box">
                    Please specify what cards we placed:{" "}
                  </label>
                  <input
                    type="text"
                    id="new-todo-input"
                    onChange={(e) => setCardsPutDown(e.target.value)}
                    className="input input__lg"
                    disabled={!(qImOn === 1)}
                  />
                  <h2 />
                </div>
                <div>
                  <label className="text-box">Has anyone called?</label>
                  <div
                    // onChange={(e) => setNumCardsPutDown(e.target.value)}
                    className="button-row"
                  >
                    <Button
                      intent="success"
                      text="true"
                      value="true"
                      onClick={(e) =>
                        qImOn === 2 ? setAnyCalled(e.target.value) : {}
                      }
                      active={anyCalled === "true"}
                      disabled={!(qImOn === 2) && !(anyCalled == "true")}
                    />
                    <Button
                      intent="success"
                      text="false"
                      value="false"
                      onClick={(e) =>
                        qImOn === 2 ? setAnyCalled(e.target.value) : {}
                      }
                      active={anyCalled === "false"}
                      disabled={!(qImOn === 2) && !(anyCalled == "false")}
                    />
                  </div>
                  <label className="text-box">
                    Please specify the ID of the player who called:
                  </label>
                  <input
                    type="text"
                    id="new-todo-input"
                    onChange={(e) => setWhoCalled(e.target.value)}
                    className="input input__lg"
                    disabled={!(qImOn === 3)}
                  />
                  <h2 />
                  <label className="text-box">
                    Please specify the cards revealed in the pot you recovered:
                  </label>
                  <input
                    type="text"
                    id="new-todo-input"
                    onChange={(e) => setPotRevealed(e.target.value)}
                    className="input input__lg"
                    disabled={!(qImOn === 3 && !showdownWon)}
                  />
                </div>
              </div>
              <p></p>
              <p></p>
              <p></p>
              <div></div>
              <div></div>

              <div className="submit-button">
                <Button
                  className="submit-button"
                  intent="success"
                  type="submit"
                  text="Submit"
                  onClick={() => console.log("got clicked!")}
                />
              </div>

              <p className="strat">Suggested Strategy: {strategy}</p>
            </form>
          </div>
        </>
      );
    }
  }
}

export default MyTurnPage;
