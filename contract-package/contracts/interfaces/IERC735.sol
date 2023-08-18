// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// Package
import { DataTypes } from "../libraries/DataTypes.sol";

/**
 * @title IERC735.
 * @author TESOBE GmbH.
 *
 * @notice Interface of the ERC735 (Claim Holder) standard as defined in the EIP.
 * https://github.com/ethereum/EIPs/issues/735
 * @dev A claim is a statement signed by a trusted party about
 * a user in the identity system.
 */
interface IERC735 {
    // ===== VIEW FUNCTIONS ======
    /**
     * @notice Get a claim by its id.
     *
     * @param _claimId The id of the desired claim.
     *
     * @return claim The claim data.
     */
    function getClaim (
        bytes32 _claimId
    ) external view returns (
        DataTypes.Claim memory claim
    );

    /**
     * @notice Returns an array of claim id by topic.
     *
     * @param _topic The topic index to filter by.
     *
     * @return claimIds An array of claim IDs.
     */
    function getClaimIdsByTopic (
        uint256 _topic
    ) external view returns (
        bytes32[] memory claimIds
    );

    // ====== CORE LOGIC ======
    /**
     * @notice Add or update a claim.
     * @dev Requires that the sender has CLAIM key.
     * Claim IDs are generated using `keccak256(abi.encode(_issuer, _topic))`.
     * 
     * @param _topic The type of claim.
     * @param _scheme The scheme with which this claim should be verified.
     * @param _issuer The issuers identity contract address.
     * @param _signature is a signed message of the following structure: `keccak256(abi.encode(address identityHolder_address, uint256 topic, bytes data))`.
     * @param _data The hash of the claim data.
     * @param _uri The URL for the claim data.
     *
     * @return _claimId Generated or existing claim id for this issuer + topic.
     */
    function addClaim (
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string memory _uri
    ) external returns (
        bytes32 _claimId
    );

    /**
     * @notice Removes a claim.
     * @dev Can only be removed by the claim issuer, or the claim holder itself. 
     *
     * @param _claimId The id of the target claim.
     *
     * @return success Returns whether the claim was successfully removed.
     */
    function removeClaim (
        bytes32 _claimId
    ) external returns (
        bool success
    );
}
