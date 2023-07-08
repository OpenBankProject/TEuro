// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// Package
import { DataTypes } from "../libraries/DataTypes.sol";

/**
 * @title IdentityStorage.
 * @author TESOBE GmbH.
 *
 * @notice Data types and storage structure definition for
 * individual Identity contracts.
 */
contract IdentityStorage {
    // ===== STATE ===== 
    uint256 internal executionNonce;

    // ====== MAPPINGS ======
    mapping(bytes32 => DataTypes.Key) internal keys;
    mapping(uint256 => bytes32[]) internal keysByPurpose;
    mapping(uint256 => DataTypes.Execution) internal executions;
    mapping(bytes32 => DataTypes.Claim) internal claims;
    mapping(uint256 => bytes32[]) internal claimsByTopic;
}