let PlayingCardsList = {};
let cards = ['a', '2', '3', '4', '5', '6', '7', '8', '9', 't', 'j', 'q', 'k']

let addSuits = (i, PlayingCardsList) => {
	PlayingCardsList[i] = require('./CardImages/png/' + i + '.png');
}

for(let i of cards){
	addSuits(i, PlayingCardsList);
}
			
PlayingCardsList.flipped = require('./CardImages/png/b.png');


export default PlayingCardsList;