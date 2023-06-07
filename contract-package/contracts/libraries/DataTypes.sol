// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title DataTypes
 * @author TESOBE GmbH
 *
 * @notice Data types used in TCoin Platform.
 */
library DataTypes {
    // ====== IERC734 ======
    /**
    * @notice Keys are cryptographic public keys,
    * or contract addresses associated with this identity.
    *
    * @param purposes Array of the key purposes.
    * @param keyType The type of key used.
    * @param key Keccak256 hash of the public key.
    */
    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    /**
     * @notice Executions are the way to forward a transaction to a smart contract.
     * @dev The `approved` field is used to track whether the execution has been approved or not.
     *
     * @param to The destination address to call.
     * @param value The amount of ETH to transfer.
     * @param data The data to forward.
     * @param approved If the execution has been approved or not.
     * @param executed If the execution has been executed or not.
     */
    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    // ====== IERC735 ======
    /**
    * @notice Claims are information an issuer has about the identity holder.
    *   - claim: A claim published for the Identity.
    * @param topic Number which represents the topic of the claim. (e.g. 1 biometric, 2 residence, ...)
    * @param scheme The scheme with which this claim SHOULD be verified or how it should be processed.
    *               Its a uint256 for different schemes. E.g. could 3 mean contract verification,
    *               where the data will be call data, and the issuer a contract address to call.
    *               Those can also mean different key types e.g. 1 = ECDSA, 2 = RSA, etc.
    * @param issuer The issuers identity contract address, or the address used to sign the above signature.
    *               If an identity contract, it should hold the key with which the above message was signed,
    *               if the key is not present anymore, the claim SHOULD be treated as invalid.
    *               The issuer can also be a contract address itself, at which the claim can be verified using the call data.
    * @param signature Signature which is the proof that the claim issuer issued a claim of topic for this identity.
    *                   it MUST be a signed message of the following structure:
    *                   `keccak256(abi.encode(identityHolder_address, topic, data))`
    * @param data The hash of the claim data, sitting in another location, a bit-mask,
    *               call data, or actual data based on the claim scheme.
    * @param uri The location of the claim, this can be HTTP links, swarm hashes, IPFS hashes, and such.
    */
    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }
}
