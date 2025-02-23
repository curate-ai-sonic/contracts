// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IContentMediaToken.sol";
import "./interfaces/IContentMediaVoting.sol";

contract ContentMediaSettlement is AccessControl {
    IContentMediaToken public token;
    IContentMediaVoting public voting;
    
    struct DailyReward {
        uint256 totalReward;
        uint256 rewardPerVote;
        bool settled;
    }
    
    mapping(uint256 => DailyReward) public dailyRewards;
    mapping(address => mapping(uint256 => bool)) private _claimedDays;

    event DailySettlement(uint256 day, uint256 totalReward);
    event RewardsClaimed(address user, uint256 totalAmount);

    constructor(address tokenAddress, address votingAddress) {
        token = IContentMediaToken(tokenAddress);
        voting = IContentMediaVoting(votingAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function settleDay(uint256 day) public {
    uint256 currentDay = block.timestamp / 1 days;
    require(currentDay > day, "Can only settle past days");
    require(!dailyRewards[day].settled, "Day already settled");
    
    token.mintDailyRewards();
    uint256 totalVotes = voting.getDailyTotalVotes(day);
    
    uint256 PRECISION = 10**18; // Same as Ether's wei
    uint256 adjustedRewardPerVote = totalVotes > 0 
        ? (token.DAILY_MINT_AMOUNT() * PRECISION) / totalVotes 
        : 0;

    dailyRewards[day] = DailyReward({
        totalReward: token.DAILY_MINT_AMOUNT(),
        rewardPerVote: adjustedRewardPerVote,
        settled: true
    });

    emit DailySettlement(day, token.DAILY_MINT_AMOUNT());
    }

function claimRewards() external {
    uint256 totalAmount = getClaimableAmount(msg.sender);
    require(totalAmount > 0, "No rewards to claim");

    uint256 PRECISION = 10**18;
    uint256 adjustedAmount = totalAmount / PRECISION; 

    token.distribute(msg.sender, adjustedAmount);
    emit RewardsClaimed(msg.sender, adjustedAmount);
}

function getClaimableAmount(address user) public view returns (uint256) {
    uint256[] memory activeDays = voting.getUserVoteDays(user);
    uint256 totalAmount;
    
    for (uint256 i = 0; i < activeDays.length; i++) {
        uint256 day = activeDays[i];
        DailyReward storage dr = dailyRewards[day];
        
        if (dr.settled && !_claimedDays[user][day]) {
            uint256 userVotes = voting.getAuthorVotes(day, user);
            totalAmount += userVotes * dr.rewardPerVote;
        }
    }
    
    return totalAmount;
}

    function getCurrentDay() public view returns (uint256) {
        return block.timestamp / 1 days;
    }
}