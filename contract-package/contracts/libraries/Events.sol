// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

/**
 * @title Events.
 * @dev Library for the TEuro platform.
 */
library Events {
    // ===== IERC734 =====
    /**
     * @notice Emitted when an execution request was approved.
     * @dev MUST be triggered when approve was successfully called.
     *
     * @param executionId_ The id for the execution.
     * @param approved_ If the execution was approved or not.
     */
    event Approved (
        uint256 indexed executionId_,
        bool approved_
    );

    /**
     * @notice Emitted when an execute operation was successfully performed.
     * @dev MUST be triggered when `approve` was called and the execution
     * was successfully approved.
     *
     * @param executionId_ The id for the execution.
     * @param to_ The destination address to call.
     * @param value_ The amount of ETH to transfer, in case of transfers.
     * @param data_ The data to forward.
     */
    event Executed (
        uint256 indexed executionId_,
        address indexed to_,
        uint256 indexed value_,
        bytes data_
    );

    /**
     * @notice Emitted when an execute operation failed to performed.
     * @dev MUST be triggered when `approve` was called and the execution
     * was not successfully due to any reason.
     *
     * @param executionId The id for the execution.
     * @param to The destination address to call.
     * @param value The amount of ETH to transfer, in case of transfers.
     * @param data The data to forward.
     */
    event ExecutionFailed (
        uint256 indexed executionId,
        address indexed to,
        uint256 indexed value,
        bytes data
    );

    /**
     * @notice Emitted when an execution request was performed via `execute`.
     * @dev MUST be triggered for any new request.
     *
     * @param executionId The id for the execution.
     * @param to The destination address to call.
     * @param value The amount of ETH to transfer, in case of transfers.
     * @param data The data to forward.
     */
    event ExecutionRequested (
        uint256 indexed executionId,
        address indexed to,
        uint256 indexed value,
        bytes data
    );

    /**
     * @notice Emitted when a key was added to the Identity.
     * @dev MUST be triggered when addKey was successfully called.
     *
     * @param key The encoded public key.
     * @param purpose The purpose of the key.
     * @param keyType The type of the key.
     */
    event KeyAdded (
        bytes32 indexed key,
        uint256 indexed purpose,
        uint256 indexed keyType
    );

    /**
     * @notice Emitted when a key was removed from the Identity.
     * @dev MUST be triggered when removeKey was successfully called.
     *
     * @param key The encoded public key.
     * @param purpose The purpose of the key.
     * @param keyType The type of the key.
     */
    event KeyRemoved (
        bytes32 indexed key,
        uint256 indexed purpose,
        uint256 indexed keyType
    );

    // ===== IERC735 =====
    /**
     * @notice Emitted when a claim was added.
     * @dev MUST be triggered when a claim was successfully added.
     *
     * @param claimId The id for the claim.
     * @param topic The topic of the claim.
     * @param scheme The scheme with which this claim should be verified.
     */
    event ClaimAdded (
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );

    /**
     * @notice Emitted when a claim was removed.
     * @dev MUST be triggered when `removeClaim` was successfully called.
     */
    event ClaimRemoved (
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );

    /**
     * @notice Emitted when a claim was changed.
     */
    event ClaimChanged (
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );

    // ===== IClaimIssuer =====
    /**
     * @notice Emitted when a claim is revoked.
     */
    event ClaimRevoked(
        bytes indexed signature
    );
}
