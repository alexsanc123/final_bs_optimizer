import React, { useState, useEffect } from "react";
import {
  Route,
  Routes,
  useNavigate,
  useHistory,
  Redirect,
} from "react-router-dom";

function StartPage(BrowserRouter, world_state) {
  const [input1, setInput1] = useState("");
  const [input2, setInput2] = useState("");
  const [input3, setInput3] = useState("");
  const [input4, setInput4] = useState("");
  const [data, setData] = useState(null);
  const [shouldISwitch, setShouldISwitch] = useState(false);

  function sendGameUrl() {
    /*local hostname of comp*/
    let uri =
      "http://ec2-44-208-58-34.compute-1.amazonaws.com:8181/" +
      "create_game?num_players=" +
      input1 +
      "&my_position=" +
      input2 +
      "&ace_of_spades=" +
      input3 +
      "&hand=" +
      input4;
    fetch(uri)
      .then(function (response) {        
        return response.json();
      })
      .then((data) => {
        const ack = data["message"];
        console.log(ack);

        if (ack === "Invalid fg vdcxarguments") {
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
export default StartPage;
