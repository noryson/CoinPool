
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "../Interfaces/InterfaceERC20.sol";
import "../Interfaces/InterfaceBEP20.sol";
import "./Utils.sol";

contract Vault{
    /* 
        @Project: CoinPool
        @Authors: noryson#5495, Zaphod#7887, jaytru#1997
        @Description: This is the vault implementation.
    */

    /* Type definitions */
    enum Status{ENABLED, DISABLED}

    /* Data */
    string private assetName;
    Status private status;
    address[] private accounts;
    mapping(address => uint256) private balance;
    mapping(uint=>mapping(address=>uint256)) private poolStakeBalance;
    mapping(uint=>mapping(address=>uint256)) private poolContributionBalance;

    /* Modifiers */
    modifier onlyWhenEnabled(){
        require(status == Status.ENABLED, "Asset disabled"); _;
    }

    /* Events */
    event Deposit(address indexed _sender, uint256 _amount);
    event Withdraw(address indexed _receiver, uint256  _amount);
    event Transfer(address indexed _sender, address indexed _receiver, uint256 _amount);
    event TransferContributionToPool(uint indexed _poolId, address indexed _sender, uint256 _amount);
    event TransferStakeToPool(uint indexed _poolId, address indexed _sender, uint256 indexed _amount);
    event TransferContributionFromPool(uint indexed _poolId, address  indexed _sender, address indexed _receiver, uint256 _amount);
    event TransferStakeFromPool(uint indexed _poolId, address indexed _sender, address indexed _receiver, uint256 _amount);

    /* Functions */
    constructor(string memory _assetName) {
        assetName = _assetName;
        status = Status.ENABLED;
    } // constructor()
    
    
    function deposit(address _depositor, uint256 _amount) public payable{
        balance[_depositor] += _amount;
        emit Deposit(_depositor, _amount);
    }
    
    function withdraw(uint256 _amount, address _receiver, address _sender) public payable{
        require(balance[_sender] >= _amount, "Insufficient funds");
        balance[_sender] -= _amount;
        emit Withdraw(_sender, _amount);
    } // withdraw()

    function transfer(address _sender, address _receiver, uint256 _amount)payable public{
        require(balance[_sender] >= _amount, "Insufficient funds");
        balance[_sender] -= _amount;
        balance[_receiver] += _amount;
        emit Transfer(_sender, _receiver, _amount);
    }// transfer()
    
    function transferContribution_toPool(address _sender, uint _poolId, uint256 _amount) public{
        require(balance[_sender] >= _amount, "Insufficient funds");
        balance[_sender] -= _amount;
        poolContributionBalance[_poolId][_sender] += _amount;
        emit TransferContributionToPool(_poolId, _sender, _amount);
    }
    
    function transferContribution_fromPool(uint _poolId, address _sender, address _receiver, uint256 _amount)
    public{
        require(poolContributionBalance[_poolId][_sender] >= _amount, "Insufficient funds");
        poolContributionBalance[_poolId][_sender] -= _amount;
        balance[_receiver] += _amount;
        emit TransferContributionFromPool(_poolId, _sender, _receiver, _amount);
    }
    
    function transferStake_toPool(address _sender, uint _poolId, uint256 _amount) public{
        require(balance[_sender] >= _amount, "Insufficient funds");
        balance[_sender] -= _amount;
        poolStakeBalance[_poolId][_sender] += _amount;
        emit TransferStakeToPool(_poolId, _sender, _amount);
    }
    
    function transferStake_fromPool(uint _poolId, address _sender, address _receiver, uint256 _amount)
    public{
        require(poolStakeBalance[_poolId][_sender] >= _amount, "Insufficient funds");
        poolStakeBalance[_poolId][_sender] -= _amount;
        balance[_receiver] += _amount;
        emit TransferStakeFromPool(_poolId, _sender, _receiver, _amount);
    }

    function connectAccount(address _account) public{
        for(uint i=0; i<getNo_ofAccounts(); i++){
            if(accounts[i] == _account){
                revert("Acount already connected");
            }
        }
        balance[_account] = 0;
    }

    /* Helpers */
    function getTotalBalance_ofVault() public view returns(uint256 _totalBalance) {
        _totalBalance;
        for(uint256 i=0; i<getNo_ofAccounts(); i++){
            _totalBalance += balance[accounts[i]];
        }
    } // getTotalBalance_ofVault()

    function getBalance_ofAccount(address _account) public view returns(uint256) {
        return balance[_account];
    } // getBalance_ofAccount()

    function getNo_ofAccounts() public view returns(uint256){
        return accounts.length;
    }// getNo_ofAccounts()
    
    function getAssetName() public returns(string memory){
        return assetName;
    }
    
    function getPoolContributionBalance_withAccount(uint _poolId, address _account) public view returns(uint256){
        return poolContributionBalance[_poolId][_account];
    }
    
    function getPoolTotalContributionBalance(uint _poolId) public view returns(uint256){
        return 5; //todo:
    }
    
    function getPoolStakeBalance_withAccount(uint _poolId, address _account) public view returns(uint256){
        return poolStakeBalance[_poolId][_account];
    }
    
    function getPoolTotalStakeBalance(uint _poolId) public view returns(uint256){
        return 5; //todo:
    }
    
    
    /* GUI Functions */
    
} // Vault


contract VaultMap{
    // type definitions
    enum Status {INITIALIZING,READY}
    
    // Working data
    address private owner;
    address private self;
    string[] private tokenNames;
    mapping(string=>address) private mapOfTokens;
    string[] private namesOfVaults;
    address[] private connectedAccounts;
    mapping(string=>address) private mapOfVaults;
    Status private status;

    // Modifiers
    modifier onlyWhenInitializing(){
        require(status == Status.INITIALIZING, "Vault is not initializing"); _;
    }
    
    modifier onlyWhenReady(){
        require(status == Status.READY, "Vault is not ready"); _;
    }

    // Events
    event AddVault(string indexed _name);
    event AddAccount(address indexed _account);

    // Functions
    constructor(address _owner, address _self) public {
        //Initialize vaults for all supported assets. All vault must hold special accounts for the contract used in
        //collecting incentives and the owner of the contract
        owner = _owner;
        self = _self;
        
        status = Status.INITIALIZING;
        
        // addNewVault("BNB");
        // addNewVault("ETH");
        // addNewVault("CT");
        status = Status.READY;
        
        // addNewAccount(owner);
        // addNewAccount(self);
    } // constructor()
    
    
    function addNewToken(string memory _tokenName, address _tokenAddress)onlyWhenInitializing public{
        mapOfTokens[_tokenName] = _tokenAddress;
        addName_toTokenNames(_tokenName);
        addNewVault(_tokenName);
        
        // emit AddToken(_tokenName);
    }
    
    function addNewVault(string memory _assetName)onlyWhenInitializing public{
        Vault newVault = new Vault(_assetName);
        mapOfVaults[_assetName] = address(newVault);
        addName_toNamesOfVaults(_assetName);
        
        // emit AddVault(_assetName);
    }
    
    function addNewAccount(address _account)onlyWhenReady public{
        require(!isAccountConnected(_account), "Account is already connected");
        
        for(uint i=0; i<getNo_ofVaults(); i++){
            string memory vaultName = getVaultNames()[i];
            Vault vault = getVault_withName(vaultName);
            vault.connectAccount(_account);
        }
        
        addAccount_toConnectedAccounts(_account);
        // emit AddAccount(_account);
    }
    
    function withdrawAsset(string memory _assetName, uint256 _amount, address _sender, address _receiver) payable public{
        Vault vault = getVault_withName(_assetName);
        vault.withdraw(_amount, _receiver, _sender);
    }
    
    function depositAsset(string memory _assetName, uint256 _amount, address _sender) payable public{
        if(Utils.compareString(_assetName, "BNB")){
            require(msg.value == _amount, "Send value and parameter mismatch");
            payable(owner).transfer(msg.value);
            _amount = msg.value;
        }
        else{
            bool found = false;
            for(uint i=0; i<tokenNames.length; i++){
                if(Utils.compareString(_assetName, tokenNames[i])){
                    IERC20 token = IERC20(mapOfTokens[_assetName]);
                    require(token.allowance(_sender, self) >= _amount, "Insufficient funds");
                    token.transferFrom(_sender, self, _amount);
                    found = true;
                    break;
                }
            }
            
            if(!found)
                revert("Assert not supported");
        }
        
        Vault vault = getVault_withName(_assetName);
        vault.deposit(_sender, _amount);
    }

    // Helper Functions
    function addName_toTokenNames(string memory _name) public{
        tokenNames.push(_name);
    }
    
    function addName_toNamesOfVaults(string memory _name) private{
        namesOfVaults.push(_name);
    }
    
    function addAccount_toConnectedAccounts(address _account) private{
        connectedAccounts.push(_account);
    }
    
    function getVault_withName(string memory _name) public view returns(Vault _vault) {
       _vault = Vault(mapOfVaults[_name]);
    } 
    
    function getVaultNames() public view returns(string[] memory){
        return namesOfVaults;
    }
    
    function getNo_ofVaults() public view returns(uint){
        return namesOfVaults.length;
    }
    
    function getConnectedAccounts() public view returns(address[] memory){
        return connectedAccounts;
    }
    
    function getNo_ofAccounts() public view returns(uint){
        return getConnectedAccounts().length;
    }
    event D(uint256 value, string []);
    function getAccountStatement(address _account) public returns(Utils.AccountSummary[] memory){
        Utils.AccountSummary[] memory summary = new Utils.AccountSummary[](getNo_ofVaults());
        for(uint i=0; i<getNo_ofVaults(); i++){
            Vault vault = getVault_withName(getVaultNames()[i]);
            summary[i].assetName = vault.getAssetName();
            summary[i].available = vault.getBalance_ofAccount(_account);
            summary[i].staked = 1; //todo: get all poolId and find this and the next (pooled)
            summary[i].contributed = 1;
        }
        return summary;
    }
    
    function isAccountConnected(address _account) public view returns(bool){
        for(uint i=0; i<getNo_ofAccounts(); i++){
            if(getConnectedAccounts()[i] == _account){
                return true;
            }
        }
        return false;
    }
    
    function init() public{
        status = Status.INITIALIZING;
    }
    
    function enable() public{
        status = Status.READY;
    }
    
    // Getters and setters
    
}// VaultMap
