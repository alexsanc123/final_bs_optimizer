import logo from './logo.svg';
import './App.css';
import PlayingCardsList from './PlayingCardsList';
// import TextInput from './TextInput';


function App() {

  return (
    <div><div className="App">
      <div class="card-wrapper"><h1> BS optimizer by Justin and Alex </h1></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["1"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["2"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["3"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["4"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["5"]}/></div>
      <div class="card-wrapper"><img class="card" src={PlayingCardsList["flipped"]}/></div>
    </div>
    <form className="Trivial">
      <div className="row">
        <label htmlFor='item'> New Item </label>
        <input type="text" id="item" />
      </div>
    </form>
    </div>
  );
}

export default App;
