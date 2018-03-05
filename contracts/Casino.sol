/**
 * The Casino contract does this and that...
 */

pragma solidity 0.4.20;

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
	}
	


	
}
