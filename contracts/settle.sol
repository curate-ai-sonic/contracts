// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISocialMediaToken.sol";
import "./post.sol";
import "hardhat/console.sol";

contract ContentMediaSettlement is Ownable {

    struct Post {
        uint256 id;
        address author;
        string contentHash;
        uint256 totalScore;
        uint256 claimedScore;
        uint256 createdAt;
        bool newVote;
        bool aiVoted;
    }

    ISocialMediaToken public token;
    SocialMediaVoting public votingContract;

    mapping(uint256 => uint256) public dailyMintAllocation;
    mapping(uint256 => mapping(address => bool)) public claimedRewards;
    uint256 public lastSettlementTime;

    event DailySettlement(uint256 totalTokensDistributed, uint256 timestamp);

    constructor(address tokenAddress, address votingContractAddress) Ownable(msg.sender) {
        token = ISocialMediaToken(tokenAddress);
        votingContract = SocialMediaVoting(votingContractAddress);
        lastSettlementTime = block.timestamp;
    }

    function settleDailyTokens() external onlyOwner {
        // require(block.timestamp >= lastSettlementTime + 1 days, "Can only settle once per day");

        token.mintDailyTokens();

        uint256 totalVotes = votingContract.dailyVoteTotals();

        if (totalVotes > 0) {
            uint256 dailyMintAmount = 100000;
            for (uint256 i = 1; i <= votingContract.postCounter(); i++) {
                (, address author, , uint256 totalScore, uint256 claimedScore, , bool newVote, ) = votingContract.posts(i);
                if (newVote) {
                    uint256 claimableAmount = totalScore - claimedScore;
                    uint256 tokensToDistribute = (dailyMintAmount * claimableAmount) / totalVotes;
                    claimedScore += claimableAmount;
                    newVote = false;
                    token.distributeTokens(author, tokensToDistribute);
                }
            }
        }
    
        lastSettlementTime = block.timestamp;
        emit DailySettlement(token.DAILY_MINT_AMOUNT(), block.timestamp);
    }

}
