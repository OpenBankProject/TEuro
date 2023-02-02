// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Storage
 *
 * @notice Data types and storage structure definition for Identity Manager.
 */
contract Storage {
    // ===== STATE =====
    uint256 internal executionNonce; 

    // ===== DATA TYPES =====
    /**
    * @notice A `Key` is a public key owned by this identity 
    * @dev Keys are cryptographic public keys, or contract addresses associated with this identity.
    *
    * @param purposes Array of the key purposes, like 1 = MANAGEMENT, 2 = EXECUTION.
    * @param keyType The type of key used, which would be a uint256 for different key types. e.g. 1 = ECDSA, 2 = RSA, etc.
    * @param key The actual public key expressed as the Keccak256 hash of the key.
    */
    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    /**
     * @notice 
     */
    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

   /**
    * @notice Claims are information an issuer has about the identity holder.
    * @dev Each `Claim` struct should represent a published claim for the Identity.
    * 
    * @param topic A number which represents the topic of the claim, e.g. 1 biometric, 2 residence, ...
    * @param scheme The scheme with which this claim should be verified or how it should be processed, e.g. 1 = ECDSA, 2 = RSA, etc.
    * @param issuer The issuers identity contract address, or the address used to sign the `signature`.
    * @param signature Signature which is the proof that the claim issuer issued a claim of topic for this identity. It must be a signed message of the following structure: `keccak256(abi.encode(identityHolder_address, topic, data))`
    * @param data The hash of the claim data, sitting in another location.
    * @param uri The URL for the claim data.
    */
    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }

    // ===== MAPPINGS =====
    mapping(bytes32 => Key) internal keys;
    mapping(uint256 => bytes32[]) internal keysByPurpose;
    mapping(uint256 => Execution) internal executions;
    mapping(bytes32 => Claim) internal claims;
    mapping(uint256 => bytes32[]) internal claimsByTopic;
}