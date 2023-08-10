import React, { useState } from "react";
import { Redirect } from "react-router-dom";
import FetchWorld from "../FetchWorld";

console.log("InfoPage Component Opened");

function InfoPage() {
  console.log("InfoPage Function Opened");
  const [world, setWorld] = useState(null);
  if (world === null) {
    FetchWorld()
      .then((world) => {
        setWorld(world);
      })
      .catch((error) => console.log(error));
  } else {
    console.log(world);
    let current_game = world["current_game"];
    if (world["whose_turn"] === current_game["my_id"]) {
      return <Redirect to="/myturn" />;
    } else {
      return <Redirect to="/oppturn" />;
    }
  }
}
export default InfoPage;
