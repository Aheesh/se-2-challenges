// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;
	mapping(address => uint256) public balances;
	uint256 public constant threshold = 1 ether; //1000000000000000000; // 1 ETH
	bool public openForWithdraw = false;
	uint256 public deadline = block.timestamp + 72 hours; // 3 days
	event Stake(address indexed staker, uint256 amount);

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	//function modifier called notCompleted.
	// It will check that ExampleExternalContract is not completed yet.
	// Use it to protect your execute and withdraw functions.
	modifier notCompleted() {
		require(
			exampleExternalContract.completed() == false,
			"Contract is already completed"
		);
		_;
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

	function stake() public payable {
		balances[msg.sender] += msg.value;
		console.log("Staked: %s", msg.value);
		console.log("Total Staked: %s", address(this).balance);
		emit Stake(msg.sender, msg.value);
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

	function execute() public notCompleted {
		require(block.timestamp >= deadline, "Deadline has not passed");
		if (address(this).balance >= threshold) {
			console.log(
				"Threshold met, calling complete: %s",
				address(this).balance
			);

			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			openForWithdraw = true;
			console.log("Open for withdraw set to true", openForWithdraw);
		}
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

	function withdraw() public notCompleted {
		require(openForWithdraw == true, "Withdraw is not open");
		uint256 amount = balances[msg.sender];
		balances[msg.sender] = 0;
		console.log("Withdrawing: %s", amount);
		payable(msg.sender).transfer(amount);
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		} else {
			return deadline - block.timestamp;
		}
	}

	// Add the `receive()` special function that receives eth and calls stake()
	receive() external payable {
		stake();
	}
}
