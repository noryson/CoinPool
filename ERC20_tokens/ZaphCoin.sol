pragma solidity >= 0.8.0;

import "../Models/Vault.sol";
import "./iCoinPoolVault.sol";

contract ZaphodToken is ICoinPoolVaultToken {
    string  public name = "Zaphod Token";
    string  public symbol = "ZAPH";
    string  public standard = "Zaphod Token v1.0";
    uint256 public totalSupply = 200000000000000;
    uint8 public decimals = 18;

    event Transfer(
      address indexed _from,
      address indexed _to,
      uint256 _value
    );

    event Approval(
      address indexed _owner,
      address indexed _spender,
      uint256 _value
    );

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    using SafeMath for uint256;

    // Constructor
    constructor() {  
      balances[msg.sender] = totalSupply;
    }   
    
    // Total supply
    function totalsupply() public view returns(uint256){
      return totalSupply;
    }

    // Balance Of 
    function balanceOf(address tokenOwner) public view returns (uint) {
      return balances[tokenOwner];
    }
    
    // Allowance 
    function allowance(address tokenOwner, address spender) public view returns (uint) {
      return allowed[tokenOwner][spender];
    }
     
    // Transfer 
    function transfer(address receiver, uint numTokens) public returns (bool) {
      require(numTokens <= balances[msg.sender]);
      
      balances[msg.sender] = balances[msg.sender].sub(numTokens);
      balances[receiver] = balances[receiver].add(numTokens);
      emit Transfer(msg.sender, receiver, numTokens);
      return true;
    }
    
    // Approve
    function approve(address delegate, uint numTokens) public returns (bool) {
      allowed[msg.sender][delegate] = numTokens;
      emit Approval(msg.sender, delegate, numTokens);      
      return true;
    }
    
    // Transfer from
    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
      require(numTokens <= balances[owner]);    
      require(numTokens <= allowed[owner][msg.sender]);
    
      balances[owner] = balances[owner].sub(numTokens);
      allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
      balances[buyer] = balances[buyer].add(numTokens);
      emit Transfer(owner, buyer, numTokens);
      return true;
    }
    
    
    // Transfer to vault
    function transferToVault(Vault vault, uint numTokens) override external returns (bool) {
      address vaultAddress = address(vault);
      
      if (approve(vaultAddress, numTokens)) {
        return (transfer(vaultAddress, numTokens));
      }

    } //transferToVault()
    
    
    // Don't accept ETH fall back
    fallback() external {
       revert();
    }    
}  // ZaphodToken


library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
} // SafeMath

