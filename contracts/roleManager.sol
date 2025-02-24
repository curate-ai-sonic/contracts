// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RoleManager is AccessControl, ReentrancyGuard {
    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant CURATOR_ROLE = keccak256("CURATOR_ROLE");
    bytes32 public constant SETTLEMENT_ROLE = keccak256("SETTLEMENT_ROLE");
    bytes32 public constant AI_AGENT = keccak256("AI_AGENT_ROLE");

    bool private _rolesLocked;

    constructor() {
        _grantRole(SUPER_ADMIN_ROLE, msg.sender);
        _grantRole(SETTLEMENT_ROLE, msg.sender);
        _setRoleAdmin(SUPER_ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(MODERATOR_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(CURATOR_ROLE, MODERATOR_ROLE);
        _setRoleAdmin(SETTLEMENT_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(AI_AGENT, SUPER_ADMIN_ROLE);
    }

    function setSettlementContract(address settlementContract) external onlyRole(SUPER_ADMIN_ROLE) nonReentrant {
        require(!_rolesLocked, "Settlement role already assigned");
        require(settlementContract != address(0), "Invalid settlement address");

        revokeRole(SETTLEMENT_ROLE, msg.sender);
        grantRole(SETTLEMENT_ROLE, settlementContract);
        _rolesLocked = true;
    }

    function assignModerator(address account) external onlyRole(SUPER_ADMIN_ROLE) nonReentrant {
        grantRole(MODERATOR_ROLE, account);
    }

    function revokeModerator(address account) external onlyRole(SUPER_ADMIN_ROLE) nonReentrant {
        revokeRole(MODERATOR_ROLE, account);
    }

    function assignAIAgent(address account) external onlyRole(SUPER_ADMIN_ROLE) nonReentrant {
        grantRole(AI_AGENT, account);
    }

    function assignCurator(address account) external onlyRole(MODERATOR_ROLE) nonReentrant {
        grantRole(CURATOR_ROLE, account);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) nonReentrant {
        if (role == SETTLEMENT_ROLE) {
            require(!_rolesLocked, "Settlement role is locked");
        }
        super.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) nonReentrant {
        if (role == SETTLEMENT_ROLE && role == CURATOR_ROLE && role == AI_AGENT) {
            require(!_rolesLocked, "Unrevokable role!");
        }
        super.revokeRole(role, account);
    }
}