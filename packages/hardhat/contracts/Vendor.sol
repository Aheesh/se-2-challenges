pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfEth,
		uint256 amountOfTokens
	);

	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// Create a payable buyTokens() function:
	function buyTokens() public payable {
		uint256 tokensPerEth = 100;
		yourToken.transfer(msg.sender, msg.value * tokensPerEth);
		emit BuyTokens(msg.sender, msg.value, msg.value * tokensPerEth);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) public {
		uint256 tokensPerEth = 100;
		require(
			yourToken.balanceOf(msg.sender) >= _amount,
			"Not enough tokens"
		);
		yourToken.transferFrom(msg.sender, address(this), _amount);
		payable(msg.sender).transfer(_amount / tokensPerEth);
		emit SellTokens(msg.sender, _amount / tokensPerEth, _amount);
	}
}
