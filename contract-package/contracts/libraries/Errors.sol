// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title DataTypes
 * @author TESOBE GmbH
 *
 * @notice Errors used in TCoin Platform.
 */
library Errors {
    // ===== Identity =====
    /**
     * @dev When the caller does not have management key.
     */
    error UnauthorizedCaller ();
}