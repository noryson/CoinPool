pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Sample token contract
//
// Symbol        : MDT
// Name          : MD Token
// Total supply  : 21000000
// Decimals      : 0
// Owner Account : 0xfD8b7D36144be2DBc1eebB41e9be21c19c70032b
//
// (c) by Oyindamola Abiola 2021.
// ----------------------------------------------------------------------------



// Lib: Arith

contract Arith {

    function add(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



// ERC Token Standard #20 Interface

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



// Contract function to receive approval and execute function in one call Borrowed from MiniMeToken

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ERC20 Token, with the addition of symbol, name and decimals and assisted token transfers

contract MDTToken is ERC20Interface, Arith {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;



    // Constructor

    constructor() public {
        symbol = "MDT";
        name = "MD Token";
        decimals = 0;
        _totalSupply = 21000000;
        balances[0xfD8b7D36144be2DBc1eebB41e9be21c19c70032b] = _totalSupply;
        emit Transfer(address(0), 0xfD8b7D36144be2DBc1eebB41e9be21c19c70032b, _totalSupply);
    }



    // Total supply

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }



    // Get the token balance for account tokenOwner

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }



    // Transfer the balance from token owner's account to to account

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = sub(balances[msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }



    // Token owner can approve for spender to transferFrom(...) token from the token owner's account

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }



    // Transfer tokens from the from account to the other account

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = sub(balances[from], tokens);
        allowed[from][msg.sender] = sub(allowed[from][msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }



    // Returns the amount of tokens approved by the owner that can be transferred to the spender's account

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }



    // Token owner can approve for spender to transferFrom(...) tokens from the token owner's account.

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }



    // Don't accept ETH

    function () public payable {
        revert();
    }
}