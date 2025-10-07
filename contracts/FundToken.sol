// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundToken{
    // 1. token's name
    // 2. token's short name
    // 3. token's amount
    // 4. owner's address
    // 5. balance address => uint256
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;
    mapping(address=>uint256) public balances;
    constructor(string memory _tokenname, string memory _tokensymbol){
        tokenName = _tokenname;
        tokenSymbol = _tokensymbol;
        owner = msg.sender;
    }
    function mint(uint256 amountToMint) public{
        balances[msg.sender] += amountToMint;
        totalSupply += amountToMint;
    }
    function transfer(address to, uint256 amount) public{
        require(balances[msg.sender]>amount,"You dont' have enough balance to transfer");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
    function balanceof(address funder) view external returns(uint256){
        return balances[funder];
    }
}