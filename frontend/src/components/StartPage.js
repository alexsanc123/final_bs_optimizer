import React, { useState} from "react";
import {

  Redirect,
} from "react-router-dom";
console.log("StartPage component opened")

function StartPage(BrowserRouter, world_state) {
  const [input1, setInput1] = useState("5");
  const [input2, setInput2] = useState("2");
  const [input3, setInput3] = useState("1");
  const [input4, setInput4] = useState("123456789t");
  const [data, setData] = useState(null);
  const [shouldISwitch, setShouldISwitch] = useState(false);

  console.log("StartPage Function Open")

  function sendGameUrl() {
    /*local hostname of comp
    curl http://169.254.169.254/latest/meta-data/public-hostname*/
    // const hostname = "ec2-44-208-58-34.compute-1.amazonaws.com;

    let uri =
      "http://" +
      "localhost"
      + ":8181/" +
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
        const ack = data["message"];
        console.log(ack);

        if (ack === "Invalid arguments") {
          console.log("BAD INPUT");
          setInput1("");
          setInput2("");
          setInput3("");
          setInput4("");
        }
        if (ack === "Game created") {
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
      <>
        <h1>Game Initialization</h1>
        <form onSubmit={handleSubmit}>
          <label htmlFor="new-todo-input" className="label__lg">
            Please specify how many players are in the round
          </label>
          <div></div>
          <input
            type="text"
            id="new-todo-input"
            onChange={(e) => setInput1(e.target.value)}
            className="input input__lg"
            value = {input1}
          />
          <div></div>
          <label htmlFor="new-todo-input" className="label__lg">
            Please specify your seating index at the table clockwise from the
            0th player (the player left of dealer):
          </label>
          <div></div>
          <input
            type="text"
            id="new-todo-input"
            onChange={(e) => setInput2(e.target.value)}
            className="input input__lg"
            value={input2}
          />
          <div></div>
          <label htmlFor="new-todo-input" className="label__lg">
            Please specify the seating index of the player with the Ace of
            spades (with respect to the dealer):
          </label>
          <div></div>
          <input
            type="text"
            id="new-todo-input"
            onChange={(e) => setInput3(e.target.value)}
            className="input input__lg"
            value={input3}
          />
          <div></div>
          <label htmlFor="new-todo-input" className="label__lg">
            Please input a sequence of the cards in your hand e.g. 123
            represents Cards 1, 2, and 3
          </label>
          <div></div>
          <input
            type="text"
            id="new-todo-input"
            onChange={(e) => setInput4(e.target.value)}
            className="input input__lg"
            value={input4}
          />
          <div>
            <button type="submit" className="btn btn__primary btn__lg">
              submit
            </button>
          </div>
        </form>
      </>
    );
  }
}

console.log("StartPage Component Closed")

export default StartPage;
