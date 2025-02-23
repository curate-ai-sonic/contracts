// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ContentMediaToken is ERC20, AccessControl, ReentrancyGuard {
    bytes32 public constant SETTLEMENT_ROLE = keccak256("SETTLEMENT_ROLE");
    
    uint256 public constant DAILY_MINT_AMOUNT = 100_000;
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000;
    uint256 public lastMintTime;

    bool private _roleAssigned;

    constructor() ERC20("CurateAIToken", "CAT") {
        _mint(msg.sender, INITIAL_SUPPLY / 2);
        _mint(address(this), INITIAL_SUPPLY / 2);

        _grantRole(SETTLEMENT_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setSettlementContract(address _settlementContract) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        require(!_roleAssigned, "Settlement role already assigned");
        require(_settlementContract != address(0), "Invalid settlement address");

        revokeRole(SETTLEMENT_ROLE, msg.sender);

        grantRole(SETTLEMENT_ROLE, _settlementContract);

        _roleAssigned = true;

        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) nonReentrant {
        require(!_roleAssigned, "Role assignments are locked");
        super.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) nonReentrant {
        require(!_roleAssigned || role != SETTLEMENT_ROLE, "SETTLEMENT_ROLE cannot be revoked after setup");
        super.revokeRole(role, account);
    }

    function mintDailyRewards() external onlyRole(SETTLEMENT_ROLE) nonReentrant {
        require(block.timestamp >= lastMintTime + 1 days, "Can only mint once per day");
        lastMintTime = block.timestamp;
        _mint(address(this), DAILY_MINT_AMOUNT);
    }

    function distribute(address to, uint256 amount) external onlyRole(SETTLEMENT_ROLE) nonReentrant {
        _transfer(address(this), to, amount);
    }
}