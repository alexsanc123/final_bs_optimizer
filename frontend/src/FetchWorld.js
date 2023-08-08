import React, { useState, useEffect } from 'react';

function FetchWorld() {
  const [data, setData] = useState(null);

  useEffect(() => {
    // Fetch data from an API
    fetch('http://localhost:8181/game_state')
      .then(response => response.json())
      .then(data => {  
         console.log(data);
          setData(data);
       })
      .catch(error => console.error(error));
  }, []); // Empty dependency array means the effect runs once after initial render

  return (
       data === null ? null : JSON.stringify(data)
    
  );
}

export default FetchWorld

