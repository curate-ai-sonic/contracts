// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IContentMediaToken.sol";
import "./utils/checkRole.sol";

contract CurateAIPostAndVote is CheckRole {

    struct Post {
        uint256 id;
        address author;
        string contentHash;
        uint256 totalScore;
        uint256 claimedScore;
        uint256 createdAt;
        string tags;
        bool newVote;
        bool aiVoted;
    }

    uint256 public constant VOTES_PER_DAY_MULTIPLIER = 5;
    IContentMediaToken public token;
    uint256 public postCounter;

    mapping(uint256 => mapping(uint256 => uint256)) public dailyPostVotes;
    mapping(uint256 => uint256) public dailyVoteTotals;
    mapping(address => mapping(uint256 => uint256)) public dailyAuthorVotes;
    mapping(address => uint256[]) public userActiveDays;

    mapping(uint256 => Post) public posts;
    mapping(address => uint256) public lastVoteResetTime;
    mapping(address => uint256) public votesUsedToday;

    event PostCreated(uint256 id, address author, string contentHash, string tags);
    event Voted(uint256 postId, address voter, uint256 amount);
    
    constructor(address _tokenAddress, address _roleManager) CheckRole(_roleManager){
        token = IContentMediaToken(_tokenAddress);
    }

    function createPost(string calldata contentHash, string calldata tags) external {
        postCounter++;
        posts[postCounter] = Post({
            id: postCounter,
            author: msg.sender,
            contentHash: contentHash,
            totalScore: 0,
            claimedScore: 0,
            createdAt: block.timestamp,
            tags: tags,
            newVote: false,
            aiVoted: false
        });
        emit PostCreated(postCounter, msg.sender, contentHash, tags);
    }

    function vote(uint256 postId, uint256 amount) external execeptRole(AI_AGENT_ROLE){
        require(postId <= postCounter, "Post does not exist");
        require(amount > 0, "Amount must be greater than 0");

        // Todo: Write test for this as well
        // Reset daily votes if 24 hours have passed
        if (block.timestamp >= lastVoteResetTime[msg.sender] + 1 days) {
            votesUsedToday[msg.sender] = 0;
            lastVoteResetTime[msg.sender] = block.timestamp;
        }

        uint256 maxVotesToday = VOTES_PER_DAY_MULTIPLIER * token.balanceOf(msg.sender);
        require(votesUsedToday[msg.sender] + amount <= maxVotesToday, "Exceeds daily vote limit");

        uint256 currentDay = block.timestamp / 1 days;
        Post storage post = posts[postId];

        post.totalScore += amount;
        post.newVote = true;
        dailyPostVotes[currentDay][postId] += amount;
        dailyVoteTotals[currentDay] += amount;
        dailyAuthorVotes[post.author][currentDay] += amount;

        if (dailyAuthorVotes[post.author][currentDay] == amount) {
            userActiveDays[post.author].push(currentDay);
        }

        votesUsedToday[msg.sender] += amount;
        emit Voted(postId, msg.sender, amount);
    }

    function aiVote(uint256 postId, uint256 amount) external onlyRole(AI_AGENT_ROLE) {
        require(postId <= postCounter, "Post does not exist");
        require(amount > 0, "Amount must be greater than 0");
        require(!posts[postId].aiVoted, "AI can only vote once per post");
        require(block.timestamp < posts[postId].createdAt + 1 days, "AI can only vote on the first day");

        uint256 currentDay = block.timestamp / 1 days;
        Post storage post = posts[postId];

        post.totalScore += amount;
        dailyPostVotes[currentDay][postId] += amount;
        dailyVoteTotals[currentDay] += amount;
        dailyAuthorVotes[post.author][currentDay] += amount;
        post.aiVoted = true;

        if (dailyAuthorVotes[post.author][currentDay] == amount) {
            userActiveDays[post.author].push(currentDay);
        }

        emit Voted(postId, msg.sender, amount);
    }

    function getPostScore(uint256 postId) external view returns (uint256) {
        return posts[postId].totalScore;
    }

    function getAuthorVotes(uint256 day, address author) external view returns (uint256) {
        return dailyAuthorVotes[author][day];
    }

    function getTotalVotes() external view returns (uint256) {
        return dailyVoteTotals[block.timestamp / 1 days];
    }

    function getUserVoteDays(address user) external view returns (uint256[] memory) {
        return userActiveDays[user];
    }

    function getDailyTotalVotes(uint256 day) external view returns (uint256) {
        return dailyVoteTotals[day];
    }

    
}