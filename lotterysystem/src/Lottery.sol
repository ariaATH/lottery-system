SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery  is VRFConsumerBaseV2 {

  uint256 private immutable ENTRY_FEE;

  address[] private payable players;

  uint256 private timestampstarted;

  uint256 private immutable interval; 

  VRFCoordinatorV2Interface private immutable vrfCoordinator;

  uint256 private immutable keyHash ;

  uint64 private immutable s_subscriptionId ;

  uint256 private immutable callbackGasLimit ;

  uint16 private immutable requestConfirmations;

  uint32 private immutable numWords ;

  error NotEnoughETHEntered();

  error Lottery__IntervalNotPassed();

  event LotteryEnter(address indexed player);

  // set the entry fee when deploying the contract
  constructor(uint256 entryFee , uint256 i_interval , uint256 keyHash , uint64 subscriptionId , uint256 gasLimit , uint16 confirmations , uint32 numberwords) VRFConsumerBaseV2(address vrfCoordinator) {
    keyHash = keyHash;
    s_subscriptionId = subscriptionId;
    callbackGasLimit = gasLimit;
    requestConfirmations = confirmations;
    numWords = numberwords;
    ENTRY_FEE = entryFee;
    interval = i_interval;
    vrfCoordinator = VRFCoordinatorV2Interface(address vrfCoordinator);
    timestampstarted = block.timestamp;
  }

  // sign up for the lottery
  function enterLottery() external payable  {
    if (msg.value < ENTRY_FEE) {
        revert NotEnoughETHEntered();
      }
    players.push(msg.sender); 
    emit LotteryEnter(msg.sender);
  }
  // pick a random winner
  function pickLotteryWinner() external {
    if (block.timestamp - timestampstarted < interval) {
        revert Lottery__IntervalNotPassed();
    }
    
  }
  // get the entry fee
  function getEntryFee() public view returns (uint256) {
      return ENTRY_FEE;
  }

  function requestRandomWords() external {
    // Will revert if subscription is not set and funded.
    vrfCoordinator.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  function fuldillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    address payable recentWinner = players[randomWords[0] % players.length];
    recentWinner.transfer(address(this).balance);
    players = new address[](0);
    timestampstarted = block.timestamp;
  }

}