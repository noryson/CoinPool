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
    uint private creator_ownerid;  // The "owner id" that created this pool.
                                   // The owner may or may not be a member 
                                   // of this pool.
    // Pool parameters                                  
    /*  @invariants: assets supported are BNB, Ether and Cryptonite */
    Pool_util.CryptoAsset contributionAsset;

    /*  @invariants: assets supported are BNB, Ether and Cryptonite
        @invariants: stakedAsset != asset
    */ 
    Pool_util.CryptoAsset stakingAsset;

    uint maxNoOfMembers = 1; // Maximum number of contributors.
    uint minNoOfMembers = 1; // Minimum number of contributors.

    uint cycleDuration = 1;  // Total number of cycles.    
    uint cycleInterval = 1;  // Total number of cycles intervals 
                             // measured in days (week,month?) 
                             // (days between cycles).    

    // Pool working data
    uint256 cycleStartDate;      // Timestamp that the cycle started.
    uint currentCycleNo = 0;     // The current cycle number
    uint currentNoOfMembers = 0; // The current number of menbers;

    uint256 UniqueID = 0; // Source of the auto generated id

    PoolStatus poolStatus; // (initialising,addingmembers,readytorun,
                           //  running,concluded)  

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
    // Funcions
    //----------------------------------
    constructor(uint _ownerid) {
      id = getNextUniqueId();
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
                                 // defaulers of this pool.

      poolStatus = PoolStatus.initialising; 

    } // constructor()

    //----------------------------------
    // Helper Funcions
    //----------------------------------
    function getNextUniqueId() public returns(uint256) {
       UniqueID++; 
       return UniqueID;
    } // getNextUniqueId()

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
    // GUI Funcions
    //----------------------------------
    /*
      The aim for the GUI functions is to expose:
      1. display pool details
      2. display members in the pool TODO
      3. display cycle details (history?) TODO
      4. display the status of the pool (initialisin,addingmembers,readytorun,
         running,concluded)


      5. edit pool details
      6. edit/add members participation in this pool 
         (only while still "addingmembers") TODO
      
      7. remove members from the pool (only while still "addingmembers") TODO
    */
    function getKeyData() public view 
      returns (uint _id, uint256 _createdDate, uint _creator_ownerid) {
      
       _id = id;
       _createdDate = createdDate;
       _creator_ownerid = creator_ownerid;

    } // getKeyData()

    function setKeyData( uint _creator_ownerid) public onlyWhenInitialising {
      
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
      
      if (!Pool_util.isSameStringValue(contributionAsset.Name,_Name)) {
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
      
      if (!Pool_util.isSameStringValue(stakingAsset.Name,_Name)) {
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
      returns (uint _cycleDuration, uint _cycleInterval) {
      
       _cycleDuration = cycleDuration;
       _cycleInterval = cycleInterval;

    } // getRequirement_forcycles()

    function setRequirement_forcycles(uint _cycleDuration, uint _cycleInterval) 
      public onlyWhenInitialising {
      
      if (cycleDuration != _cycleDuration){
        cycleDuration = _cycleDuration;
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
        // -- Check that every pool member has the cycle payin amount.
        //    -- if not then remove from the staking amount

        // TODO

        poolStatus = PoolStatus.running;
        _value = true; 
      }
      else {
        _value = false; 
      }
    } // runThisPool()

} // contract Pool

library Pool_util {

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
    // Funcions
    //----------------------------------
    function isSameStringValue(string memory _a, string memory _b)
      internal pure returns (bool) {
      if (bytes(_a).length != bytes(_b).length) {
        return false;
      } else {
        return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
      }
    } // isSameStringValue()

} // Pool_util

contract Member {
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum MemberStatus {initialising,readytoverify,readytorun,running,concluded} 
    //----------------------------------
    // Data
    //----------------------------------
    uint private id;  // unique Identification for each Member.
    uint private memberid;  // The "member id" of of the member that joined this pool.

    Pool_util.CryptoAssetWithAddress contributionAsset;
    Pool_util.CryptoAssetWithAddress stakingAsset;
    Pool_util.CryptoAssetWithAddress payoutAsset;

    MemberStatus memberStatus; // (initialising,readytoverify,readytorun,
                               //  running,concluded)  
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(
            memberStatus == MemberStatus.initialising,
            "This task can only be done while Initialising this Member."
        );
        _;
    } // onlyWhenInitialising()

    modifier onlyWhenReadyToVerfyMember() {
        require(
            memberStatus == MemberStatus.readytoverify,
            "This task can only be done when verifing this member."
        );
        _;
    } // onlyWhenAddingMembers()

    modifier onlyWhenItsReadyToRun() {
        require(
            memberStatus == MemberStatus.readytorun,
            "This task can only be done when this Member is Ready to participate in the Pool."
        );
        _;
    } // onlyWhenItsReadyToRun()

    modifier onlyWhenThePoolIsRunning() {
        require(
            memberStatus == MemberStatus.running,
            "This task can only be done while the Member is an active part of the Pool."
        );
        _;
    } // onlyWhenThePoolIsRunning()

    modifier onlyWhenThePoolHasConculded() {
        require(
            memberStatus == MemberStatus.concluded,
            "This task can only be done after the pool has been concluded for this Member ."
        );
        _;
    } // onlyWhenThePoolHasConculded()
    //----------------------------------
    // Funcions
    //----------------------------------
    constructor(Pool _ParentPool,
                uint _memberid,
                string memory _contributionAsset_Name,
                uint _contributionAsset_Amount,
                string memory _stakingAsset_Name,
                uint _stakingAsset_Amount
                ) {
      id = _ParentPool.getNextUniqueId();
      memberid = _memberid;

      // set defaults

      // Asset name to be use with the fixed
      // amount. (bnb,ether,crypt)
      contributionAsset.Asset.Name = _contributionAsset_Name; 
      // Fixed Amount that every member spends per cycle.
      contributionAsset.Asset.Amount = _contributionAsset_Amount;

      // Asset name to be use by the member who
      // fails to contribute to the pool.
      // (bnb,ether,crypt)
      stakingAsset.Asset.Name = _stakingAsset_Name; 
      // staking amount to be used as colateral.
      stakingAsset.Asset.Amount = _stakingAsset_Amount;   

      // Asset name to be use by the member for payouts 
      // (bnb,ether,crypt)
      payoutAsset.Asset.Name = _contributionAsset_Name; 
      payoutAsset.Asset.Amount = 0;   // payout amount.

      memberStatus = MemberStatus.initialising;

    } // constructor()
    //----------------------------------
    // Helper Funcions
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
    // GUI Funcions
    //----------------------------------
    function getKeyData() public view 
      returns (uint _id, uint _memberid) {
      
       _id = id;
       _memberid = memberid;

    } // getKeyData()

    function setKeyData(uint _memberid) public onlyWhenInitialising {
      
      if (memberid != _memberid){
       memberid = _memberid;
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
      
      if (!Pool_util.isSameStringValue(contributionAsset.Asset.Name,_Name)) {
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
      
      if (!Pool_util.isSameStringValue(stakingAsset.Asset.Name,_Name)) {
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
      
      if (!Pool_util.isSameStringValue(payoutAsset.Asset.Name,_Name)) {
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
      // The member is now wishing to run the pool (go live).
      memberStatus = MemberStatus.readytorun;

    } // setMemberStatusTo_readytorun()

    function isMemberStatus_running() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.running);

    } // isMemberStatus_running()

    function setMemberStatusTo_running() public onlyWhenItsReadyToRun {

      memberStatus = MemberStatus.readytorun;

    } // setMemberStatusTo_running()

    function isMemberStatus_concluded() public view
      returns(bool _value) {
      
      _value = (memberStatus == MemberStatus.concluded);

    } // isMemberStatus_concluded()

    function setMemberStatusTo_concluded() public onlyWhenThePoolIsRunning {

      memberStatus = MemberStatus.concluded;

    } // setMemberStatusTo_concluded()


}

