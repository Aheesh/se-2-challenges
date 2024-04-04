// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";

contract ExampleExternalContract {
	bool public completed;

	function complete() public payable {
		completed = true;
		console.log("Completed called %s", completed);
	}
}
