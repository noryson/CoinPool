// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract Pool {
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum PoolStatus {initialising,addingmembers,readytorun,running,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    uint private id;  // unique Identification for each pool event.
    uint256 private createdDate;   // Timestamp when the pool was created.
    address private creator_ownerid;  // The "owner id" that created this pool.
                                   // The owner may or may not be a member 
                                   // of this pool.
    string poolName = "noname";  // the pool name that the pool owner assigns                              
    // Pool parameters                                  
    /*  @invariants: assets supported are BNB, Ether and Cryptonite */
    Pool_Utils.CryptoAsset public contributionAsset;

    /*  @invariants: assets supported are BNB, Ether and Cryptonite
        @invariants: stakedAsset != asset
    */ 
    Pool_Utils.CryptoAsset public stakingAsset;

    uint maxNoOfMembers = 1; // Maximum number of contributors.
    uint minNoOfMembers = 1; // Minimum number of contributors.

    uint numberOfCycles = 1; // Total number of cycles.    
    uint cycleInterval = 1;  // Total number of cycles intervals 
                             // measured in days (week,month?) 
                             // (days between cycles).    

    // Pool working data
    uint256 cycleStartDate;      // Timestamp that the cycle started.
    uint currentCycleNo = 0;     // The current cycle number
    uint currentNoOfMembers = 0; // The current number of members;

    uint256 uniqueID = 0; // Source of the auto generated id

    PoolStatus poolStatus;    // (initialising,addingmembers,readytorun,
                           //  running,concluded)  

    MembersList  membersList; // List of all members that will be
                              // playing in this pool
    CyclesList  cyclesList;   // List of cycles that have already been run.
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            poolStatus == PoolStatus.initialising,
            "This task can only be done when Initialising this Pool."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenAddingMembers() {
        require(
            poolStatus == PoolStatus.addingmembers,
            "This task can only be done when Adding Members to this Pool."
        );
        _;
    } // onlyWhenAddingMembers()

    modifier onlyWhenItsReadyToRun() {
        require(
            poolStatus == PoolStatus.readytorun,
            "This task can only be done when this Pool is Ready to Run."
        );
        _;
    } // onlyWhenItsReadyToRun()

    modifier onlyWhenThePoolIsRunning() {
        require(
            poolStatus == PoolStatus.running,
            "This task can only be done when the Pool is Running."
        );
        _;
    } // onlyWhenThePoolIsRunning()

    modifier onlyWhenThePoolHasConculded() {
        require(
            poolStatus == PoolStatus.concluded,
            "This task can only be done when the Pool has Concluded."
        );
        _;
    } // onlyWhenThePoolHasConculded()

    //----------------------------------
    // Functions
    //----------------------------------
    constructor(address _ownerid, uint _uniqueId, bool participateInThisPool) {
      id = _uniqueId; //getNextUniqueId();
      createdDate =  block.timestamp;
      creator_ownerid = _ownerid;

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

      poolStatus = PoolStatus.initialising; 

      membersList = new MembersList(this); // List of all members that will be
                                           // playing in this pool                       
      cyclesList = new CyclesList(this,membersList);  // List of cycles that have already been run.

      if (participateInThisPool) {
        membersList.addNewMember(_ownerid);
      }

    } // constructor()

    //----------------------------------
    // Helper Functions
    //----------------------------------
    //function getNextUniqueId() public returns(uint256) {
    //   uniqueID++; 
    //   return uniqueID;
    //} // getNextUniqueId()

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
      returns (uint _id, uint256 _createdDate, address _creator_ownerid) {
      
       _id = id;
       _createdDate = createdDate;
       _creator_ownerid = creator_ownerid;

    } // getKeyData()

    function setKeyData(address _creator_ownerid) public onlyWhenInitialising {
      
      if (creator_ownerid != _creator_ownerid){
       creator_ownerid = _creator_ownerid;
      }

    } // setKeyData()

    function getRequirement_forContributionAsset() public view
      returns (string memory _Name, uint _Amount) {
      
       _Name = contributionAsset.Name;
       _Amount = contributionAsset.Amount;

    } //getRequirement_forContributionAsset()

    function setRequirement_forContributionAsset(string memory _Name, uint _Amount) 
      public onlyWhenInitialising {
      
      if (!Pool_Utils.isSameStringValue(contributionAsset.Name,_Name)) {
        contributionAsset.Name = _Name;
      }
      if (contributionAsset.Amount != _Amount){
        contributionAsset.Amount = _Amount;
      }

    } // setRequirement_forContributionAsset()

    function getRequirement_forStakingAsset() public view
      returns (string memory _Name, uint _Amount) {
      
       _Name = stakingAsset.Name;
       _Amount = stakingAsset.Amount;

    } // getRequirement_forStakingAsset()

    function setRequirement_forStakingAsset(string memory _Name, uint _Amount) 
      public onlyWhenInitialising {
      
      if (!Pool_Utils.isSameStringValue(stakingAsset.Name,_Name)) {
        stakingAsset.Name = _Name;
      }
      if (stakingAsset.Amount != _Amount){
        stakingAsset.Amount = _Amount;
      }

    } // setRequirement_forStakingAsset()

    function getRequirement_forMembers() public view
      returns (uint _maxNoOfMembers, uint _minNoOfMembers) {
      
       _maxNoOfMembers = maxNoOfMembers;
       _minNoOfMembers = minNoOfMembers;

    } // getRequirement_forMembers()

    function setRequirement_forMembers(uint _maxNoOfMembers, uint _minNoOfMembers) 
      public onlyWhenInitialising {
      
      if (maxNoOfMembers != _maxNoOfMembers){
        maxNoOfMembers = _maxNoOfMembers;
      }
      if (minNoOfMembers != _minNoOfMembers){
        minNoOfMembers = _minNoOfMembers;
      }

    } // setRequirement_forMembers()

    function getRequirement_forcycles() public view
      returns (uint _numberOfCycles, uint _cycleInterval) {
      
       _numberOfCycles = numberOfCycles;
       _cycleInterval = cycleInterval;

    } // getRequirement_forcycles()

    function setRequirement_forcycles(uint _numberOfCycles, uint _cycleInterval) 
      public onlyWhenInitialising {
      
      if (numberOfCycles != _numberOfCycles){
        numberOfCycles = _numberOfCycles;
      }
      if (cycleInterval != _cycleInterval){
        cycleInterval = _cycleInterval;
      }

    } // setRequirement_forcycles()

    function getData_forMembers() public view
      returns (uint _currentNoOfMembers) {
      
       _currentNoOfMembers = currentNoOfMembers;

    } // getData_forMembers()

    function getData_forCycles() public view
      returns (uint256 _cycleStartDate, uint _currentCycleNo) {
      
       _cycleStartDate = cycleStartDate;
       _currentCycleNo = currentCycleNo;

    } // getData_forCycles()

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

    function runThisPool() public onlyWhenItsReadyToRun
      returns(bool _value) {
      // go live
      uint MembersArraySize = 1; //PoolMember.Length; TODO
      if ((MembersArraySize >= minNoOfMembers ) && 
          (MembersArraySize <= maxNoOfMembers)) {
        // Try to start running Pool
        // Do first cycle....
        // -- Check that every pool member has the cycle paying amount.
        //    -- if not then remove from the staking amount

        // TODO

        poolStatus = PoolStatus.running;
        _value = true; 
      }
      else {
        _value = false; 
      }
    } // runThisPool()

    function getMembersList() public view returns(MembersList _membersList){
      _membersList = membersList;
    }

    function getCyclesList() public view returns(CyclesList _cyclesList){
      _cyclesList = cyclesList;
    }

} // contract Pool


contract PoolsList{
    //----------------------------------
    // Type definitions
    //----------------------------------
    //----------------------------------
    // Data
    //----------------------------------
    // Todo Main parentMain;

    Pool[] public listOfPools;

    // PoolList working data
    uint256 uniqueID = 0; // Source of the auto generated id
    //----------------------------------
    // Modifiers
    //----------------------------------
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(/*Main _parentMain todo*/) {

      //todo parentMain = _parentMain;
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
    
    Pool private parentPool;
    MembersList private parentMembersList;

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
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(MembersList _parentMemberslist,
                Pool _parentPool,
                uint _uniqueid,
                address _userid
                ) {

      id  = _uniqueid ;
      userid = _userid;

      parentMembersList = _parentMemberslist;
      parentPool = _parentPool;

      // set defaults

      string memory _AssetName;
      uint _AssetAmount;

      // Asset name to be use with the fixed
      // amount. (bnb,ether,crypt)
      (_AssetName, _AssetAmount) = parentPool.getRequirement_forContributionAsset();

      contributionAsset.Asset.Name = _AssetName;
      // Fixed Amount that every member spends per cycle.
      contributionAsset.Asset.Amount = _AssetAmount;

      // Asset name to be use by the member who
      // fails to contribute to the pool.
      // (bnb,ether,crypt)
      (_AssetName, _AssetAmount) = parentPool.getRequirement_forStakingAsset();

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
    Pool public parentPool;

    Member[] public listOfMembers;

    // MembersList working data
    uint256 uniqueID = 0; // Source of the auto generated id
    //----------------------------------
    // Modifiers
    //----------------------------------
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(Pool _parentPool) {

      parentPool = _parentPool;

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
    //----------------------------------
    // GUI Functions
    //----------------------------------
    function addNewMember(address _userid) public 
      returns (uint _uniqueId, uint _index){
       // First check if this member does exist using "user id"
       bool userAlreadyExists;
       (userAlreadyExists, _uniqueId, _index) = isThisUserAlreadyAMember(_userid);

       if (!userAlreadyExists) {
         _uniqueId = getNextUniqueId();

         Member _NewMember = new Member(this, parentPool, _uniqueId, _userid);
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
    
    function getKeyData_usingUniqueID(uint _uniqueId) public view 
      returns (bool _doesExist, address _userid) {
      
      uint _index;
      (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

      if (_doesExist) {
        Member _member = listOfMembers[_index]; 
        (_uniqueId, _userid) = _member.getKeyData();
      }  

    } // getKeyData_usingUniqueID()

    function setKeyData_usingUniqueID(uint _uniqueId, address _userid) public  {
      
      bool _doesExist;
      uint _index;
      (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

      if (_doesExist) {
        Member _member = listOfMembers[_index]; 
        _member.setKeyData(_userid);
      }  

    } // setKeyData_usingUniqueID()

    function getRequirement_forContributionAsset_usingUniqueID(uint _uniqueId) public view
      returns (bool _doesExist, string memory _Name, uint _Amount, address _walletAddress ) {
      
      uint _index;
      (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

      if (_doesExist) {
        Member _member = listOfMembers[_index]; 
        (_Name, _Amount, _walletAddress) = _member.getRequirement_forContributionAsset();
      }  
    } // getRequirement_forContributionAsset_usingUniqueID()

    function setRequirement_forContributionAsset_usingUniqueID(uint _uniqueId, string memory _Name, uint _Amount, address _walletAddress) 
      public {

      bool _doesExist;
      uint _index;
      (_doesExist, _index) = getMemberIndex_usingUniqueID(_uniqueId);

      if (_doesExist) {
        Member _member = listOfMembers[_index]; 
        _member.setRequirement_forContributionAsset(_Name, _Amount,  _walletAddress);
      }  

    } // setRequirement_forContributionAsset_usingUniqueID()



    //----------------------------------
    // External Functions
    //----------------------------------

}  // contract MembersList


contract Cycle{
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum CycleStatus {initialising,allocateWinner,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    uint private id;  // unique Identification for each Cycle.
    
    Pool private parentPool;
    MembersList private poolMembersList;

    uint cycleNo; // eg 1/10,2/10 etc

    Member WinningMember; // The member that won this round/cycle

    CycleStatus cycleStatus; // (initialising,allocateWinner,concluded)  

    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            cycleStatus == CycleStatus.initialising,
            "This task can only be done when Initialising this Pool Cycle."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenAllocatingWinnerForCycle() {
        require(
            cycleStatus == CycleStatus.allocateWinner,
            "This task can only be done when allocate Winner for this Pool Cycle."
        );
        _;
    } // onlyWhenAllocatingWinnerForCycle()

    modifier onlyWhenThePoolCycleHasConculded() {
        require(
            cycleStatus == CycleStatus.concluded,
            "This task can only be done when the Pool Cycle has Concluded."
        );
        _;
    } // onlyWhenThePoolCycleHasConculded()
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(uint256 _uniqueid, uint _cycleNo, Pool _parentPool, MembersList _poolMembersList) {

      id  = _uniqueid ;
      cycleNo = _cycleNo;

      parentPool = _parentPool;
      poolMembersList = _poolMembersList;

      cycleStatus = CycleStatus.initialising; 
    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
    function setWinningPoolMember(Member _member) public  {
      WinningMember = _member; 
    } // setWinningPoolMember()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    function getCycleNo() public view returns(uint256) {
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

    function isPooCycle_allocateWinner() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.allocateWinner);

    } // isPooCycle_allocateWinner()
  
    function isPooCycle_concluded() public view
      returns(bool _value) {
      
      _value = (cycleStatus == CycleStatus.concluded);

    } // isPooCycle_concluded()


} //contract Cycle 

contract CyclesList{
    //----------------------------------
    // Type definitions
    //----------------------------------
    //----------------------------------
    // Data
    //----------------------------------
    Pool public parentPool;
    MembersList public poolMembersList;

    Cycle[] public listOfCycles;

    // CycleList working data
    uint256 uniqueID = 0; // Source of the auto generated id

    Member[] public listOfEligiblePoolMembers;
    Member[] public listOfWinningPoolMembers;
    //----------------------------------
    // Modifiers
    //----------------------------------
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(Pool _parentPool, MembersList _poolMembersList) {

      parentPool = _parentPool;
      poolMembersList = _poolMembersList;

      initialiseAvailiableWinningMembersArray();

    } // constructor()
    //----------------------------------
    // Helper Functions
    //----------------------------------
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

    function selectAWinningMember_forThisCycle(Cycle _cycle) public returns(Member _winningMember) {
      // for testing the initial phase we will do Random
      //todo uint poolEligibleWinnersSize = listOfEligiblePoolMembers.length;
      //todo require(poolEligibleWinnersSize > 0);

      // find the ramdom winner
      //todo string memory _parm1 = Pool_Utils.integerToString(block.difficulty);
      //todo string memory _parm2 = Pool_Utils.integerToString(block.timestamp);
      //todo uint randomIndex = uint(keccak256(block.difficulty, block.timestamp)) % poolEligibleWinnersSize;
      
      uint randomIndex = 0; // todo      
      _winningMember = listOfEligiblePoolMembers[randomIndex];

      _cycle.setWinningPoolMember(_winningMember);

      // Remove from the eligible Winner list

      // Add to the already won members list

       //return cycleNo;
    } // selectAWinningMember_forThisCycle()



    //----------------------------------
    // GUI Functions
    //----------------------------------
    function addNewCycle() public 
      returns (uint _uniqueId, uint _index){
         _uniqueId = getNextUniqueId();

         uint _cycleNo = listOfCycles.length;

         Cycle _NewCycle = new Cycle(_uniqueId, _cycleNo, parentPool, poolMembersList);
         listOfCycles.push(_NewCycle);

         _index = listOfCycles.length -1;

    } // addNewCycle() 

    //----------------------------------
    // External Functions
    //----------------------------------


} //contract CyclesList 



