// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract Pool {
    //----------------------------------
    // Type definitions
    //----------------------------------
    struct CryptoAsset {
        string Name;
        uint   Amount;
    }  // struct CryptoAsset 

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
    CryptoAsset contributionAsset;

    /*  @invariants: assets supported are BNB, Ether and Cryptonite
        @invariants: stakedAsset != asset
    */ 
    CryptoAsset stakingAsset;

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

      stakingAsset.Name = "bnb"; // Asset name to be use if the contributor 
                                 // fails to contribut to the pool.
                                 // (bnb,ether,crypt)
      stakingAsset.Amount = 1;   // staking amount to sufficiently prevent 
                                 // defaulers of this pool.

      poolStatus = PoolStatus.initialising; 

    } // constructor()

    //----------------------------------
    // Helper Funcions
    //----------------------------------
    function getNextUniqueId() private returns(uint256) {
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

    function isSameStringValue(string memory _a, string memory _b)
      internal pure returns (bool) {
      if (bytes(_a).length != bytes(_b).length) {
        return false;
      } else {
        return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
      }
    } // isSameStringValue()


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
      
      if (!isSameStringValue(contributionAsset.Name,_Name)) {
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
      
      if (!isSameStringValue(stakingAsset.Name,_Name)) {
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
      returns (string memory _PoolStatusText) {
      
      _PoolStatusText = getPoolStatus_asString();

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

