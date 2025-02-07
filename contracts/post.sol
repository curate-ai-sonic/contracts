// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IContentMediaToken.sol";

contract ContentMediaVoting is Ownable {
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

    struct Vote {
        address voter;
        uint256 amount;
    }

    uint256 public constant VOTES_PER_DAY_MULTIPLIER = 5;
    ISocialMediaToken public token;
    uint256 public postCounter;
    uint256 public dailyVoteTotals;
    
    mapping(uint256 => Post) public posts;
    mapping(uint256 => Vote[]) public postVotes;
    mapping(address => uint256) public lastVoteResetTime;
    mapping(address => uint256) public votesUsedToday;

    event PostCreated(uint256 id, address author, string contentHash);
    event Voted(uint256 postId, address voter, uint256 amount);

    constructor(address tokenAddress) Ownable(msg.sender) {
        token = ISocialMediaToken(tokenAddress);
    }

    function createPost(string memory contentHash) public {
        postCounter++;
        posts[postCounter] = Post(postCounter, msg.sender, contentHash, 0, 0, block.timestamp, false, false);
        emit PostCreated(postCounter, msg.sender, contentHash);
    }

    // Add a requirement to check if user already voted or not
    function vote(uint256 postId, uint256 amount) public {
        require(postId <= postCounter, "Post does not exist");
        require(amount > 0, "Amount must be greater than 0");

        if (block.timestamp >= lastVoteResetTime[msg.sender] + 1 days) {
            votesUsedToday[msg.sender] = 0;
            lastVoteResetTime[msg.sender] = block.timestamp;
        }

        uint256 maxVotesToday = VOTES_PER_DAY_MULTIPLIER * token.balanceOf(msg.sender);
        require(votesUsedToday[msg.sender] + amount <= maxVotesToday, "Exceeds daily vote limit");

        posts[postId].totalScore += amount;
        posts[postId].newVote = true;
        postVotes[postId].push(Vote(msg.sender, amount));
        votesUsedToday[msg.sender] += amount;

        dailyVoteTotals += amount;

        emit Voted(postId, msg.sender, amount);
    }

    function aiVote(uint256 postId, uint256 amount) public onlyOwner {
        require(postId <= postCounter, "Post does not exist");
        require(amount > 0, "Amount must be greater than 0");
        require(!posts[postId].aiVoted, "AI can only vote once per post");
        require(block.timestamp < posts[postId].createdAt + 1 days, "AI can only vote on the first day");

        posts[postId].totalScore += amount;
        postVotes[postId].push(Vote(owner(), amount));
        posts[postId].aiVoted = true;

        dailyVoteTotals += amount;

        emit Voted(postId, owner(), amount);
    }

    function getPostScore(uint256 postId) public view returns (uint256) {
        return posts[postId].totalScore;
    }
}
