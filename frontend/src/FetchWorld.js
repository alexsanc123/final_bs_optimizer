import React, { useState, useEffect } from 'react';

async function FetchWorld() {
    const response = await fetch('http://localhost:8181/world_state');
    const data = await response.json();
    return data;
}

export default FetchWorld

