import './App.css';
import React, { useState, useEffect } from 'react';
import FetchWorld from './FetchWorld';
import StartPage from './components/StartPage';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import InfoPage from './components/InfoPage';
// import ContactPage from './components/ContactPage';

function App() {
 let world = FetchWorld();
  return (
    <Router>
      <Switch>
        <Route path="/" exact component={StartPage} />
        <Route path="/infopage" component={InfoPage} />
      </Switch>
    </Router>
  );
};

export default App
