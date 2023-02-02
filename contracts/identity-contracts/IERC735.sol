// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import { Storage } from "./Storage.sol";

/**
 * @title IERC735
 *
 * @notice Interface of the ERC735 (Claim Holder) standard as defined in the EIP.
 * https://github.com/ethereum/EIPs/issues/735
 */
interface IERC735 {
    // ===== EVENTS =====
    /**
     * @notice Emitted when a claim was added.
     * @dev MUST be triggered when a claim was successfully added.
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
     * @dev MUST be triggered when `changeClaim` was successfully called.
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

    // ====== CORE LOGIC ======
    /**
     * @notice Add a new claim.
     * Claims can requested to be added by anybody, including the claim holder itself (self issued).
     * @dev Triggers event `ClaimAdded`.
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address, uint256 topic))`.
     * 
     * @param _topic A number which represents the topic of the claim.
     * @param _scheme The scheme with which this claim should be verified.
     * @param _issuer The issuers identity contract address.
     * @param _signature is a signed message of the following structure: `keccak256(abi.encode(address identityHolder_address, uint256 topic, bytes data))`.
     * @param _data The hash of the claim data.
     * @param _uri The URL for the claim data.
     *
     * @return claimRequestId claim ID that could be sent to the approve function.
     */
    function addClaim (
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string memory _uri
    ) external returns (
        bytes32 claimRequestId
    );

    /**
     * @notice Removes a claim.
     * @dev Triggers event `ClaimRemoved`.
     * Should only be callable by the claim issuer and/or claim holder itself. 
     *
     * @param _claimId The id of the target claim.
     */
    function removeClaim (
        bytes32 _claimId
    ) external returns (
        bool success
    );

    /**
     * @notice Updates an existing claim.
     * @dev Triggers event `ClaimChanged`.
     *
     * @param _claimId The id for this specific claim.
     * @param _topic A number which represents the topic of the claim.
     * @param _scheme The scheme with which this claim should be verified.
     * @param _issuer The issuers identity contract address.
     * @param _signature Signed messsage of the holder address, topic and data of the claim.
     * @param _data The hash of the claim data.
     * @param _uri The URL for the claim data.
     */
    function changeClaim (
        bytes32 _claimId,
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string memory _uri
    ) external returns (
        bool success
    );

    // ===== VIEW FUNCTIONS ======
    /**
     * @notice Get a claim by its id.
     *
     * @param _claimId The id of the desired claim.
     */
    function getClaim (
        bytes32 _claimId
    ) external view returns (
        Storage.Claim memory claim
    );

    /**
     * @notice Returns an array of claim id by topic.
     *
     * @param _topic The topic index to filter by.
     */
    function getClaimIdsByTopic (
        uint256 _topic
    ) external view returns (
        bytes32[] memory claimIds
    );
}