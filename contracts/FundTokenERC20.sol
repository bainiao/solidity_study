//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20 {
    FundMe fundme;
    constructor(address fundMeAddr) ERC20("FundTokenERC20", "FT"){
        fundme = FundMe(fundMeAddr);
    }
    function mint(uint256 amountToMint) public {
        require(fundme.funderToAmount(msg.sender)>=amountToMint, "You don't have enough token");
        _mint(msg.sender, amountToMint);
        fundme.setFunderAmount(msg.sender, fundme.funderToAmount(msg.sender)-amountToMint);
    }
    function claim(uint256 amountToClaim) public{
        require(balanceOf(msg.sender)>=amountToClaim, "you don't have enough ERC20 tokens");
        _burn(msg.sender, amountToClaim);
    }
}