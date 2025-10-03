SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery {
  uint256 public immutable ENTRY_FEE;

  address[] public players;

  uint256 public timestampstarted;

  uint256 public interval = 30 hours;

  error NotEnoughETHEntered();

  error Lottery__IntervalNotPassed();

  event LotteryEnter(address indexed player);

  // set the entry fee when deploying the contract
  constructor(uint256 entryFee) {
    ENTRY_FEE = entryFee;
    timestampstarted = block.timestamp;
  }

  // sign up for the lottery
  function enterLottery() public payable  {
    if (msg.value < ENTRY_FEE) {
        revert NotEnoughETHEntered();
      }
    players.push(msg.sender); 
    emit LotteryEnter(msg.sender);
  }
  // pick a random winner
  function pickLotteryWinner() public {
    if (block.timestamp - timestampstarted < interval) {
        revert Lottery__IntervalNotPassed();
    }
    
  }
  // get the entry fee
  function getEntryFee() public view returns (uint256) {
      return ENTRY_FEE;
  }

}