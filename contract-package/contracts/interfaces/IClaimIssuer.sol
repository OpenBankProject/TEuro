// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

// Package
import { IIdentity } from "./IIdentity.sol";

/**
 * @title IClaimIssuer.
 * @author TESOBE GmbH.
 *
 * @notice Claim Issuer Interface. Managerial and extra utilities for claims
 * in the identity system.
 */
interface IClaimIssuer is
    IIdentity
{    
    // ===== VIEW FUNCTIONS =====
    /**
     * @notice Returns status of a claim.
     *
     * @param _signature the signature of the claim.
     *
     * @return isRevoked True if the claim is revoked and false otherwise.
     */
    function isClaimRevoked (
        bytes calldata _signature
    ) external view returns (
        bool isRevoked
    );

    /**
     * @notice Checks if a claim is valid.
     *
     * @param _identity The identity contract related to the claim.
     * @param _claimTopic The claim topic of the claim.
     * @param _signature The signature of the claim.
     * @param _data The data field of the claim.
     *
     * @return claimValid True if the claim is valid, false otherwise.
     */
    function isClaimValid (
        IIdentity _identity,
        uint256 _claimTopic,
        bytes calldata _signature,
        bytes calldata _data
    ) external view returns (
        bool claimValid
    );

    // ===== UTILITIES =====
    /**
     * @notice Returns the address that signed the given data.
     *
     * @param _signature The signature of the data.
     * @param _dataHash The data that was signed.
     *
     * @return signer The address that signed dataHash and created the signature signature.
     */
    function getRecoveredAddress (
        bytes memory _signature,
        bytes32 _dataHash
    ) external pure returns (
        address signer
    );

    // ===== CORE LOGIC =====
    /**
     * @notice Revoke a claim previously issued,
     * the claim is no longer considered as valid after revocation.
     * @dev Will fetch the claim from the identity contract (unsafe).
     *
     * @param _claimId The id of the claim.
     * @param _identity The address of the identity contract.
     *
     * @return isRevoked True when the claim is revoked.
     */
    function revokeClaim (
        bytes32 _claimId,
        address _identity
    ) external returns (
        bool
    );

    /**
     * @notice Revoke a claim previously issued,
     * the claim is no longer considered as valid after revocation.
     *
     * @param _signature The signature of the claim.
     */
    function revokeClaimBySignature (
        bytes calldata _signature
    ) external;
}