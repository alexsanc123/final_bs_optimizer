import "./App.css";
import React, { useState, useEffect } from "react";
import FetchWorld from "./FetchWorld";
import StartPage from "./components/StartPage";
import MyTurnPage from "./components/MyTurnPage";
import {
  BrowserRouter as Router,
  Route,
  Switch,
  Redirect,
} from "react-router-dom";
import InfoPage from "./components/InfoPage";
import { BrowserRouter } from "react-router-dom/cjs/react-router-dom.min";
// import ContactPage from './components/ContactPage';

function App() {
  let world = FetchWorld();
  return (
    <Router>
      <Switch>
        <Route path="/" exact component={StartPage} />
        <Route path="/infopage" component={InfoPage} />
        <Route path="/myturn" component={MyTurnPage} />
        <Route path="/oppturn" component={InfoPage} />
        <Redirect to="/" />
      </Switch>
    </Router>
  );
}

export default App;
