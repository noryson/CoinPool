pragma solidity ^0.8.0;

import "../Models/Vault.sol";

interface ICoinPoolVaultToken{
  function transferToVault(Vault vault, uint numTokens) external returns (bool);
}