pragma solidity >=0.6.2;

import "../Models/Pool.sol";
import "../Models/Vault.sol";
import "../Models/Utils.sol";
import "../Models/Cycle.sol";
import "../ERC20_tokens/CoinPoolToken.sol";

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
    address public coinPoolTokenAddress;
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
    constructor(/*address[] memory externalTokens*/){
        status = Status.INITIALIZING;
        owner = msg.sender;
        self = address(this);
        
        mapOfVaults = new VaultMap(owner, self);
        mapOfVaults.init();
        
        // link external tokens with their addresses
        // mapOfVaults.addNewToken(_token1.name, _token1.deployedAddress);
        CoinPoolToken nRC= new CoinPoolToken(21000000000000000000000, "NorysonCoin", "NRC");
        address nRCAddress = address(nRC);
        
        CoinPoolToken mDT= new CoinPoolToken(21000000000000000000000, "MieldToken", "MDT");
        address mDTAddress = address(mDT);
        
        CoinPoolToken yhwh= new CoinPoolToken(21000000000000000000000, "YahwehCoin", "YHWH");
        address yhwhAddress = address(yhwh);
        
        CoinPoolToken zC= new CoinPoolToken(21000000000000000000000, "ZaphCoin", "ZC");
        address zcAddress = address(zC);
        
        // initialize contract's local Tokens
        CoinPoolToken cT= new CoinPoolToken(21000000000000000000000, "CoinPoolToken", "CT");
        coinPoolTokenAddress = address(cT);
        
        // create vaults for tokens
        mapOfVaults.addNewToken(cT.symbol(), coinPoolTokenAddress);
        mapOfVaults.addNewToken(nRC.symbol(), nRCAddress);
        mapOfVaults.addNewToken(mDT.symbol(), mDTAddress);
        mapOfVaults.addNewToken(yhwh.symbol(), yhwhAddress);
        mapOfVaults.addNewToken(zC.symbol(), zcAddress);
        
        // create vaults for onchain assets
        mapOfVaults.addNewVault("BNB");
        mapOfVaults.enable();
        
        // connect local accounts to all vaults
        mapOfVaults.addNewAccount(owner);
        mapOfVaults.addNewAccount(self);
        
        listOfPools = new PoolsList(address(mapOfVaults), owner, self);
        status = Status.RUNNING;
        
        // transfer CTokens to contract creator and pools
        cT.transfer(owner, 1000000000000000000);
        cT.transfer(0x680f520a98177c18a305aAA8523b26228bc05d31, 1000000000000000000000);
        cT.transfer(0x78760030Bd9c50E7ee0CE0b8E2829095EEC0ef41, 10000000000000000000000);
        
        nRC.transfer(owner, 1000000000000000000);
        nRC.transfer(0x680f520a98177c18a305aAA8523b26228bc05d31, 10000000000000000000000);
        nRC.transfer(0x78760030Bd9c50E7ee0CE0b8E2829095EEC0ef41, 10000000000000000000000);
        
        mDT.transfer(owner, 1000000000000000000);
        mDT.transfer(0x680f520a98177c18a305aAA8523b26228bc05d31, 10000000000000000000000);
        mDT.transfer(0x78760030Bd9c50E7ee0CE0b8E2829095EEC0ef41, 10000000000000000000000);
        
        yhwh.transfer(owner, 1000000000000000000);
        yhwh.transfer(0x680f520a98177c18a305aAA8523b26228bc05d31, 10000000000000000000000);
        yhwh.transfer(0x78760030Bd9c50E7ee0CE0b8E2829095EEC0ef41, 1000000000000000000);
        
        zC.transfer(owner, 1000000000000000000);
        zC.transfer(0x680f520a98177c18a305aAA8523b26228bc05d31, 10000000000000000000000);
        zC.transfer(0x78760030Bd9c50E7ee0CE0b8E2829095EEC0ef41, 10000000000000000000000);
        
        cT.transfer(address(listOfPools), 1000000000000000000000);
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
    
    function dashboard() onlyWhenRunning onlyWhenAccount_isConnected public view
    returns(Utils.AccountSummary[] memory sum){
        address _account = msg.sender;
        sum = getMap_ofVaults().getAccountStatement(_account, viewRunningPools_withAccount(_account), viewPendingPools_withAccount(_account));
    }
    
    function viewRunningPools()onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getRunningPools();
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }
    
    function viewRunningPools_withAccount(address _account)onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getRunningPools_withAccount(_account);
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }
    
    // function viewConcludedPools()onlyWhenRunning onlyWhenAccount_isConnected public view 
    // returns(uint[] memory ){
    //     Pool[] memory pool = getList_ofPools().getConcludedPools();
    //     uint[] memory poolId = new uint[](pool.length);
    //     for(uint i=0; i<pool.length; i++)
    //         poolId[i] = pool[i].getPoolId();
    //     return poolId;
    // }
    
    function viewPendingPools()onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getPendingPools();
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }
    
    function viewPendingPools_withAccount(address _account)onlyWhenRunning onlyWhenAccount_isConnected public view 
    returns(uint[] memory ){
        Pool[] memory pool = getList_ofPools().getPendingPools_withAccount(_account);
        uint[] memory poolId = new uint[](pool.length);
        for(uint i=0; i<pool.length; i++)
            poolId[i] = pool[i].getPoolId();
        return poolId;
    }
    
    function viewPool(uint _poolId)onlyWhenRunning onlyWhenAccount_isConnected 
        public view returns(uint id, string memory poolName, string memory poolAssetName, uint256 poolAssetAmount,
                string memory stakeAssetName, uint256 stakeAssetAmount, uint8 maxNoOfMembers,   
                uint8 currentCycleNo, uint8 currentNoOfMembers, string memory poolStatus){
                    
        Pool pool = getList_ofPools().getPool_withId(_poolId);
        
        id = pool.getPoolId();
        poolName = pool.getPoolName();
        poolStatus = pool.getPoolStatus_asString();
        (poolAssetName, poolAssetAmount) = pool.getRequirement_forContributionAsset();
        (stakeAssetName, stakeAssetAmount) = pool.getRequirement_forStakingAsset();
        (maxNoOfMembers, currentNoOfMembers) = pool.getData_forMembers();
        currentCycleNo = pool.getCurrentCycleNo();
    }
    
    function viewCycle(uint _poolId, uint _cycleNo)onlyWhenRunning onlyWhenAccount_isConnected public view
    returns(address[10] memory members,  address[10] memory payedMembers, address winner, string memory cycleStatus, uint256 l1, uint256 l2){
        // Member[] private auctioningMembers;
        
        Cycle cycle = getList_ofPools().getPool_withId(_poolId).getCyclesList().getCycle_atIndex(_cycleNo -1);
        // address[] memory allMembers = new address[](cycle.getMemberList().getLength());
        for(uint8 i=0; i<cycle.getMemberList().getLength(); i++){
            members[i] = cycle.getMemberList().getMember_atIndex(i).getAccount();
        }
        
        // address[] memory payed = new address[](cycle.getPayedMembers().length);
        for(uint8 i=0; i<cycle.getPayedMembers().length; i++){
            payedMembers[i] = cycle.getPayedMembers()[i].getAccount();
        }
        
        l1 = cycle.getMemberList().getLength();
        l2 = cycle.getPayedMembers().length;
        
        if(address(cycle.getWinner()) != address(0x0))
            winner = cycle.getWinner().getAccount();
            
        cycleStatus = cycle.getCycleStatus_asString();
    }
    
    
    function buyStake(uint poolId, address member) public{
        getList_ofPools().getPool_withId(poolId).getCyclesList().getCurrentCycle().buyStake(member, msg.sender);
        // servicePool(poolId);
    }
    
    
    // function viewAuctionedMembers(uint id, uint no) public view returns(address){
    //     return getList_ofPools().getPool_withId(id).getCyclesList().getCurrentCycle().getAuctioningMembers()[no].getAccount();
    // }
    
    
    function viewAuctionedStakes() public view returns(Utils.Auction[10] memory auctions, uint8 count){
        return ext1.viewAuctionedStakes(getList_ofPools());
    }

    function joinPool(uint _poolId)onlyWhenRunning onlyWhenAccount_isConnected public{
        address _account = msg.sender;
        getList_ofPools().getPool_withId(_poolId).join(_account);
        getList_ofPools().getPool_withId(_poolId).stake(_account);
    }

    function payPoolCycle(uint _poolId)onlyWhenRunning onlyWhenAccount_isConnected payable public{
        getList_ofPools().getPool_withId(_poolId).pay_toCycle(msg.sender);
    }

    function createPool(string memory _name, string memory _poolAsset, uint256 _assetAmount, string memory _stakedAsset)
    onlyWhenRunning onlyWhenAccount_isConnected public returns(uint _id, uint256 _stakeAssetAmount){
        (_id, _stakeAssetAmount) = getList_ofPools().addNewPool(_name, msg.sender, _poolAsset, _assetAmount, _stakedAsset, 10, 1);
        joinPool(_id);
    }
    
    // event Check(uint256 nows, uint256 then);
    
    function servicePool(uint _id) public returns(bool){
        return ext1.servicePool(_id, getList_ofPools());
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
    
    function getTokenAddress(string memory tokenName) public view returns(address){
        return getMap_ofVaults().getTokenAddress_withName(tokenName);
    }
    
    
}
