import React, { useState, useEffect, useRef } from "react";
import { Redirect } from "react-router-dom";
import FetchWorld from "../FetchWorld";
import {
  RadioGroup,
  Radio,
  Button,
  ButtonGroup,
  Card,
  Elevation,
} from "@blueprintjs/core";

function OppTurnPage() {
  // console.log("OppTurn Function Opened");

  const [world, setWorld] = useState(null);

  const [numCardsPutDown, setNumCardsPutDown] = useState("");
  const [anyCalled, setAnyCalled] = useState("");
  const [whoCalled, setWhoCalled] = useState("");
  const [recommendation, setRecommendation] = useState(
    "No Recommendation Available"
  );
  const [cardsRevealed, setCardsRevealed] = useState("");

  const [qImOn, setQImOn] = useState(1);
  const [potRevealed, setPotRevealed] = useState(null);

  const whoCalledRef = useRef("");
  const cardsRevealedRef = useRef("");
  const potRevealedRef = useRef("");

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
    const whoseTurn = world["whose_turn"];
    const cardOnTurn = world["card_on_turn"];
    // const roundNum = currentGame["round_num"];
    // const pot = currentGame["pot"];
    const myId = currentGame["my_id"];
    // const allPlayers = currentGame["all_players"];

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
          if (resp === "Showdown") {
            setQImOn(qImOn + 1);
          }
          if (resp === "No Showdown") {
            console.log("Refresh page");
            setNumCardsPutDown("");
            setAnyCalled("");
            setQImOn(1);
            whoCalledRef.current.value = "";
            cardsRevealedRef.current.value = "";
            potRevealedRef.current.value = "";
          }
        })
        .catch((error) => console.error(error));
    }

    function sendWhoCalledAndCardsRevealed() {
      console.log("sendWhoCalledUrl!");
      let uri =
        "http://localhost:8181/" +
        "opp_showdown?caller_id=" +
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
            console.log("AACKKKKK");
            setNumCardsPutDown("");
            setAnyCalled("");
            setQImOn(1);

            whoCalledRef.current.value = "";
            cardsRevealedRef.current.value = "";
            potRevealedRef.current.value = "";
          }
        })
        .catch((error) => console.error(error));
    }

    function sendPotRevealedUrl() {
      console.log("sendPotRevealedUrl!");
      let uri = "http://localhost:8181/" + "reveal_pot?pot=" + potRevealed;
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
            setNumCardsPutDown("");
            setAnyCalled("");
            setQImOn(1);
            whoCalledRef.current.value = "";
            cardsRevealedRef.current.value = "";
            potRevealedRef.current.value = "";
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
        sendWhoCalledAndCardsRevealed();
      }
      if (qImOn === 4) {
        sendPotRevealedUrl();
      }
    }

    if (whoseTurn === myId) {
      // console.log("OppTurn Function Closed");
      return <Redirect to="/myturn" />;
    } else {
      // console.log("OppTurn Function Closed");
      return (
        <>
          <h1 className="bs">BS Optimizer</h1>
          <Card
            className="game-log"
            interactive={true}
            elevation={Elevation.TWO}
          >
            <p>Game log: </p>
            <p className="rec-txt">{world["game_log"]}</p>
            
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
              It is Player {whoseTurn}'s turn to place Down A(n) {cardOnTurn}
            </h2>
          </div>

          <form onSubmit={handleSubmit}>
            <div class="page-column">
              <div>
                <label className="text-box">
                  Please Specify How many card were placed?
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
                <label className="text-box">Has Anyone Called?</label>
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
              </div>

              <div>
                <p className="please-center">
                  <label className="text-box">Please Specify who Called?</label>
                  <input
                    type="text"
                    id="new-todo-input"
                    onChange={(e) => setWhoCalled(e.target.value)}
                    className="help"
                    ref={whoCalledRef}
                    disabled={!(qImOn === 3)}
                  />
                </p>

                <p className="please-center">
                  <label className="text-box">
                    Please Specify Cards Revealed?
                  </label>
                  <input
                    type="text"
                    id="new-todo-input"
                    onChange={(e) => setCardsRevealed(e.target.value)}
                    className="help"
                    ref={cardsRevealedRef}
                    disabled={!(qImOn === 3)}
                  />
                </p>
                <p className="please-center">
                  <label className="text-box">
                    Please Specify Pot Revealed?
                  </label>
                  <input
                    type="text"
                    id="new-todo-input"
                    onChange={(e) => setPotRevealed(e.target.value)}
                    className="help"
                    ref={potRevealedRef}
                    disabled={!(qImOn === 4)}
                  />
                </p>
              </div>
            </div>

            <div className="submit-button">
              <Button
                className="submit-button"
                intent="success"
                type="submit"
                text="Submit"
                onClick={() => console.log("got clicked!")}
              />
            </div>
          </form>

          <div></div>
        </>
      );
    }
  }
}

export default OppTurnPage;
