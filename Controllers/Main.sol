pragma solidity >=0.6.2;

import "../Models/Pool.sol";
import "../Models/Vault.sol";
import "../Models/Utils.sol";
import "../Models/Cycle.sol";
// import "../Models/CoinPoolToken.sol";

contract Main{
    /* 
        @Project: CoinPool
        @Authors: noryson#5495, 
        @Description: This contract functions as the sole controller. All web3.js calls will directly interact 
                        with the functions here.
    */
    
    // type definitions
    enum Status {INITIALIZING,RUNNING}

    // working data
    address private owner;
    address private self;
    Status private status;
    PoolsList private listOfPools;
    VaultMap private mapOfVaults;

    // modifiers
    modifier onlyWhenRunning(){
        require(status == Status.RUNNING, "Contract is not running"); _;
    }

    modifier onlyWhenInitializing(){
        require(status == Status.INITIALIZING, "Contract is not initializing"); _;
    }
    
    modifier onlyWhenAccount_isConnected(){
        require(isAccountConnected(msg.sender), "Account is not connected"); _;
    }

    // events

    /* functions */
    constructor(/*Utils.Token memory _token1*/){
        status = Status.INITIALIZING;
        owner = msg.sender;
        self = address(this);
        
        mapOfVaults = new VaultMap(owner, self);
        
        mapOfVaults.init();
        // mapOfVaults.addNewToken(_token1.name, _token1.deployedAddress);
        // initialize contract's local Token
        // CoinPoolToken cT= new CoinPoolToken();
        // address cTAddress = address(cT);
        // mapOfVaults.addNewToken("CT", cTAddress);
        mapOfVaults.addNewVault("BNB");
        mapOfVaults.addNewVault("ETH");
        mapOfVaults.enable();
        
        mapOfVaults.addNewAccount(owner);
        mapOfVaults.addNewAccount(self);
        
        listOfPools = new PoolsList(address(mapOfVaults), owner, self);
        status = Status.RUNNING;
    }
    
    function isAccountConnected(address _account)onlyWhenRunning public view returns(bool){
        return getMap_ofVaults().isAccountConnected(_account);
    }

    function connectSelf_toVaults() onlyWhenRunning public{
        address _account = msg.sender;
        getMap_ofVaults().addNewAccount(_account);
    }

    function depositAsset(string memory _assetName, uint256 _amount)
    onlyWhenRunning onlyWhenAccount_isConnected payable public{
        getMap_ofVaults().depositAsset{value:msg.value}(_assetName, _amount, msg.sender);
    }
    
    function withdrawAsset(string memory _assetName, uint256 _amount, address _receiver)
    onlyWhenRunning onlyWhenAccount_isConnected payable public{
        getMap_ofVaults().withdrawAsset(_assetName, _amount, msg.sender, _receiver);
    }
    
    function dashboard() onlyWhenRunning onlyWhenAccount_isConnected public
    returns(Utils.AccountSummary[] memory sum){
        address _account = msg.sender;
        sum = getMap_ofVaults().getAccountStatement(_account);
    }
    
    function viewRunningPools()onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getRunningPools();
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }
    
    function viewConcludedPools()onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getConcludedPools();
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }
    
    function viewPendingPools()onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getPendingPools();
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }

    function viewPool(uint _poolId)onlyWhenRunning onlyWhenAccount_isConnected public view  
    returns(Pool){
        return getList_ofPools().getPool_withId(_poolId);
    }
    
    function viewCycle(uint _poolId, uint _cycleNo)onlyWhenRunning onlyWhenAccount_isConnected public
    returns(Cycle){
        return getList_ofPools().getPool_withId(_poolId).getCyclesList().getCycle_atIndex(_cycleNo -1);
    }

    function joinPool(uint _poolId)onlyWhenRunning onlyWhenAccount_isConnected public{
        address _account = msg.sender;
        getList_ofPools().getPool_withId(_poolId).join(_account);
        getList_ofPools().getPool_withId(_poolId).stake(_account);
    }

    function payPoolCycle(uint _poolId)onlyWhenRunning onlyWhenAccount_isConnected payable public{
        getList_ofPools().getPool_withId(_poolId).pay_toCycle(msg.sender);
    }

    function createPool(string memory _nameOfPool, string memory _poolAsset, string memory _stakeAsset)
    onlyWhenRunning onlyWhenAccount_isConnected public returns(uint _id, uint256 _stakeAssetAmount){
        (_id, _stakeAssetAmount) = getList_ofPools().addNewPool(_nameOfPool, msg.sender, _poolAsset, 100, _stakeAsset, 10, 1);
        joinPool(_id);
    }
    
    event Check(uint256 nows, uint256 then);
    
    function servicePool(uint _id) public returns(bool){
        Pool pool = getList_ofPools().getPool_withId(_id);
        require(!pool.isPoolStatus_concluded(), "This pool has ended");
        
        //begin pending pools
        emit Check(block.timestamp, pool.getCycleStartDate());
        if(pool.isPoolStatus_addingmembers() && block.timestamp > pool.getCycleStartDate()){
            // pool.cycleStartDate = block.timestamp;
            pool.runThisPool(new CyclesList(pool));
            return true; 
        }
        
        //select winners, conclude cycles, auction assets, pay users, initiate new cycles or conclude pool with no more cycles left
        if(pool.isPoolStatus_running() && block.timestamp > pool.getCycleStartDate() 
            + (pool.getCurrentCycleNo() * Utils.timestamp(pool.getCycleInterval()))){
                
            pool.getCyclesList().selectAWinningMember_forThisCycle();
             return true;
        }
        
        return false;
    }

    // Helpers and checkers
    
    //getters and setters
    
    function getMap_ofVaults()onlyWhenRunning public view returns(VaultMap){
        return mapOfVaults;
    }
    
    function getList_ofPools()onlyWhenRunning public view returns(PoolsList){
        return listOfPools;
    }
    
    function getOwner() public view returns(address){
        return owner;
    }
    
    function getContractAddress() public view returns(address){
        return self;
    }
    
    
}
