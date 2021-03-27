pragma solidity ^0.5.0;

import "./Round.sol";

contract Contribution{
    /* 
        @Project: BSC-Master-Project
        @Authors: noryson#5495, 
        @Description: This contract keeps track of all contribution events in the system
    */

    uint id;  // unique Identification for each contribution event.
    address host;  // Contribution's creator address. Is this neccesary though?
    uint maxNoOfMembers;
    uint256 startDate;  // gotten by adding contribution's creation date timestamp and duration
    Round[] rounds;
    uint roundDuration;  // measured in days
    address[] contributors;
    bool concluded;  // tracks the event state
    mapping(address => amount) auctionedAsset;

    /*  @invariants: assets supported are BNB, Ether and Cryptonite */
    string asset;
    uint contributionAmount;

    /*  @invariants: assets supported are BNB, Ether and Cryptonite
        @invariants: stakedAsset != asset
    */ 
    string stakedAsset;
    uint stakedAmount;

    function constructor(string assetName, uint amount, string stake, uint stakeValue, uint max, uint duration, uint waitPeriod){
        require(assetName == "bnb" | assetName == "ether" | assetName == "crypt");
        id = 1;  // todo: generate random data
        host = msg.sender;
        maxNoOfMembers = max;
        startDate = 12312;  // todo: currentDate + waitPeriod
        contributors.push(host);
        contributionAmount = amount;
        asset = assetName;
        stakedAsset = stake;
        stakedAmount = stakeValue;
        roundDuration = duration;
        concluded = false;
    }
    
    /*  addContributor() 
        @pre isConcluded == false;
        @pre contributors !contains newContributor
        @pre len(contributors) < maxNoOfMembers;
        @post contributors contains newContributor
    */
    function addContributor(address newContributor){}

    /*  stake() transfers staked asset from msg.sender to contract before msg.sender is added as contributor.
        @pre contributors !contain msg.sender
        @post contributer contain msg.sender
    */
    function stake(){}
    
    /*  payIn() transfers to choosen contribution asset from the user into the contract.
        @pre isConcluded == false;
        @pre getCurrentRound().hasUserPayed() == false
        @pre amount == contributionAmount
        @post getCurrentRound().remmittedUsers contain msg.sender
    */
    function payIn(uint amount){}
    
    /*  payRound() selects winner in the current round, transfers asset to them and concludes the current round.
        @pre getCurrentRound().isConcluded == false
        @post getCurrentRound().isConcluded ==  true
    */
    function payRound(){}

    /*  nextRound() creates a new round object and updates the Contribution.
        @post getCurrentRound() == new Round()
    */
    function nextRound(){}

    /*  auctionAsset() sells part of a defaulters stake so payOuts will be complete
        @pre getCurrentRound() !contain defaulter
        @post getCurrentRound() !contain defaulter
        @post actionedAsset[defaulter] += actionAmount
    */
    function auctionAsset(address defaulter){}
    
    /*  conclude() checks if all rounds have been concluded, returns staked assets and concludes the contribution
        @pre isConcluded() == false
        @pre rounds[len(rounds)].isConcluded() = true
        @post isConcluded() == true
    */
    function conclude(){}
    
    // todo: checkers
    function isConclued() returns(bool){}

    // todo: getters and setters

}