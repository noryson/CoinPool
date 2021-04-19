// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "./Utils.sol";
import "./Member.sol";
import "./Cycle.sol";
import "./Vault.sol";

contract Pool {
    /* 
        @Project: CoinPool
        @Authors: noryson#5495, Zaphod#7887, jaytru#1997
        @Description: This contract keeps track of a single pool event.
    */

    //----------------------------------
    // Type definitions
    //----------------------------------
    enum PoolStatus {initialising,addingmembers,readytorun,running,concluded} 
    
    /* DATA ----------------------------------*/
    uint private id;  // unique Identification for each pool event.
    uint256 private creationDate;   // Timestamp when the pool was created.
    address private creator;  // The "owner address" that created this pool.
    string private poolName;  // the pool name that the pool owner assigns                                  
    /*  @invariants: assets supported are BNB, Ether and Cryptonite */
    Pool_Utils.CryptoAsset private contributionAsset;
    Pool_Utils.CryptoAsset private stakingAsset;
    uint8 private maxNoOfMembers;
    uint8 private minNoOfMembers;
    uint8 private numberOfCycles;  
    uint8 private cycleInterval;  // Total number of cycles intervals measured in days (week,month?) (days between cycles).    
    uint256 private cycleStartDate;  // Timestamp that the cycle started.
    uint8 private currentCycleNo;
    uint8 private currentNoOfMembers;
    PoolStatus private poolStatus;    // (initialising,addingmembers,readytorun, running,concluded)  
    
    MembersList private membersList;
    CyclesList private cyclesList;   // List of cycles that have already been run.
    
    VaultMap private vaultMap;
    address private owner;
    address private self;

    
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitialising() {
        require(poolStatus == PoolStatus.initialising, "This task can only be done when Initialising this Pool."); _;
    } // onlyWhenInitialising()

    modifier onlyWhenAddingMembers() {
        require(poolStatus == PoolStatus.addingmembers, "This task can only be done when Adding Members to this Pool."); _;
    } // onlyWhenAddingMembers()

    modifier onlyWhenItsReadyToRun() {
        require(poolStatus == PoolStatus.readytorun, "This task can only be done when this Pool is Ready to Run."); _;
    } // onlyWhenItsReadyToRun()

    modifier onlyWhenThePoolIsRunning() {
        require(poolStatus == PoolStatus.running, "This task can only be done when the Pool is Running."); _;
    } // onlyWhenThePoolIsRunning()

    modifier onlyWhenThePoolHasConculded() {
        require(poolStatus == PoolStatus.concluded, "This task can only be done when the Pool has Concluded."); _;
    } // onlyWhenThePoolHasConculded()


    /* EVENTS */
    event Stake(address indexed _stakerAddress, uint indexed _poolId, string _assetName, uint256 _amount);
    // event Join(address indexed _acccount, uint indexed _poolId);


    //----------------------------------
    // Functions
    //----------------------------------
    constructor(address _vaultAddress, address _owner, address _self, 
                string memory _name, address _creator, string memory _poolAsset, uint _assetAmount, 
                string memory _stakedAsset, uint _stakedAssetAmount, uint8 _maxNoOfMembers, uint8 _cycleInterval){
        
        
        vaultMap = VaultMap(_vaultAddress);
        
        id = Utils.generateRandomUint();
        creationDate =  block.timestamp;
        creator = _creator;
        poolName = _name;
        owner = _owner;
        self = _self;

        // set defaults
        contributionAsset.Name = _poolAsset; // Asset name to be use with the fixed amount. (bnb,ether,crypt)
        contributionAsset.Amount = _assetAmount;   // Fixed Amount that every contributor spends per cycle.

        stakingAsset.Name = _stakedAsset; // Asset name to be used when the contributor fails to contribute to the pool. (bnb,ether,crypt)
        stakingAsset.Amount = _stakedAssetAmount;   // staking amount to sufficiently prevent defaulers of this pool.
        
        minNoOfMembers = 2;
        maxNoOfMembers = _maxNoOfMembers;
        cycleInterval = _cycleInterval;
        cycleStartDate = Utils.timestampDays(1); // setting waiting period to 7 days by default.
        poolStatus = PoolStatus.addingmembers; 

        membersList = new MembersList(maxNoOfMembers); // List of all members that will be playing in this pool
    } // constructor()

    //----------------------------------
    // Helper Functions
    //----------------------------------
    // function getPoolStatus_asString() private view 
    //   returns(string memory _poolStatusText) {

    //   if (poolStatus == PoolStatus.initialising) {
    //      _poolStatusText = "initialising";
    //   }
    //   else if (poolStatus == PoolStatus.addingmembers) {
    //      _poolStatusText = "addingmembers";
    //   }
    //   else if (poolStatus == PoolStatus.readytorun) {
    //      _poolStatusText = "readytorun";
    //   }
    //   else if (poolStatus == PoolStatus.running) {
    //      _poolStatusText = "running";
    //   }
    //   else {
    //      _poolStatusText = "concluded";
    //   }
      
    // } // getPoolStatus_asString()

    //----------------------------------
    // GUI Functions
    //----------------------------------
    /*
      The aim for the GUI functions is to expose:
      1. display pool details
      2. display members in the pool TODO
      3. display cycle details (history?) TODO
      4. display the status of the pool (initialising,addingmembers,readytorun,running,concluded)
      5. edit pool details
      6. edit/add members participation in this pool (only while still "addingmembers") TODO
      7. remove members from the pool (only while still "addingmembers") TODO
    */

    function getPoolId() public view returns(uint) {
        return id;
    } // getPoolId()

    function getPoolName() public view returns (string memory) {
        return  poolName;
    } // getPoolName()

    // function getKeyData() public view 
    //   returns (uint _id, uint256 _creationDate, address _creator) {
    //     _id = id;
    //     _creationDate = creationDate;
    //     _creator = creator;
    // } // getKeyData()


    function getRequirement_forContributionAsset() public view
      returns (string memory _name, uint _amount) {
        _name = contributionAsset.Name;
        _amount = contributionAsset.Amount;
    } //getRequirement_forContributionAsset()

    function getRequirement_forStakingAsset() public view returns (string memory _name, uint _amount) {
        _name = stakingAsset.Name;
        _amount = stakingAsset.Amount;

    } // getRequirement_forStakingAsset()


    function getData_forMembers() public view
      returns (uint8 _maxNoOfMembers, uint8 _currentNoOfMembers) {
      _maxNoOfMembers = maxNoOfMembers;
      _currentNoOfMembers = uint8(membersList.getLength());

    } // getData_forMembers()

    // function getData_forCycles() public view
    //   returns (uint256 _cycleStartDate, uint _currentCycleNo) {
      
    //   _cycleStartDate = cycleStartDate;
    //   _currentCycleNo = currentCycleNo;

    // } // getData_forCycles()

    // function getData_forPool() public view
    //   returns (string memory _poolStatusText) {
      
    //   _poolStatusText = getPoolStatus_asString();

    // } // getData_forPool
    
    function getCycleInterval() public view returns(uint256){
        return cycleInterval;
    }
    
    function getCycleStartDate() public view returns(uint256){
        return cycleStartDate;
    }
    
    function getCurrentCycleNo() public view returns(uint8){
        return currentCycleNo;
    }
    
    function getMap_ofVaults() public view returns(VaultMap){
        return vaultMap;
    }


    function isPoolStatus_initialising() public view returns(bool) {
        if(poolStatus == PoolStatus.initialising)
            return true;
    } // isPoolStatus_initialising()

    function isPoolStatus_addingmembers() public view returns(bool) {
        if(poolStatus == PoolStatus.addingmembers)
            return true;
    } // isPoolStatus_addingmembers()
    
    function setPoolStatusTo_concluded() public {
        poolStatus = PoolStatus.concluded;
    } // setPoolStatusTo_addingmembers()

    function isPoolStatus_readytorun() public view returns(bool) {
        if(poolStatus == PoolStatus.readytorun)
            return true;
    } // isPoolStatus_readytorun()

    function isPoolStatus_running() public view returns(bool _value) {
        if(poolStatus == PoolStatus.running)
            return true;
    } // isPoolStatus_running()

    function isPoolStatus_concluded() public view returns(bool) {
        if(poolStatus == PoolStatus.concluded)
            return true;
    } // isPoolStatus_concluded()

    function runThisPool(CyclesList listInit) public /*onlyWhenItsReadyToRun*/ returns(bool _value) {
      // go live
      uint MembersArraySize = membersList.getLength();
      if ((MembersArraySize >= minNoOfMembers ) && (MembersArraySize <= maxNoOfMembers)) {
        // Try to start running Pool
        // Do first cycle....
        // -- Check that every pool member has the cycle paying amount.
        //    -- if not then remove from the staking amount

        cyclesList = listInit;
        cyclesList.addNewCycle();

        poolStatus = PoolStatus.running;
        _value = true; 
      }
      else {
        revert("This pool cannot run because of maximum and minimum number of members requirement"); 
      }
    } // runThisPool()

    function getMembersList() public view returns(MembersList _membersList){
      _membersList = membersList;
    }

    function getCyclesList() public view returns(CyclesList _cyclesList){
      _cyclesList = cyclesList;
    }
    
    function hasMember_withAccount(address _account) public view returns(bool){
        for(uint i=0; i<getMembersList().getLength(); i++){
            if(getMembersList().getMember_atIndex(i).getAccount() == _account){
                return  true;
            }
        }
        return false;
    }
    

    function stake(address _account)onlyWhenAddingMembers public {
        // (bool exist, uint index) = getMembersList().isThisUserAlreadyAMember(_account);
        
        Vault vault = vaultMap.getVault_withName(stakingAsset.Name);
        vault.transferStake_toPool(_account, getPoolId(), stakingAsset.Amount);
        
        emit Stake(_account, getPoolId(), stakingAsset.Name, stakingAsset.Amount);
    }// stake()
    
    
    function join(address _account) onlyWhenAddingMembers public{
        (bool exist, uint index) = getMembersList().isThisUserAlreadyAMember(_account);
        membersList.addNewMember(_account);
    }
    
    function pay_toCycle(address _account) onlyWhenThePoolIsRunning public{
        (bool exist, uint index) = getMembersList().isThisUserAlreadyAMember(_account);
        require(exist, "This member does not exist");
        getCyclesList().pay_toCurrentCycle(getMembersList().getMember_atIndex(index));
    }
    
    // function concludeCycle() onlyWhenThePoolIsRunning public{
    //     getCyclesList().selectAWinningMember_forThisCycle();
    // }

} // contract Pool

contract PoolsList{
    //----------------------------------
    // Type definitions
    //----------------------------------
    enum Status {INITIALIZING,READY}
    
    //----------------------------------
    // Data
    //----------------------------------
    address private owner;
    address private self;
    VaultMap private vaultMap;
    Status private status;
    address[] private listOfPools;
    
    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyWhenInitializing(){
        require(status == Status.INITIALIZING); _;
    }
    
    modifier onlyWhenReady(){
        require(status == Status.READY); _;
    }
    
    // Events
    event AddNewPool(uint _poolId);
    
    //----------------------------------
    // Functions
    //----------------------------------
    constructor(address _vaultAddress, address _owner, address _self) {
        vaultMap = VaultMap(_vaultAddress);
        owner = _owner;
        self = _self;
        status = Status.READY;
    } // constructor()
    
    function addNewPool(string memory _name, address _creator, string memory _poolAsset, 
                        uint256 _assetAmount, string memory _stakedAsset, uint8 _maxNoOfMembers, 
                        uint8 _cycleInterval) public returns (uint _id, uint256 _stakedAssetAmount){
        
        for(uint i=0; i<vaultMap.getNo_ofVaults(); i++){
            if(Utils.compareString(vaultMap.getVaultNames()[i], _poolAsset)){
                break;
            }
            else if(vaultMap.getNo_ofVaults() == (i+1)){
                revert("Pool asset not supported");
            }
        }
        
        for(uint i=0; i<vaultMap.getNo_ofVaults(); i++){
            if(Utils.compareString(vaultMap.getVaultNames()[i], _stakedAsset)){
                break;
            }
            else if(vaultMap.getNo_ofVaults() == (i+1)){
                revert("Staked asset not supported");
            }
        }
        
        // require(!Utils.compareString(_stakedAsset, _poolAsset), "Pool asset must differ from stake asset");
        
        // get conversion rate and multiple by maxNoOfMembers
        uint256 _conversionRate = 1;
        _stakedAssetAmount = _conversionRate * _maxNoOfMembers; 

        Pool newPool = new Pool(address(vaultMap), owner, self, _name, _creator, _poolAsset, _assetAmount,
                                _stakedAsset, _stakedAssetAmount, _maxNoOfMembers, _cycleInterval);

        listOfPools.push(address(newPool));

        _id = newPool.getPoolId();

    } // addNewPool() 
    
    //----------------------------------
    // Helper Functions
    //----------------------------------
    
    // function getAuctions() public returns(Cycle[] memory){
        
    // }
    
    function getRunningPools_withAccount(address _account) public view returns(Pool[] memory){
        uint count;
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_running() && pool.hasMember_withAccount(_account)){
                count++;
            }
        }
        
        Pool[] memory runningPools = new Pool[](count);
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_running() && pool.hasMember_withAccount(_account)){
                runningPools[count] = pool;
                count--;
            }
        }
        return runningPools;
    }
    
    function getConcludedPools_withAccount(address _account) public view returns(Pool[] memory){
        uint count;
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_concluded() && pool.hasMember_withAccount(_account)){
                count++;
            }
        }
        
        Pool[] memory concludedPools = new Pool[](count);
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_concluded() && pool.hasMember_withAccount(_account)){
                concludedPools[count] = pool;
                count--;
            }
        }
        return concludedPools;
    }
    
    function getPendingPools_withAccount(address _account) public view returns(Pool[] memory){
        uint count;
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_addingmembers() && pool.hasMember_withAccount(_account)){
                count++;
            }
        }
        
        Pool[] memory pendingPools = new Pool[](count);
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_addingmembers() && pool.hasMember_withAccount(_account)){
                pendingPools[count] = pool;
                count--;
            }
        }
        return pendingPools;
    }
    
    function getRunningPools() public view returns(Pool[] memory){
        uint count;
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_running()){
                count++;
            }
        }
        
        Pool[] memory runningPools = new Pool[](count);
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_running()){
                count--;
                runningPools[count] = pool;
            }
        }
        return runningPools;
    }
    
    function getConcludedPools() public view returns(Pool[] memory){
        uint count;
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_concluded()){
                count++;
            }
        }
        
        Pool[] memory concludedPools = new Pool[](count);
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_concluded()){
                count--;
                concludedPools[count] = pool;
            }
        }
        return concludedPools;
    }
    
    function getPendingPools() public view returns(Pool[] memory){
        uint count;
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_addingmembers() || pool.isPoolStatus_initialising()){
                count++;
            }
        }
        
        Pool[] memory pendingPools = new Pool[](count);
        for(uint i=0; i<getLength(); i++){
            Pool pool = getPool_atIndex(i);
            if(pool.isPoolStatus_addingmembers() || pool.isPoolStatus_initialising()){
                count--;
                pendingPools[count] = pool;
            }
        }
        return pendingPools;
    }
    
    function getLength() public view returns(uint) {
       return listOfPools.length;
    } // getLength()

    function getPool_atIndex(uint _index) public view returns(Pool) {
       require(_index < listOfPools.length);
       return Pool(listOfPools[_index]);
    } // getPool_atIndex()

    // function removePool_atIndex(uint _index) public {
    //   // Move the last element to the deleted spot.
    //   // Delete the last element, then correct the length.
    //   require(_index < listOfPools.length);

    //   // Only allowed to remove this pool if is in "initialisation" status.
    //   Pool _pool = Pool(listOfPools[_index]);
    //   require(_pool.isPoolStatus_initialising());
      
    //   listOfPools[_index] = listOfPools[listOfPools.length-1];
    //   listOfPools.pop();

    // } // removePool_atIndex()

    function getPool_withId(uint _id) public view returns(Pool) {
      for(uint i=0; i<getLength(); i++){
          if(getPool_atIndex(i).getPoolId() == _id)
                return getPool_atIndex(i);
      }
      revert("Pool does not exist");
    } // getPool_withId()
    
    //----------------------------------
    // External Functions
    //----------------------------------


} //contract PoolsList 