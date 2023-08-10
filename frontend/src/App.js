import "./App.css";
import StartPage from "./components/StartPage";
import MyTurnPage from "./components/MyTurnPage";
import OppTurnPage from "./components/OppTurnPage";
import {
  BrowserRouter as Router,
  Route,
  Switch,
  Redirect,
} from "react-router-dom";
import InfoPage from "./components/InfoPage";


console.log("App Component Opened")
function App() {
  console.log("App Function Opened")
  console.log("App Function Closed")
  return (
    <Router>
      <Switch>
        <Route path="/" exact component={StartPage} />
        <Route path="/infopage" component={InfoPage} />
        <Route path="/myturn" component={MyTurnPage} />
        <Route path="/oppturn" component={OppTurnPage} />
        <Redirect to="/infopage" />
      </Switch>
    </Router>
  );
}
console.log("App Component Closed")
export default App;
