import React, { useState } from "react";
import { Redirect } from "react-router-dom";
import { Button, NumericInput, InputGroup, Slider } from "@blueprintjs/core";

console.log("StartPage component opened");

function StartPage(BrowserRouter, world_state) {
  const [input1, setInput1] = useState(5);
  const [input2, setInput2] = useState(0);
  const [input3, setInput3] = useState(1);
  const [input4, setInput4] = useState("11246tq6735");
  const [data, setData] = useState(null);
  const [shouldISwitch, setShouldISwitch] = useState(false);

  console.log("StartPage Function Open");

  function sendGameUrl() {
    /*local hostname of comp
    curl http://169.254.169.254/latest/meta-data/public-hostname*/
    // const hostname = "ec2-44-208-58-34.compute-1.amazonaws.com;

    let uri =
      "http://localhost:8181/" +
      "create_game?num_players=" +
      input1 +
      "&my_position=" +
      input2 +
      "&ace_of_spades=" +
      input3 +
      "&hand=" +
      input4;
    console.log(uri);
    fetch(uri)
      .then(function (response) {
        return response.json();
      })
      .then((data) => {
        const resp = data["message"];
        console.log(resp);

        if (resp === "Rej") {
          console.log("BAD INPUT");
        }
        if (resp === "Ack") {
          setData(data);
          console.log(data);
          setShouldISwitch(true);
          console.log("Switch Set to True");
        }
      })
      .catch((error) => console.error(error));
  }

  // const [submitted, setSubmitted] = useState([])
  function handleSubmit(e) {
    e.preventDefault();
    console.log([input1, input2, input3, input4]);
    sendGameUrl();
  }
  console.log("StartPage Function Closed");
  if (shouldISwitch) {
    return <Redirect to="/infopage" />;
  } else {
    return (
      <div className="App">
        <h1>Game Initialization</h1>
        <form onSubmit={handleSubmit}>
          <h2>
            <label htmlFor="new-todo-input" className="label__lg">
              Please specify how many players are in the round
            </label>
          </h2>
          <div></div>
          <div className="slider">
            <Slider
              value={input1}
              min={3}
              max={10}
              labelStepSize={1}
              stepSize={1}
              onChange={(e) => {
                setInput1(e);
              }}
            />
          </div>

          <div></div>
          <h3>
            <label htmlFor="new-todo-input" className="label__lg">
              Please specify your seating index at the table clockwise from the
              0th player (the player left of dealer):
            </label>
          </h3>
          <div></div>
          <div className="slider">
            <Slider
              value={input2}
              min={0}
              max={input1-1}
              labelStepSize={1}
              stepSize={1}
              onChange={(e) => {
                console.log(e);
                setInput2(e);
              }}
            />
          </div>
          <h4>
            <label htmlFor="new-todo-input" className="label__lg">
              Please specify the seating index of the player with the Ace of
              spades (with respect to the dealer):
            </label>
          </h4>
          <div></div>
          <div className="slider">
            <Slider
              value={input3}
              min={0}
              max={input1-1}
              labelStepSize={1}
              stepSize={1}
              onChange={(e) => {
                console.log(e);
                setInput3(e);
              }}
            />
          </div>
          <div></div>
          <h5>
            <label htmlFor="new-todo-input" className="label__lg">
              Please input a sequence of the cards in your hand e.g. 123
              represents Cards 1, 2, and 3
            </label>
          </h5>
          <div></div>
          <input
            type="text"
            id="new-todo-input"
            onChange={(e) => setInput4(e.target.value)}
            className="input input__lg"
            value={input4}
          />
            <div className="submit-button">
              <Button
                intent="success"
                type="submit"
                text="Submit"
                onClick={() => console.log("got clicked!")}
              />
          </div>
        </form>
      </div>
    );
  }
}

console.log("StartPage Component Closed");

export default StartPage;
