/**
 * The Casino contract does this and that...
 */

pragma solidity 0.4.19;

contract Casino {

	address public owner;
	uint256 public minimumBet;
	uint256 public totalBet;
	uint256 public numberOfBets;
	uint256 public maxAmountOfBets = 100;

	address [] public players;

	struct Player {
		uint256 amountBet;
		uint256 numberSelected;
	}
	
	mapping (address => Player) public playerInfo;	

	//Constuctor is executed only once during the deployment
	function Casino (uint256 _minimumBet) {
		owner = msg.sender;
		if(_minimumBet!=0) {
			minimumBet = _minimumBet;
		}
	}	

	//fallback function
	function() public payable {}


	function getBalance() public returns(uint) {
		return this.balance;
	}

	function resetData(){
	   players.length = 0; // Delete all the players array
	   totalBet = 0; 
	   numberOfBets = 0;
	}
	
	//I’m invoking a function called checkPlayerExists() to check that the user has not played
	// already because we only want that each person only plays once per game.
	function checkPlayerExists (address player) public constant returns(bool) {
		for(uint256 i = 0; i < players.length; i++){
			if(players[i] == player) return true;
		}
		return false;
	}
	


	/*
		The function kill() is used to destroy the contract whenever you want.
		Of course only the owner can kill it. The remaining ether that the 
		contract has stored will be sent to the owner’s address. Only use it if
		the contract is compromised by some hack and you can’t secure it.

	*/
	function kill () public {
		if(msg.sender == owner) {
			selfdestruct(owner);
		}
	}

	function bet (uint256 numberSelected) public payable{
		require(!checkPlayerExists(msg.sender));
		require(numberSelected >= 1 && numberSelected <= 10);
		require(msg.value >= minimumBet);

		playerInfo[msg.sender].amountBet = msg.value;
		playerInfo[msg.sender].numberSelected = numberSelected;

		numberOfBets++;
		players.push(msg.sender);
		totalBet += msg.value;

		if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
	}
	/*
		It takes the current block number and gets the last number + 1 so if the block 
		number is 128142 the number generated will be 128142 % 10 = 2 and 2 +1 = 3.
		This isn’t secure because it’s easy to know what number will be the winner depending on the conditions.
		The miners can decide see the block number for their own benefit.
	*/
	function generateNumberWinner () public{
		uint256 numberGenerated = block.number % 10 + 1; //This isn't secure at all
		distributePrizes(numberGenerated);	
	}
	
	function distributePrizes (uint256 numberWinner) public {
		address[100] memory winners; // We have to create a temporary in memory array with fixed size
		uint256 count = 0; 


		for(uint256 i = 0; i < players.length; i++){
			address playerAddress = players[i];
			if(playerInfo[playerAddress].numberSelected == numberWinner){
				winners[count] = playerAddress;
				count++;
			}
			delete playerInfo[playerAddress]; // Delete all the players
		}

		players.length = 0; //delete all the players in the array

        uint256 winnerEtherAmount = totalBet / winners.length; // How much each winner gets

        for(uint256 j = 0; j < count; j++){
         	if(winners[j] != address(0)){ // Check that the address in this fixed array is not empty
         		winners[j].transfer(winnerEtherAmount);
         	}
        }
    }

	
	

	
}
