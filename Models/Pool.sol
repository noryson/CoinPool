// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract Pool {
    // Type definitions
    struct CryptoAsset {
        string Name;
        uint   Amount;
    }  // struct CryptoAsset 

    enum PoolStatus {initialising,ready,running,concluded} 
    
    // Key data
    uint private id;  // unique Identification for each pool event.
    uint256 private createdDate;   // Timestamp when the pool was created.
    uint private creator_ownerid;  // The "owner id" that created this pool.
                                   // The owner may or may not be a member of this pool.
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
    uint cycleInterval = 1;  // Total number of cycles intervals measured in days (week,month?) (days between cycles).    

    // Pool working data
    uint256 cycleStartDate;      // Timestamp that the cycle started.
    uint currentCycleNo = 0;     // The current cycle number
    uint currentNoOfMembers = 0; // The current number of menbers;

    uint256 UniqueID = 0; // Source of the auto generated id

    PoolStatus poolStatus; // (initialising,ready,running,concluded)  


    //----------------------------------
    // Funcions
    //----------------------------------
    constructor(uint _ownerid) public {
      id = getNextUniqueId();
      createdDate =  block.timestamp;
      creator_ownerid = _ownerid;

      // set defaults
      contributionAsset.Name = "bnb"; // Asset name to be use with the fixed amount. (bnb,ether,crypt)
      contributionAsset.Amount = 1;   // Fixed Amount that every contributor spends per cycle.

      stakingAsset.Name = "bnb"; // Asset name to be use if the contributor fails to contribut to the pool. (bnb,ether,crypt)
      stakingAsset.Amount = 1;   // staking amount to sufficiently prevent defaulers of this pool.

      poolStatus = PoolStatus.initialising; 

    } // constructor()

    //----------------------------------
    // Helper Funcions
    //----------------------------------
    function getNextUniqueId() private returns(uint256) {
       UniqueID++; 
       return UniqueID;
    } // getNextUniqueId()

    function getPoolStatus_asString() private view returns(string memory _poolStatusText) {

      if (poolStatus == PoolStatus.initialising) {
         // initialising
         _poolStatusText = "initialising";
      }
      else if (poolStatus == PoolStatus.ready) {
         // ready
         _poolStatusText = "ready";
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
      1. display pool details []
      2. display members in the pool
      3. display cycle details
      4. display the status of the pool (initialising,ready,running,concluded)


      5. edit pool details
      6. edit/add members participation in this pool
      
      7. remove members from the pool (only while still "initialising")
    */
    function getKeyData() public view 
      returns (uint _id, uint256 _createdDate, uint _creator_ownerid) {
      
       _id = id;
       _createdDate = createdDate;
       _creator_ownerid;

    } // getKeyData()

    function getRequirement_forContributionAsset() public view
      returns (string memory _Name, uint _Amount) {
      
       _Name = contributionAsset.Name;
       _Amount = contributionAsset.Amount;

    } // getRequirement_forContributionAsse()

    function getRequirement_forStakingAsset() public view
      returns (string memory _Name, uint _Amount) {
      
       _Name = stakingAsset.Name;
       _Amount = stakingAsset.Amount;

    } // getRequirement_forStakingAsset()

    function getRequirement_forMembers() public view
      returns (uint _maxNoOfMembers, uint _minNoOfMembers) {
      
       _maxNoOfMembers = maxNoOfMembers;
       _minNoOfMembers = minNoOfMembers;

    } // getRequirement_forMembers()

    function getRequirement_forcycles() public view
      returns (uint _cycleDuration, uint _cycleInterval) {
      
       _cycleDuration = cycleDuration;
       _cycleInterval = cycleInterval;

    } // getRequirement_forcycles()

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
      2. the ability to "run" this loop from the main looping mechanism
     */

    function isPool_initialising() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.initialising);

    } // isPool_initialising()

    function isPool_ready() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.ready);

    } // isPool_running()

    function isPool_running() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.running);

    } // isPool_running()
    function hasPool_concluded() public view
      returns(bool _value) {
      
      _value = (poolStatus == PoolStatus.concluded);

    } // hasPool_concluded()

    function runThisPool() public 
      returns(bool _value) {

      if (poolStatus == PoolStatus.ready) {
         uint MembersArraySize = 1; //PoolMember.Length; TODO
         if ((MembersArraySize >= minNoOfMembers ) && (MembersArraySize <= maxNoOfMembers)) {
            // Try to start Pool
            // Do first cycle 

            // TODO
            
            poolStatus = PoolStatus.running;
           _value = true; 
         }
         else {
          _value = false; 
         }
      }
      else {
        _value = false; 
      }      

    } // runThisPool()

} // contract Pool

