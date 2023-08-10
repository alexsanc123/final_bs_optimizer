import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import reportWebVitals from "./reportWebVitals";

console.log("IndexJS Open");
const root = ReactDOM.createRoot(document.getElementById("root"));
// React.Strict Mode Caused my App.Js to be called twice
// root.render(
//   <React.StrictMode>
//     <TestPage />
//     <App />
//   </React.StrictMode>
// );
root.render(<App />);
console.log("IndexJs -> WebVitals AKA IndexJs component closed");
// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
