// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISocialMediaToken {
    function mintDailyTokens() external;
    function distributeTokens(address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function DAILY_MINT_AMOUNT() external view returns (uint256);
}