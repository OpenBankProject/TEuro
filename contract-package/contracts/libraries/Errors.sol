// SPDX-License-Identifier: GPL-3.0
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
    /**
     * @dev When the requested purpose of a key was not found.
     */
    error KeyAlreadyHavePurpose ();
    /**
     * @dev When the required purposed of a key was not found.
     */
    error KeyNotHavePurpose ();
    /**
     * @dev When the requested key was not found.
     */
    error NonexistentKey ();
    /**
     * @dev When the given execution id was not found.
     */
    error NonexistentExecution ();
    /**
     * @dev When a given execution id was already fulfilled.
     */
    error RequestAlreadyExecuted ();
    /**
     * @dev When the given claim is not valid.
     */
    error InvalidClaim ();
    /**
     * When the given claim is not found.
     */
    error NonexistentClaim ();
}