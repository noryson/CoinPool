pragma solidity ^0.5.0;

import "./Contribution.sol";

contract Round{
    /* 
        @Project: BSC-Master-Project
        @Authors: noryson#5495, 
        @Description: This contract keeps track of a contribution round.
    */

    uint roundNo;
    Contribution contribution;
    address[] remittedContributors;
    address[] unRemittedContributors;
    bool concluded;
    address winner;

    function constructor(Contribution hostContribution){
        contribution = hostContribution;
        roundNo = hostContribution.getRounds().len();
        unRemittedContributors = hostContribution.contributors;
        concluded = false;
    }

    /*  selectWinner() chooses a random contributor who hasn't won previously as the winner of the round.
        @pre isConcluded() == false
        @pre hasWinner() == false
        @post hasWinner() == true
        @post winner != Empty
    */
    function selectWinner(){}

    // todo: checkers
    // todo: getters and setters
}