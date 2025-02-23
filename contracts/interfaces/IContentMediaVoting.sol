// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IContentMediaVoting {
    // Event emitted when a vote is cast
    event Voted(address indexed voter, uint256 day, address author, uint256 amount);

    // Function to cast a vote for a specific author on a specific day
    function vote(uint256 day, address author, uint256 amount) external;

    // Function to get the total votes for a specific author on a specific day
    function getAuthorVotes(uint256 day, address author) external view returns (uint256);

    // Function to get the list of days a user has voted
    function getUserVoteDays(address user) external view returns (uint256[] memory);

    function getDailyTotalVotes(uint256 day) external view returns (uint256);
}