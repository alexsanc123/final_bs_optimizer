import logo from './logo.svg';
import './App.css';
import PlayingCardsList from './PlayingCardsList';


function App() {

  let ranks = ["A"]

  return (
    <div><div className="App">
      <div class="card-wrapper"><h1> BS optimizer by Justin and Alex </h1></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["1"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["2"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["3"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["4"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["5"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["flipped"]}/></div>
    </div></div>
  );
}

export default App;
