// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe{
    // 1. receive money funciton
    // 2. record investor
    // 3. within lock time, attain to target, producer get money
    // 4. within lock time, not attain to target, investor can withdraw money
    // 5. 1 eth = 10**3 Pwei = 10**6 Twei = 10**9 Gwei = 10**12 Mwei = 10**15 Kwei = 10**18 wei
    mapping(address => uint256) public funderToAmount;
    uint256 MINIMUM_VALUE = 1*10**18;    // wei
    uint256 MINIMUM_DOLLAR = 100;
    AggregatorV3Interface internal dataFeed;
    address public owner;
    address private erc20Addr;
    event fundGotByOwner(address indexed owner, uint256 indexed amount);
    event funderWithdraw(address indexed funder, uint256 indexed amount);
    uint256 lockTime;
    uint256 deploymentTimestamp;
    modifier onlyOwner(){
        require(owner == msg.sender, "only owner");
        _;
    }
    
    constructor(uint256 _locktime){
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = deploymentTimestamp + _locktime;
    }
    function fund() external payable{
        require(convertEthToUsd(msg.value) >= MINIMUM_DOLLAR, "the minimum fund value is 1 eth.");
        funderToAmount[msg.sender] += msg.value;
    }
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / 10**8;
        // ETH / USD precision = 10**8
    }
    function transferOwner(address newOwner) external onlyOwner{
        owner = newOwner;
    }
    function getFund() payable external onlyOwner{
        uint256 totalAmount = address(this).balance;
        require(convertEthToUsd(totalAmount)>=MINIMUM_DOLLAR, "minimum target not reach");
        require(owner == msg.sender, "You are not woner.");
        // payable(msg.sender).transfer(totalAmount);
        // bool res = payable(msg.sender).send(totalAmount);
        bool res;
        (res, ) = payable(msg.sender).call{value: totalAmount}("");
        if (res){
            revert();
        }
        emit fundGotByOwner(msg.sender, totalAmount);
    }
    function withdraw() external payable{
        require(block.timestamp > lockTime, "funding is not finished.");
        require(address(this).balance<MINIMUM_DOLLAR, "total fund exceeds target.");
        require(funderToAmount[msg.sender]>0, "you don't fund.");
        bool success;
        uint256 amount = funderToAmount[msg.sender];
        funderToAmount[msg.sender] = 0;
        (success, ) = payable(msg.sender).call{value: amount}("");
        if (!success){
            revert("withdraw failed.");
        }
        emit funderWithdraw(msg.sender, amount);
    }
    function setErc20Addr(address _erc20Addr) external onlyOwner{
        erc20Addr = _erc20Addr;
    }
    function setFunderAmount(address funder, uint256 amountToUpdate) external{
        require(msg.sender == erc20Addr, "you don't have right to update token.");
        funderToAmount[funder] = amountToUpdate;
    }
}