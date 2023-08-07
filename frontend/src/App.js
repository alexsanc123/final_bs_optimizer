import logo from './logo.svg';
import './App.css';
import Card from 'react-playing-card'


function App() {

  let ranks = ["A"]

  return (
    <div className="App">
      <h1> BS optimizer</h1>
      <Card rank="A" suit="S"/>
      <Card rank="10" suit="C"/>
      <Card rank="7" suit="H"/>
      <Card rank="9" suit="D"/>
      </div>
  );
}

export default App;
