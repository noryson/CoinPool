// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "./Pool.sol";
import "./Utils.sol";

contract Member {
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum MemberStatus{initialising,readytoverify,readytorun,running,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    address private account;  // The "user id" of of the member that joined this pool.
    
    // Pool private parentPool;

    // Pool_Utils.CryptoAssetWithAddress private contributionAsset;
    // Pool_Utils.CryptoAssetWithAddress private stakingAsset;
    // // Pool_Utils.CryptoAssetWithAddress private payoutAsset;

    MemberStatus memberStatus; // (initialising,readytoverify,readytorun, running,concluded)  
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            memberStatus == MemberStatus.initialising,
            "This task can only be done while Initialising this Pool Member."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenReadyToVerfyMember() {
        require(
            memberStatus == MemberStatus.readytoverify,
            "This task can only be done when verifing this Pool Member."
        );
        _;
    } // onlyWhenAddingMembers()

    modifier onlyWhenPoolMemberIsReadyToRun() {
        require(
            memberStatus == MemberStatus.readytorun,
            "This task can only be done when this Pool Member is Ready to participate in the Pool."
        );
        _;
    } // onlyWhenPoolMemberIsReadyToRun()

    modifier onlyWhenThePoolIsRunning() {
        require(
            memberStatus == MemberStatus.running,
            "This task can only be done while the Pool Member is an active part of the Pool."
        );
        _;
    } // onlyWhenPoolMemberIsReadyToRun()

    modifier onlyWhenThePoolHasConculded() {
        require(
            memberStatus == MemberStatus.concluded,
            "This task can only be done after the pool has been concluded for this Member."
        );
        _;
    } // onlyWhenThePoolHasConculded()
    // ----------------------------------
    // Functions
    // ----------------------------------
    constructor(address _account) {
      account = _account;

      // set defaults
    //   string memory _AssetName;
    //   uint _AssetAmount;

    //   (_AssetName, _AssetAmount) = parentPool.getRequirement_forContributionAsset();
    //   contributionAsset.Asset.Name = _AssetName;
    //   contributionAsset.Asset.Amount = _AssetAmount;

    //   (_AssetName, _AssetAmount) = parentPool.getRequirement_forStakingAsset();
    //   stakingAsset.Asset.Name = _AssetName;
    //   stakingAsset.Asset.Amount = _AssetAmount;   

      // Asset name to be use by the member for payouts 
      // (bnb,ether,crypt)
    //   payoutAsset.Asset.Name = contributionAsset.Asset.Name; 
    //   payoutAsset.Asset.Amount = 0;   // payout amount.

    //   memberStatus = MemberStatus.initialising;

    } // constructor()

    //----------------------------------
    // Helper Functions
    //----------------------------------
    // function getMemberStatus_asString() private view 
    //   returns(string memory _memberStatusText) {

    //   if (memberStatus == MemberStatus.initialising) {
    //      _memberStatusText = "initialising";
    //   }
    //   else if (memberStatus == MemberStatus.readytoverify) {
    //      _memberStatusText = "readytoverify";
    //   }
    //   else if (memberStatus == MemberStatus.readytorun) {
    //      // member data cannot be changed when its gets here 
    //      _memberStatusText = "readytorun";
    //   }
    //   else if (memberStatus == MemberStatus.running) {
    //      _memberStatusText = "running";
    //   }
    //   else { 
    //      _memberStatusText = "concluded";
    //   }
      
    // } // getMemberStatus_asString()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    function getAccount() public view 
      returns (address _account) {
      
       _account = account;

    } // getAccount()

    // function getKeyData() public view 
    //   returns (address _account) {
    //   _account = account;

    // } // getKeyData()


    // function getRequirement_forContributionAsset() public view
    //   returns (string memory _Name, uint _Amount, address _walletAddress ) {
      
    //   _Name = contributionAsset.Asset.Name;
    //   _Amount = contributionAsset.Asset.Amount;
    //   _walletAddress = contributionAsset.walletAddress;

    // } // getRequirement_forContributionAsset()


    // function getRequirement_forStakingAsset() public view
    //   returns (string memory _Name, uint _Amount, address _walletAddress) {
      
    //   _Name = stakingAsset.Asset.Name;
    //   _Amount = stakingAsset.Asset.Amount;
    //   _walletAddress = stakingAsset.walletAddress;

    // } // getRequirement_forStakingAsset()


    // function getData_forMember() public view
    //   returns (string memory _memberStatusText) {
      
    //   _memberStatusText = getMemberStatus_asString();

    // } // getData_forMember()

    //----------------------------------
    // External Functions
    //----------------------------------
    // function isMemberStatus_initialising() public view returns(bool) {
    //     if(memberStatus == MemberStatus.initialising)
    //         return true;
    // } // isMemberStatus_initialising()

    // function isMemberStatus_readytoverify() public view returns(bool _value) {
    //     _value = (memberStatus == MemberStatus.readytoverify);
    // } // isMemberStatus_readytoverify()
    
    // // function setMemberStatusTo_readytoverify() public onlyWhenInitialising {
    // //     // To be set by "the member" when the initial configuration is complete.
    // //     // Now the member is also wishing to verfy all details.
    // //     memberStatus = MemberStatus.readytoverify;
    // // } // setMemberStatusTo_readytoverify()

    // function isMemberStatus_readytorun() public view returns(bool _value) {
    //     _value = (memberStatus == MemberStatus.readytorun);
    // } // isMemberStatus_readytorun()

    // function setMemberStatusTo_readytorun() public onlyWhenReadyToVerfyMember {
    //   // To be set by the "member" when verfied. All the needed checks (staking amount,...) have been done.
    //   // The member is now wishing to run with the pool (go live).
    //   memberStatus = MemberStatus.readytorun;

    // } // setMemberStatusTo_readytorun()

    function isMemberStatus_running() public view returns(bool _value) {
        _value = (memberStatus == MemberStatus.running);
    } // isMemberStatus_running()

    // function setMemberStatusTo_running() public onlyWhenPoolMemberIsReadyToRun {
    //     memberStatus = MemberStatus.readytorun;
    // } // setMemberStatusTo_running()

    function isMemberStatus_concluded() public view returns(bool _value) {
        _value = (memberStatus == MemberStatus.concluded);
    } // isMemberStatus_concluded()

    // function setMemberStatusTo_concluded() public onlyWhenThePoolIsRunning {

    //   memberStatus = MemberStatus.concluded;

    // } // setMemberStatusTo_concluded()

} // contract Member


contract MembersList {

    //----------------------------------
    // Type definitions
    //----------------------------------
    //----------------------------------
    // Data
    //----------------------------------
    address poolAddress;
    uint maxNoOfMembers;
    Member[] private listOfMembers;

    // MembersList working data
    //----------------------------------
    // Modifiers
    //----------------------------------
    
    /* Events */
    // event AddMember(address indexed _memberAddress, uint256 indexed _poolId);
    // event RemoveMember(address indexed _memberAddress, uint256 indexed _poolId);
    
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(uint _maxNoOfMembers){
        maxNoOfMembers = _maxNoOfMembers;
    //   poolAddress = _poolAddress;
    } // constructor()

    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getLength() public view returns(uint) {
       return listOfMembers.length;
    } // getLength()

    function getMember_atIndex(uint _index) public view returns(Member) {
       require(_index < listOfMembers.length);
       return listOfMembers[_index];
    } // getMember_atIndex()
    
    

    // function removeMember_atIndex(uint _index) public {
    //   // Move the last element to the deleted spot.
    //   // Delete the last element, then correct the length.
    //   require(_index < listOfMembers.length);
    //   listOfMembers[_index] = listOfMembers[listOfMembers.length-1];
    //   listOfMembers.pop();
    // } // removeMember_atIndex()
    //----------------------------------
    // GUI Functions
    //----------------------------------
    function addNewMember(address _account) public 
    returns (uint _index){
       require(listOfMembers.length <= maxNoOfMembers, "This pool is full");
       bool userAlreadyExists;
       (userAlreadyExists, _index) = isThisUserAlreadyAMember(_account);

       if (userAlreadyExists) {
           revert("User exist");
       }
       
       Member _NewMember = new Member(_account);
       listOfMembers.push(_NewMember);

    //   emit AddMember(_account, parentPool.getPoolId());            
    } // addNewMember() 

    // function removeMember(Member _member) public {
    //     // // First check if this member does exist using "user id"
    //     // bool userAlreadyExists;
    //     // uint _index;
    //     // (userAlreadyExists, _index) = isThisUserAlreadyAMember(_member.getKeyData());

    //     // if (userAlreadyExists) {
    //     //     removeMember_atIndex(_index);
    //     // }
    //     // else{
    //     //     revert("Member is not part of this pool");
    //     // }

    //     // emit RemoveMember(_member.getKeyData(), parentPool.getPoolId());            
    // } // addNewMember() 

    function isThisUserAlreadyAMember(address _account) public view
      returns (bool _doesExist, uint _index){
        // First check if this member does exist using "user id"
        uint length = listOfMembers.length;
        Member _member;

       _doesExist = false;

       for (uint i = 0; i < length; i++) {
         _member = listOfMembers[i];
         if (_member.getAccount() == _account) {
           _doesExist = true;
           _index = i;
           break;
         }
       } // for loop 

    } // isThisUserAlreadyAMember() 

    //==================================
    

    //----------------------------------
    // External Functions
    //----------------------------------

}  // contract MembersList