let PlayingCardsList = {};
let faces = ['j', 'q', 'k'];

let addSuits = (i, PlayingCardsList) => {
	PlayingCardsList[i] = require('./CardImages/png/' + i + '.png');
}

for(let i = 1; i < 10; i++){
	addSuits(i, PlayingCardsList);
}

for(let i of faces){
	addSuits(i, PlayingCardsList);
}
			
PlayingCardsList.flipped = require('./CardImages/png/b.png');


export default PlayingCardsList;