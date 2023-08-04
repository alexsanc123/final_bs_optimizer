import logo from './logo.svg';
import './App.css';
import Card from 'react-playing-card'


function App() {

  let ranks = ["A"]

  return (
    <div className="App">
      <h1> BS optimizer by Justin and Alex </h1>
      <Card rank="A" suit="S"/>
    </div>
  );
}

export default App;
