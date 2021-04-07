// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract PoolRequirements{
  //----------------------------------
  // Type definitions
  //----------------------------------
  //----------------------------------
  // Data
  //----------------------------------
  uint private maxNoOfMembers = 1; // Maximum number of contributors.
  uint private minNoOfMembers = 1; // Minimum number of contributors.

  Pool_Utils.CryptoAsset private contributionAsset; 
  Pool_Utils.CryptoAsset private stakingAsset;
  //----------------------------------
  // Modifiers
  //----------------------------------
  //----------------------------------
  // Functions
  //----------------------------------
  constructor() { 
    // set defaults
    contributionAsset.Name = "bnb"; // Asset name to be use with the fixed
                                    // amount. (bnb,ether,crypt)
    contributionAsset.Amount = 1;   // Fixed Amount that every contributor
                                    // spends per cycle.

    stakingAsset.Name = "bnb"; // Asset name to be used when the contributor 
                               // fails to contribute to the pool.
                               // (bnb,ether,crypt)
    stakingAsset.Amount = 1;   // staking amount to sufficiently prevent 
                               // defaulters of this pool.
  } // constructor()

  //MAX
  function getMaxNoOfMembers() public view
    returns (uint _maxNoOfMembers) {
    _maxNoOfMembers = maxNoOfMembers;
  } // getMaxNoOfMembers()

  function setMaxNoOfMembers(uint _maxNoOfMembers) public {
    maxNoOfMembers = _maxNoOfMembers;
  } // setMaxNoOfMembers()

  //MIN
  function getMinNoOfMembers() public view
    returns (uint _minNoOfMembers) {
    _minNoOfMembers = minNoOfMembers;
  } // getMinNoOfMembers()

  function setMinNoOfMembers(uint _minNoOfMembers) public {
    minNoOfMembers = _minNoOfMembers;
  } // setMinNoOfMembers()

  // Contributions
  function getFixedContributionAmount() public view 
    returns(uint) {
    return contributionAsset.Amount;
  } // getFixedContributionAmount()

  function setContributionAsset(string memory _Name, uint _Amount) 
    public {
      
    if (!Pool_Utils.isSameStringValue(contributionAsset.Name,_Name)) {
      contributionAsset.Name = _Name;
    }
    if (contributionAsset.Amount != _Amount){
      contributionAsset.Amount = _Amount;
    }
  } // setrContributionAsset()

  function getContributionAsset() public view
    returns (string memory _Name, uint _Amount) {
      
     _Name = contributionAsset.Name;
     _Amount = contributionAsset.Amount;

  } //getContributionAsset()

  // Staking
  function getStakingAsset() public view
    returns (string memory _Name, uint _Amount) {
      
     _Name = stakingAsset.Name;
     _Amount = stakingAsset.Amount;

  } // getStakingAsset()

  function setStakingAsset(string memory _Name, uint _Amount) 
    public {
      
    if (!Pool_Utils.isSameStringValue(stakingAsset.Name,_Name)) {
      stakingAsset.Name = _Name;
    }
    if (stakingAsset.Amount != _Amount){
      stakingAsset.Amount = _Amount;
    }
  } // setStakingAsset()
  //----------------------------------
  // Helper Functions
  //----------------------------------
  //----------------------------------
  // GUI Functions
  //----------------------------------
  //----------------------------------
  // External Functions
  //----------------------------------
} // contract PoolRequirements



contract Pool {
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum PoolStatus {initialising,addingmembers,readytorun,running,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    uint private id;  // unique Identification for each pool event.
    address private creator_ownerid;  // The "owner id" that created this pool.
                                   // The owner may or may not be a member 
                                   // of this pool.
    string poolName = "noname";  // the pool name that the pool owner assigns                              

    // Pool working data
    PoolStatus poolStatus; // (initialising,addingmembers,readytorun,
                           //  running,concluded)
    
    PoolRequirements poolRequirements;  // Required defaults/parameters for this pool                          

    MembersList  membersList; // List of all members that will be
                              // playing in this pool
    CyclesList  cyclesList;   // List of cycles that have already been run.
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            poolStatus == PoolStatus.initialising,
            "P01" //"This task can only be done when Initialising this Pool."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenAddingMembers() {
        require(
            poolStatus == PoolStatus.addingmembers,
            "P02" //"This task can only be done when Adding Members to this Pool."
        );
        _;
    } // onlyWhenAddingMembers()

    modifier onlyWhenItsReadyToRun() {
        require(
            poolStatus == PoolStatus.readytorun,
            "P03" //"This task can only be done when this Pool is Ready to Run."
        );
        _;
    } // onlyWhenItsReadyToRun()

    modifier onlyWhenThePoolIsRunning() {
        require(
            poolStatus == PoolStatus.running,
            "P04" //"This task can only be done when the Pool is Running."
        );
        _;
    } // onlyWhenThePoolIsRunning()

    modifier onlyWhenThePoolHasConculded() {
        require(
            poolStatus == PoolStatus.concluded,
            "P05" //"This task can only be done when the Pool has Concluded."
        );
        _;
    } // onlyWhenThePoolHasConculded()

    //----------------------------------
    // Functions
    //----------------------------------
    constructor(address _ownerid, uint _uniqueId, bool participateInThisPool) {
      id = _uniqueId;
      creator_ownerid = _ownerid;

      poolStatus = PoolStatus.initialising; 

      poolRequirements = new PoolRequirements(); // Required defaults for this pool                          

      membersList = new MembersList(poolRequirements); // List of all members that will be
                                                       // playing in this pool                       
      cyclesList = new CyclesList(poolRequirements, membersList);  // List of cycles that have already been run.

      if (participateInThisPool) {
        membersList.addNewMember(_ownerid);
      }

    } // constructor()

    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getPoolStatus_asString() private view 
      returns(string memory _poolStatusText) {

      if (poolStatus == PoolStatus.initialising) {
         // initialising
         _poolStatusText = "initialising";
      }
      else if (poolStatus == PoolStatus.addingmembers) {
         // Adding pool members
         _poolStatusText = "addingmembers";
      }
      else if (poolStatus == PoolStatus.readytorun) {
         // Ready to Run
         _poolStatusText = "readytorun";
      }
      else if (poolStatus == PoolStatus.running) {
         // running
         _poolStatusText = "running";
      }
      else {
         // concluded 
         _poolStatusText = "concluded";
      }
      
    } // getPoolStatus_asString()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    /*
      The aim for the GUI functions is to expose:
      1. display pool details
      2. display members in the pool TODO
      3. display cycle details (history?) TODO
      4. display the status of the pool (initialising,addingmembers,readytorun,
         running,concluded)


      5. edit pool details
      6. edit/add members participation in this pool 
         (only while still "addingmembers") TODO
      
      7. remove members from the pool (only while still "addingmembers") TODO
    */
    function getUniqueID() public view 
      returns (uint _id) {
      
       _id = id;

    } // getUniqueID()

    function getPool() public view returns(Pool) {
       return this;
    } // getPool()

    function getPoolName() public view 
      returns (string memory) {
      
      return  poolName;

    } // getPoolName()

    function setPoolName(string memory _poolName) public  onlyWhenInitialising {
      
      poolName = _poolName;

    } // setPoolName()

    function getKeyData() public view 
      returns (uint _id, address _creator_ownerid) {
      
       _id = id;
       _creator_ownerid = creator_ownerid;

    } // getKeyData()

    function setKeyData(address _creator_ownerid) public onlyWhenInitialising {
      
      if (creator_ownerid != _creator_ownerid){
       creator_ownerid = _creator_ownerid;
      }

    } // setKeyData()

    function getData_forPool() public view
      returns (string memory _poolStatusText) {
      
      _poolStatusText = getPoolStatus_asString();

    } // getData_forPool()

    //----------------------------------
    // External Functions
    //----------------------------------
    /*
      The aim of the external functions is to expose:
      1. the status of the pool to the main looping mechanism.
      2. the ability to "run" this pool from the main looping mechanism
     */

    function isPoolStatus_initialising() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.initialising);

    } // isPoolStatus_initialising()

    function isPoolStatus_addingmembers() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.addingmembers);

    } // isPoolStatus_addingmembers()
    
    function setPoolStatusTo_addingmembers() public onlyWhenInitialising {
      // To be set by "the owner of the pool" when the 
      // pool configuration is complete.
      // Now the owner is also wishing to add
      // the members to the pool.
      poolStatus = PoolStatus.addingmembers;

    } // setPoolStatusTo_addingmembers()

    function isPoolStatus_readytorun() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.readytorun);

    } // isPoolStatus_readytorun()

    function setPoolStatusTo_readytorun() public onlyWhenAddingMembers {
      // To be set by the "owner of the pool" when all the 
      // members have been allocated.
      // All the needed checks (staking amount,...) have been done.
      // The owner is now wishing to run the pool (go live).
      poolStatus = PoolStatus.readytorun;

    } // setPoolStatusTo_readytorun()

    function isPoolStatus_running() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.running);

    } // isPoolStatus_running()

    function isPoolStatus_concluded() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.concluded);

    } // isPoolStatus_concluded()

    function processThisPool() public onlyWhenItsReadyToRun
      returns(bool _value) {
      // This will be called by some looping mechanism of a parent contract

      // go live
      uint MembersArraySize = membersList.getLength();

      if ((MembersArraySize >= poolRequirements.getMinNoOfMembers()) && 
          (MembersArraySize <= poolRequirements.getMaxNoOfMembers())) {
        //------------------------------
        // Check Members
        // todo

        //------------------------------
        // Check Cycles 
        // (initialising ==> running ==> concluded)
        if (cyclesList.isPoolCycleListStatus_initialising()) {
          // Start cycles
          cyclesList.setCycleListStatusTo_running();
        }
        else if (cyclesList.isPoolCycleListStatus_running()) {
          // process all remaining cycles
          cyclesList.processCycles();
        }
        else if (cyclesList.isPoolCycleListStatus_concluded()) {
          // nothing more to do in this pool
          poolStatus = PoolStatus.concluded;
        }  
        //------------------------------
        _value = true; 
      }
      else {
        _value = false; 
      }
    } // processThisPool()

    function getPoolRequirements() public view 
      returns(PoolRequirements _poolRequirements){
      _poolRequirements = poolRequirements;
    } // getPoolRequirements()

    function getMembersList() public view 
      returns(MembersList _membersList){
      _membersList = membersList;
    } // getMembersList()

    function getCyclesList() public view 
      returns(CyclesList _cyclesList){
      _cyclesList = cyclesList;
    } // getCyclesList()

} // contract Pool


contract PoolsList{
    //----------------------------------
    // Type definitions
    //----------------------------------
    //----------------------------------
    // Data
    //----------------------------------
    Pool[] public listOfPools;

    // PoolList working data
    uint256 uniqueID = 0; // Source of the auto generated id
    //----------------------------------
    // Modifiers
    //----------------------------------
    //----------------------------------
    // Functions
    //----------------------------------
    constructor() {

    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getNextUniqueId() public returns(uint256) {
       uniqueID++; 
       return uniqueID;
    } // getNextUniqueId()

    function getLength() public view returns(uint) {
       return listOfPools.length;
    } // getLength()

    function getPool_atIndex(uint _index) public view returns(Pool) {
       require(_index < listOfPools.length);
       return listOfPools[_index];
    } // getPool_atIndex()

    function removePool_atIndex(uint _index) public {
      // Move the last element to the deleted spot.
      // Delete the last element, then correct the length.
      require(_index < listOfPools.length);

      // Only allowed to remove this pool if is in "initialisation" status.
      Pool _pool = listOfPools[_index].getPool();
      require(_pool.isPoolStatus_initialising());
      
      listOfPools[_index] = listOfPools[listOfPools.length-1];
      listOfPools.pop();

    } // removePool_atIndex()
    //----------------------------------
    // GUI Functions
    //----------------------------------
    function addNewPool(address _ownerid) public 
      returns (uint _uniqueId, uint _index){
         _uniqueId = getNextUniqueId();

         Pool _NewPool = new Pool(_ownerid, _uniqueId, true);

         listOfPools.push(_NewPool);

         _index = listOfPools.length -1;
    } // addNewPool() 
    //----------------------------------
    // External Functions
    //----------------------------------
    function processAllPools() public {
      // This will be called by some looping mechanism of a parent contract
      Pool _thisPool;
      for (uint i = 0; i < listOfPools.length; i++) {
        _thisPool = listOfPools[i];
        _thisPool.processThisPool();
      } // for loop 
    } // processAllPools()

} //contract PoolsList 


library Pool_Utils {

    //----------------------------------
    // Type definitions
    //----------------------------------
    struct CryptoAsset {
        string Name;
        uint   Amount;
    }  // struct CryptoAsset 
    struct CryptoAssetWithAddress {
        CryptoAsset Asset;
        address walletAddress;        
    }  // struct CryptoAssetWithAddress 

    //----------------------------------
    // Functions
    //----------------------------------
    function isSameStringValue(string memory _a, string memory _b)
      internal pure returns (bool) {
      if (bytes(_a).length != bytes(_b).length) {
        return false;
      } else {
        return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
      }
    } // isSameStringValue()

   /* TODO TODO TODO
   function integerToString(uint _i) internal pure 
      returns (string memory) {
      
      if (_i == 0) {
         return "0";
      }
      uint j = _i;
      uint len;
      
      while (j != 0) {
         len++;
         j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len - 1;
      
      while (_i != 0) {
         uint8 _bytes8 = uint8(48 + _i % 10);
     //Todo   bstr[k--] = _bytes8;
         _i /= 10;
      }
      return string(bstr);
   }  // integerToString() 
   */ 

} // library Pool_Utils

contract Member {
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum MemberStatus {initialising,readytoverify,readytorun,running,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    uint private id;  // unique Identification for each Member.
    address private userid;  // The "user id" of of the member that joined this pool.
    
    Pool_Utils.CryptoAssetWithAddress contributionAsset;
    Pool_Utils.CryptoAssetWithAddress stakingAsset;
    Pool_Utils.CryptoAssetWithAddress payoutAsset;

    MemberStatus memberStatus; // (initialising,readytoverify,readytorun,
                               //  running,concluded)  
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            memberStatus == MemberStatus.initialising,
            "M01" //"This task can only be done while Initialising this Pool Member."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenReadyToVerfyMember() {
        require(
            memberStatus == MemberStatus.readytoverify,
            "M02" //"This task can only be done when verifing this Pool Member."
        );
        _;
    } // onlyWhenAddingMembers()

    modifier onlyWhenPoolMemberIsReadyToRun() {
        require(
            memberStatus == MemberStatus.readytorun,
            "M03" //"This task can only be done when this Pool Member is Ready to participate in the Pool."
        );
        _;
    } // onlyWhenPoolMemberIsReadyToRun()

    modifier onlyWhenThePoolIsRunning() {
        require(
            memberStatus == MemberStatus.running,
            "M04" //"This task can only be done while the Pool Member is an active part of the Pool."
        );
        _;
    } // onlyWhenPoolMemberIsReadyToRun()

    modifier onlyWhenThePoolHasConculded() {
        require(
            memberStatus == MemberStatus.concluded,
            "M05" //"This task can only be done after the pool has been concluded for this Member."
        );
        _;
    } // onlyWhenThePoolHasConculded()
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(PoolRequirements _poolRequirements,
                uint _uniqueid,
                address _userid
                ) {

      id  = _uniqueid ;
      userid = _userid;

      // set defaults
      string memory _AssetName;
      uint _AssetAmount;

      // Asset name to be use with the fixed
      // amount. (bnb,ether,crypt)
      (_AssetName, _AssetAmount) = _poolRequirements.getContributionAsset();

      contributionAsset.Asset.Name = _AssetName;
      // Fixed Amount that every member spends per cycle.
      contributionAsset.Asset.Amount = _AssetAmount;

      // Asset name to be use by the member who
      // fails to contribute to the pool.
      // (bnb,ether,crypt)
      (_AssetName, _AssetAmount) = _poolRequirements.getStakingAsset();

      stakingAsset.Asset.Name = _AssetName; 
      // staking amount to be used as colateral.
      stakingAsset.Asset.Amount = _AssetAmount;   

      // Asset name to be use by the member for payouts 
      // (bnb,ether,crypt)
      payoutAsset.Asset.Name = contributionAsset.Asset.Name; 
      payoutAsset.Asset.Amount = 0;   // payout amount.

      memberStatus = MemberStatus.initialising;

    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getMemberStatus_asString() private view 
      returns(string memory _memberStatusText) {

      if (memberStatus == MemberStatus.initialising) {
         // initialising
         _memberStatusText = "initialising";
      }
      else if (memberStatus == MemberStatus.readytoverify) {
         // Ready to have all the member data verified
         _memberStatusText = "readytoverify";
      }
      else if (memberStatus == MemberStatus.readytorun) {
         // Ready to Run
         // member data cannot be changed when its gets here 
         _memberStatusText = "readytorun";
      }
      else if (memberStatus == MemberStatus.running) {
         // running
         _memberStatusText = "running";
      }
      else {
         // concluded 
         _memberStatusText = "concluded";
      }
      
    } // getMemberStatus_asString()

    function getContributionBalanceAmount() public view 
      returns(uint _contributionBalance) {
      
      _contributionBalance = contributionAsset.Asset.Amount;

    } // getContributionBalanceAmount()

    function depositContributionAmount(uint _depositAmount) public 
      returns(uint _contributionBalance) {
      
      contributionAsset.Asset.Amount = (contributionAsset.Asset.Amount + _depositAmount);
      _contributionBalance = contributionAsset.Asset.Amount;

    } // depositContributionAmount()

    function extractContributionAmount(uint _fixedAmountToExtract) public 
      returns(uint _extractedAmount) {
      
      contributionAsset.Asset.Amount = (contributionAsset.Asset.Amount - _fixedAmountToExtract);
      _extractedAmount = _fixedAmountToExtract;

    } // extractContributionAmount()

    function depositCycleWinningAmount(uint _cycleWinningAmount) public {
      
      payoutAsset.Asset.Amount = (payoutAsset.Asset.Amount + _cycleWinningAmount);

    } // depositCycleWinningAmount()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    function getUniqueID() public view 
      returns (uint _id) {
      
       _id = id;

    } // getUniqueID()

    function getUserID() public view 
      returns (address _userid) {
      
       _userid = userid;

    } // getUserID()

    function getKeyData() public view 
      returns (uint _id, address _userid) {
      
       _id = id;
       _userid = userid;

    } // getKeyData()

    function setKeyData(address _userid) public onlyWhenInitialising {
      
      if (userid != _userid){
       userid = _userid;
      }

    } // setKeyData()

    function getRequirement_forContributionAsset() public view
      returns (string memory _Name, uint _Amount, address _walletAddress ) {
      
       _Name = contributionAsset.Asset.Name;
       _Amount = contributionAsset.Asset.Amount;
       _walletAddress = contributionAsset.walletAddress;

    } // getRequirement_forContributionAsset()

    function setRequirement_forContributionAsset(string memory _Name, uint _Amount, address _walletAddress) 
      public onlyWhenInitialising {
      
      if (!Pool_Utils.isSameStringValue(contributionAsset.Asset.Name,_Name)) {
        contributionAsset.Asset.Name = _Name;
      }
      if (contributionAsset.Asset.Amount != _Amount){
        contributionAsset.Asset.Amount = _Amount;
      }
      if (contributionAsset.walletAddress != _walletAddress){
        contributionAsset.walletAddress = _walletAddress;
      }

    } // setRequirement_forContributionAsset()

    function getRequirement_forStakingAsset() public view
      returns (string memory _Name, uint _Amount, address _walletAddress) {
      
       _Name = stakingAsset.Asset.Name;
       _Amount = stakingAsset.Asset.Amount;
       _walletAddress = stakingAsset.walletAddress;

    } // getRequirement_forStakingAsset()

    function setRequirement_forStakingAsset(string memory _Name, uint _Amount, address _walletAddress) 
      public onlyWhenInitialising {
      
      if (!Pool_Utils.isSameStringValue(stakingAsset.Asset.Name,_Name)) {
        stakingAsset.Asset.Name = _Name;
      }
      if (stakingAsset.Asset.Amount != _Amount){
        stakingAsset.Asset.Amount = _Amount;
      }
      if (stakingAsset.walletAddress != _walletAddress){
        stakingAsset.walletAddress = _walletAddress;
      }

    } // setRequirement_forStakingAsset()

    function getRequirement_forPayOutAsset() public view
      returns (string memory _Name, uint _Amount, address _walletAddress) {
      
       _Name = payoutAsset.Asset.Name;
       _Amount = payoutAsset.Asset.Amount;
       _walletAddress = payoutAsset.walletAddress;

    } // getRequirement_forPayOutAsset()

    function setRequirement_forPayOutAsset(string memory _Name, uint _Amount, address _walletAddress) 
      public onlyWhenInitialising {
      
      if (!Pool_Utils.isSameStringValue(payoutAsset.Asset.Name,_Name)) {
        payoutAsset.Asset.Name = _Name;
      }
      if (payoutAsset.Asset.Amount != _Amount){
        payoutAsset.Asset.Amount = _Amount;
      }
      if (payoutAsset.walletAddress != _walletAddress){
        payoutAsset.walletAddress = _walletAddress;
      }

    } // setRequirement_forPayOutAsset()

    function getData_forMember() public view
      returns (string memory _memberStatusText) {
      
      _memberStatusText = getMemberStatus_asString();

    } // getData_forMember()

    //----------------------------------
    // External Functions
    //----------------------------------
    function isMemberStatus_initialising() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.initialising);

    } // isMemberStatus_initialising()

    function isMemberStatus_readytoverify() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.readytoverify);

    } // isMemberStatus_readytoverify()
    
    function setMemberStatusTo_readytoverify() public onlyWhenInitialising {
      // To be set by "the member" when the 
      // initial configuration is complete.
      // Now the member is also wishing to verfy all details.
      memberStatus = MemberStatus.readytoverify;

    } // setMemberStatusTo_readytoverify()

    function isMemberStatus_readytorun() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.readytorun);

    } // isMemberStatus_readytorun()

    function setMemberStatusTo_readytorun() public onlyWhenReadyToVerfyMember {
      // To be set by the "member" when verfied.
      // All the needed checks (staking amount,...) have been done.
      // The member is now wishing to run with the pool (go live).
      memberStatus = MemberStatus.readytorun;

    } // setMemberStatusTo_readytorun()

    function isMemberStatus_running() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.running);

    } // isMemberStatus_running()

    function setMemberStatusTo_running() public onlyWhenPoolMemberIsReadyToRun {

      memberStatus = MemberStatus.readytorun;

    } // setMemberStatusTo_running()

    function isMemberStatus_concluded() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.concluded);

    } // isMemberStatus_concluded()

    function setMemberStatusTo_concluded() public onlyWhenThePoolIsRunning {

      memberStatus = MemberStatus.concluded;

    } // setMemberStatusTo_concluded()

} // contract Member

contract MembersList {

    //----------------------------------
    // Type definitions
    //----------------------------------
    //----------------------------------
    // Data
    //----------------------------------
    PoolRequirements poolRequirements;

    Member[] public listOfMembers;

    // MembersList working data
    uint256 uniqueID = 0; // Source of the auto generated id
    //----------------------------------
    // Modifiers
    //----------------------------------
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(PoolRequirements _poolRequirements) {

      poolRequirements = _poolRequirements;

    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getNextUniqueId() public returns(uint256) {
       uniqueID++; 
       return uniqueID;
    } // getNextUniqueId()

    function getLength() public view returns(uint) {
       return listOfMembers.length;
    } // getLength()

    function getMember_atIndex(uint _index) public view returns(Member) {
       require(_index < listOfMembers.length);
       return listOfMembers[_index];
    } // getMember_atIndex()

    function removeMember_atIndex(uint _index) public {
      // Move the last element to the deleted spot.
      // Delete the last element, then correct the length.
      require(_index < listOfMembers.length);
      listOfMembers[_index] = listOfMembers[listOfMembers.length-1];
      listOfMembers.pop();
    } // removeMember_atIndex()

    function extractAllMemberContributions(uint _fixedAmountToExtract) public 
      returns(uint _totalContributions) {
      // For the testing period this will only be simulated
      uint poolMemberSize = listOfMembers.length;

      _totalContributions = 0;
      uint _extractedAmount;
      Member _member;
      for (uint i = 0; i < poolMemberSize; i++) {
        _member = listOfMembers[i];
        _extractedAmount = _member.extractContributionAmount(_fixedAmountToExtract);
        _totalContributions = (_totalContributions + _extractedAmount);
      } // for loop 
    } // extractAllMemberContributions()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    function addNewMember(address _userid) public 
      returns (uint _uniqueId, uint _index){
       // First check if this member does exist using "user id"
       bool userAlreadyExists;
       (userAlreadyExists, _uniqueId, _index) = isThisUserAlreadyAMember(_userid);

       if (!userAlreadyExists) {
         // Check Max number of members
         require(listOfMembers.length < poolRequirements.getMaxNoOfMembers());

         _uniqueId = getNextUniqueId();

         Member _NewMember = new Member(poolRequirements, _uniqueId, _userid);
         listOfMembers.push(_NewMember);

         _index = listOfMembers.length -1;
       }

    } // addNewMember() 

    function isThisUserAlreadyAMember(address _userid) public view
      returns (bool _doesExist, uint _uniqueId, uint _index){
        // First check if this member does exist using "user id"
        uint length = listOfMembers.length;
        Member _member;

       _doesExist = false;

       for (uint i = 0; i < length; i++) {
         _member = listOfMembers[i];
         if (_member.getUserID() == _userid) {
           _uniqueId = _member.getUniqueID();
           _doesExist = true;
           _index = i;
           break;
         }
       } // for loop 

    } // isThisUserAlreadyAMember() 

    function getMemberIndex_usingUniqueID(uint _uniqueId) public view
      returns (bool _doesExist, uint _index){
        // get the index in the array that has this unique index
        
        uint length = listOfMembers.length;
        Member _member;

        _doesExist = false;
        for (uint i = 0; i < length; i++) {
         _member = listOfMembers[i];
         if (_member.getUniqueID() == _uniqueId) {
           _doesExist = true;
           _index = i;
           break;
         }
       } // for loop 

    } // getMemberIndex_usingUniqueID() 

    //==================================
    function getUserID_usingUniqueID(uint _uniqueId) public view 
      returns (bool _doesExist, address _userid) {
      
      uint _index;
      (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);
      if (_doesExist) {
        Member _member = listOfMembers[_index]; 
        (_userid) = _member.getUserID();
      }  

    } // getUserID_usingUniqueID()
    
    // function getKeyData_usingUniqueID(uint _uniqueId) public view 
    //   returns (bool _doesExist, address _userid) {
      
    //   uint _index;
    //   (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

    //   if (_doesExist) {
    //     Member _member = listOfMembers[_index]; 
    //     (_uniqueId, _userid) = _member.getKeyData();
    //   }  

    // } // getKeyData_usingUniqueID()

    // function setKeyData_usingUniqueID(uint _uniqueId, address _userid) public  {
      
    //   bool _doesExist;
    //   uint _index;
    //   (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

    //   if (_doesExist) {
    //     Member _member = listOfMembers[_index]; 
    //     _member.setKeyData(_userid);
    //   }  

    // } // setKeyData_usingUniqueID()

    // function getRequirement_forContributionAsset_usingUniqueID(uint _uniqueId) public view
    //   returns (bool _doesExist, string memory _Name, uint _Amount, address _walletAddress ) {
      
    //   uint _index;
    //   (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

    //   if (_doesExist) {
    //     Member _member = listOfMembers[_index]; 
    //     (_Name, _Amount, _walletAddress) = _member.getRequirement_forContributionAsset();
    //   }  
    // } // getRequirement_forContributionAsset_usingUniqueID()

    // function setRequirement_forContributionAsset_usingUniqueID(uint _uniqueId, string memory _Name, uint _Amount, address _walletAddress) 
    //   public {

    //   bool _doesExist;
    //   uint _index;
    //   (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

    //   if (_doesExist) {
    //     Member _member = listOfMembers[_index]; 
    //     _member.setRequirement_forContributionAsset(_Name, _Amount,  _walletAddress);
    //   }  

    // } // setRequirement_forContributionAsset_usingUniqueID()


    //----------------------------------
    // External Functions
    //----------------------------------

}  // contract MembersList


contract Cycle{
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum CycleStatus {initialising,waitForInterval,allocateWinner,payoutWinner,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    uint private id;  // unique Identification for each Cycle.
    
    MembersList private poolMembersList;

    uint cycleNo; // eg 1/10,2/10 etc

    Member winningMember; // The member that won this round/cycle

    CycleStatus cycleStatus; // (initialising,waitForInterval,allocateWinner,payoutWinner,concluded)  

    uint256 startedDate; // The date that this cycle started.
                         // This date will be used with the cycle intercal
                         // period to know when the cycle has ompleted.
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            cycleStatus == CycleStatus.initialising,
            "C01" //"This task can only be done when Initialising this Pool Cycle."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenWaitingForAnIntervalToComplete() {
        require(
            cycleStatus == CycleStatus.waitForInterval,
            "C02" //"This task can only be done while waiting for this Pool Cycle interval to complete."
        );
        _;
    } // onlyWhenWaitingForAnIntervalToComplete()

    modifier onlyWhenAllocatingAWinner() {
        require(
            cycleStatus == CycleStatus.allocateWinner,
            "C03" //"This task can only be done when allocate Winner for this Pool Cycle."
        );
        _;
    } // onlyWhenAllocatingAWinner()

    modifier onlyWhenPayingoutWinner() {
        require(
            cycleStatus == CycleStatus.payoutWinner,
            "C04" //"This task can only be done when paying out the Winner for this Pool Cycle."
        );
        _;
    } // onlyWhenPayingoutWinner()

    modifier onlyWhenThePoolCycleHasConculded() {
        require(
            cycleStatus == CycleStatus.concluded,
            "C05" //"This task can only be done when the Pool Cycle has Concluded."
        );
        _;
    } // onlyWhenThePoolCycleHasConculded()
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(uint256 _uniqueid, uint _cycleNo, MembersList _poolMembersList) {

      id  = _uniqueid ;
      cycleNo = _cycleNo;

      poolMembersList = _poolMembersList;

      cycleStatus = CycleStatus.initialising; 
    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getCycleStatus_asString() private view 
      returns(string memory _cycleStatusText) {

      if (cycleStatus == CycleStatus.initialising) {
         // initialising
         _cycleStatusText = "initialising";
      }
      else if (cycleStatus == CycleStatus.waitForInterval) {
         // waiting for the interval to complete
         _cycleStatusText = "waitForInterval";
      }
      else if (cycleStatus == CycleStatus.allocateWinner) {
         // Ready to Run
         _cycleStatusText = "allocateWinner";
      }
      else if (cycleStatus == CycleStatus.payoutWinner) {
         // running
         _cycleStatusText = "payoutWinner";
      }
      else {
         // concluded 
         _cycleStatusText = "concluded";
      }
      
    } // getCycleStatus_asString()

    function checkInitComplete() public onlyWhenInitialising {
      // Check whatever needs be be cheched during. 

      // set the start date.
      startedDate = block.timestamp;
      
      // move to next status
      cycleStatus == CycleStatus.waitForInterval; 

    } // checkInitComplete()

    function setIntervalComplete() public view onlyWhenWaitingForAnIntervalToComplete {
      // the interval duration has completed 

      // move to next status
      cycleStatus == CycleStatus.allocateWinner; 
    } // setIntervalComplete()

    function setWinningPoolMember(Member _member) public onlyWhenAllocatingAWinner {
      // We now have a winner...yay
      winningMember = _member;

      // move to next status
      cycleStatus == CycleStatus.payoutWinner; 
    } // setWinningPoolMember()

    function payoutWinningPoolMember(uint _payoutAmount) public onlyWhenPayingoutWinner {
      // this is where the pooled funds get moved 
      // into the winners payout address.
      winningMember.depositCycleWinningAmount(_payoutAmount);

      // move to next status
      cycleStatus == CycleStatus.concluded; 
    } // setWinningPoolMember()

    function getCycleStartedDate() public view returns(uint256) {
       return startedDate;
    } // getCycleStartedDate()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    function getCycleNo() public view returns(uint) {
       return cycleNo;
    } // getCycleNo()

    function getCycle() public view returns(Cycle) {
       return this;
    } // getCycle()
   
    //----------------------------------
    // External Functions
    //----------------------------------
    function isPoolCycleStatus_initialising() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.initialising);

    } // isPoolCycleStatus_initialising()

    function isPoolCycleStatus_waitForInterval() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.waitForInterval);

    } // isPoolCycleStatus_waitForInterval()

    function isPoolCycleStatus_allocateWinner() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.allocateWinner);

    } // isPoolCycleStatus_allocateWinner()

    function isPoolCycleStatus_payoutWinner() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.payoutWinner);

    } // isPoolCycleStatus_payoutWinner()

    function isPoolCycleStatus_concluded() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.concluded);

    } // isPoolCycleStatus_concluded()

} //contract Cycle 

contract CyclesList{
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum CycleListStatus {initialising,running,concluded} 

    enum CycleIntervalType {day,week,month} 
    //----------------------------------
    // Data
    //----------------------------------
    PoolRequirements poolRequirements;
    MembersList public poolMembersList;

    Cycle[] public listOfCycles;

    CycleListStatus cycleListStatus; // (initialising,running,concluded)

    uint cycleInterval = 1;  // Total number of cycle intervals 
                             // measured in days (week,month?) 
                             // (days between cycles).    
    CycleIntervalType cycleIntervalType; // (day,week,month)

    // CycleList working data
    uint256 uniqueID = 0; // Source of the auto generated id

    uint256 cycles_StartDate;   // Timestamp that the cycles started.

    Member[] private listOfEligiblePoolMembers;
    Member[] private listOfWinningPoolMembers;
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            cycleListStatus == CycleListStatus.initialising,
            "CL01" //"This task can only be done when Initialising this Pool Cycle List."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenCylesAreRunning() {
        require(
            cycleListStatus == CycleListStatus.running,
            "CL02" //"This task can only be done when Running this Pool Cycle List."
        );
        _;
    } // onlyWhenCylesAreRunning()

    modifier onlyWhenCyclesHaveConculded() {
        require(
            cycleListStatus == CycleListStatus.concluded,
            "CL03" //"This task can only be done when the Pool Cycle List has Concluded."
        );
        _;
    } // onlyWhenCyclesHaveConculded()
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(PoolRequirements _poolRequirements, MembersList _poolMembersList) {

      poolRequirements = _poolRequirements;
      poolMembersList = _poolMembersList;

      initialiseAvailiableWinningMembersArray();

      cycleListStatus = CycleListStatus.initialising; // (initialising,running,concluded)

      cycleIntervalType = CycleIntervalType.day; // (day,week,month)

    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
    function getCycleListStatus_asString() private view 
      returns(string memory _cycleListStatusText) {

      if (cycleListStatus == CycleListStatus.initialising) {
         // initialising
         _cycleListStatusText = "initialising";
      }
      else if (cycleListStatus == CycleListStatus.running) {
         // running
         _cycleListStatusText = "running";
      }
      else {
         // concluded 
         _cycleListStatusText = "concluded";
      }
      
    } // getCycleListStatus_asString()

    function getNextUniqueId() public returns(uint256) {
       uniqueID++; 
       return uniqueID;
    } // getNextUniqueId()

    function getLength() public view returns(uint) {
       return listOfCycles.length;
    } // getLength()

    function getCycle_atIndex(uint _index) public view returns(Cycle) {
       require(_index < listOfCycles.length);
       return listOfCycles[_index];
    } // getCycle_atIndex()

    function removeCycle_atIndex(uint _index) public {
      // Move the last element to the deleted spot.
      // Delete the last element, then correct the length.
      require(_index < listOfCycles.length);

      // Only allowed to remove this cycle if is in "initialisation" status.
      Cycle _cycle = listOfCycles[_index].getCycle();
      require(_cycle.isPoolCycleStatus_initialising());
      
      listOfCycles[_index] = listOfCycles[listOfCycles.length-1];
      listOfCycles.pop();

    } // removeCycle_atIndex()

    function initialiseAvailiableWinningMembersArray() private {
       Member _member;
       for (uint i = 0; i < poolMembersList.getLength(); i++) {
         _member = poolMembersList.getMember_atIndex(i);
         listOfEligiblePoolMembers.push(_member);
       } // for loop 
    } // initialiseAvailiableWinningMembersArray()

    function removeMemberFromAvailiableWinningMembersArray(Member _member) private {
       
       Member _arrayMember;
       for (uint i = 0; i < listOfEligiblePoolMembers.length; i++) {
         _arrayMember = listOfEligiblePoolMembers[i];
         if (_arrayMember.getUniqueID() == _member.getUniqueID()){
           // Move the last element to the deleted spot.
           // Delete the last element, then correct the length.
           listOfEligiblePoolMembers[i] = listOfEligiblePoolMembers[listOfEligiblePoolMembers.length-1];
           listOfEligiblePoolMembers.pop();

           break;
         }
       } // for loop 
    } // removeMemberFromAvailiableWinningMembersArray()

    function selectAWinningMember_forThisCycle(Cycle _cycle) public onlyWhenCylesAreRunning
      returns(Member _winningMember) {
      // for testing the initial phase we will do Random
      uint poolofEligibleWinners_Size = listOfEligiblePoolMembers.length;
      require(poolofEligibleWinners_Size > 0, "The list of eligible winners is empy!");

      // find the ramdom winner
      uint sourceOfRandomness = uint(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp)));

      uint randomIndex = (sourceOfRandomness % poolofEligibleWinners_Size);      

      _winningMember = listOfEligiblePoolMembers[randomIndex];

      _cycle.setWinningPoolMember(_winningMember);
      
      // Remove from the eligible Winner list
      removeMemberFromAvailiableWinningMembersArray(_winningMember);
      // Add to the already won members list
      listOfWinningPoolMembers.push(_winningMember);
     
      return _winningMember;

    } // selectAWinningMember_forThisCycle()

    function processCycles() public onlyWhenCylesAreRunning {
      // This will be called by some looping mechanism of a parent contract
      // initialising ==> waitForInterval ==> allocateWinner ==> payoutWinner ==> concluded         
      uint currentNoOfCycles = listOfCycles.length; 
      uint maxNoOfCycles = getMaxNoOfCycles();

      if (currentNoOfCycles < 1) {
        // This starts the cycles....
        
        if (maxNoOfCycles > 0) {
          // Set the start date for the cycles
          cycles_StartDate = block.timestamp;

          // then to start the first cycle cycle
          addNewCycle();
        }
      }

      Cycle _thisCycle;
      uint noOfConcludedCycles = 0;

      for (uint i = 0; i < currentNoOfCycles; i++) {
        _thisCycle = listOfCycles[i];

         if (_thisCycle.isPoolCycleStatus_concluded()) {
           // counting the number of concluded cycles for later use
           noOfConcludedCycles++;
         }
         else if (_thisCycle.isPoolCycleStatus_payoutWinner()) {
           // need to payout the winning member of this cycle
           uint _fixedAmountToExtract = poolRequirements.getFixedContributionAmount();
           uint _totalContributions = poolMembersList.extractAllMemberContributions(_fixedAmountToExtract);
           _thisCycle.payoutWinningPoolMember(_totalContributions);
         }
         else if (_thisCycle.isPoolCycleStatus_allocateWinner()) {
           // looking for a winning member of this cycle
           selectAWinningMember_forThisCycle(_thisCycle);
         }
         else if (_thisCycle.isPoolCycleStatus_waitForInterval()) {
           // this cycle is still waiting for the interval period to complete
           uint256 currentDate = block.timestamp;
           uint256 startedDate = _thisCycle.getCycleStartedDate();
           uint256 diff_inDays = (currentDate - startedDate) / 60 / 60 / 24; // in days           
           
           uint intervalPeriod_inDays = getIntervalPeriod_asDays(); 

           if (diff_inDays >= intervalPeriod_inDays) {
             // cycle interval now complete
             _thisCycle.setIntervalComplete();
           }
         }
         else if (_thisCycle.isPoolCycleStatus_initialising()) {
           // verify that initialisation is complete
           _thisCycle.checkInitComplete();
         }
      } // for loop 

      if (noOfConcludedCycles >= maxNoOfCycles) {
        // This ends the cycles.
        // all cycles have completed, the pool is also now complete
        cycleListStatus = CycleListStatus.concluded;
      }
      else {
        // noOfConcludedCycles < maxNoOfCycles
        if (noOfConcludedCycles == currentNoOfCycles) {
          // All current cycles have concluded
          // its time to add another cycle 
          addNewCycle();
        }
      }
    } // processCycles()

    function getIntervalPeriod_asDays() public view returns(uint) {
      // get the interval period in days
      require(cycleInterval > 0, "Cycle Interval must be greater than zero");

      //cycleInterval
      uint intervalPeriodInDays; 

      if (cycleIntervalType == CycleIntervalType.day) {
        // only a day
        intervalPeriodInDays = 1; 
      }
      else if (cycleIntervalType == CycleIntervalType.week) {
        // only a week
      intervalPeriodInDays = 1*7; //todo
      }
      else if (cycleIntervalType == CycleIntervalType.month) { 
        // only a month
        intervalPeriodInDays = 1*28; //todo
      }  
 
      return (cycleInterval*intervalPeriodInDays); 

    } // getIntervalPeriod_asDays

    function getMaxNoOfCycles() public view returns(uint) {
       return poolMembersList.getLength();
    } // getMaxNoOfCycles()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    function addNewCycle() public onlyWhenCylesAreRunning
      returns (uint _uniqueId, uint _index){
         _uniqueId = getNextUniqueId();

         uint _cycleNo = listOfCycles.length;

         Cycle _NewCycle = new Cycle(_uniqueId, _cycleNo, poolMembersList);
         listOfCycles.push(_NewCycle);

         _index = listOfCycles.length -1;
    } // addNewCycle() 

    function getCurrentCycleNo() public view returns(uint) {
       return listOfCycles.length;
    } // getCurrentCycleNo()

    //----------------------------------
    // External Functions
    //----------------------------------
    function isPoolCycleListStatus_initialising() public view
      returns(bool _value) {
      
      _value = (cycleListStatus == CycleListStatus.initialising);

    } // isPoolCycleListStatus_initialising()

    function isPoolCycleListStatus_running() public view
      returns(bool _value) {
      
      _value = (cycleListStatus == CycleListStatus.running);

    } // isPoolCycleListStatus_running()

    function isPoolCycleListStatus_concluded() public view
      returns(bool _value) {
      
      _value = (cycleListStatus == CycleListStatus.concluded);

    } // isPoolCycleListStatus_concluded()

    function setCycleListStatusTo_running() public onlyWhenInitialising {
      // To be set by the "pool" when the 
      // initial pool configuration is complete
      // and all pool members have been added.
      cycleListStatus = CycleListStatus.running;
    } // setCycleListStatusTo_running()

} //contract CyclesList 



