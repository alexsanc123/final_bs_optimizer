// console.log("FetchWorld Component Opened");

async function FetchWorld() {
  // console.log("FetchWorld Function Opened");
  const response = await fetch("http://localhost:8181/world_state");
  const data = await response.json();
  // console.log("FetchWorld Function Closed");

  return data;
}
// console.log("FetchWorld Component Closed");

export default FetchWorld;
