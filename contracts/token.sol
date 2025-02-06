// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContentMediaToken is ERC20, Ownable {
    uint256 public constant AI_SUPPLY_PERCENTAGE = 50;
    uint256 public constant DAILY_MINT_AMOUNT = 100000 * (10 ** 18);
    uint256 private constant INITIAL_SUPPLY = 1000000000;
    address public aiAgent;

    constructor() ERC20("SocialMediaToken", "SMT") Ownable(msg.sender) {
        uint256 aiSupply = (INITIAL_SUPPLY * AI_SUPPLY_PERCENTAGE) / 100;
        _mint(msg.sender, INITIAL_SUPPLY - aiSupply);
        _mint(address(this), aiSupply);
        aiAgent = msg.sender;
    }

    // Need to add access control
    function mintDailyTokens() external {
        _mint(address(this), DAILY_MINT_AMOUNT);
    }

    function distributeTokens(address recipient, uint256 amount) external {
        require(balanceOf(address(this)) >= amount, "Not enough tokens");
        _transfer(address(this), recipient, amount);
    }
}