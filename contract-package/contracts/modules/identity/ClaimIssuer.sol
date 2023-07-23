// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

// Package
import { IClaimIssuer } from "../../interfaces/IClaimIssuer.sol";
import { IIdentity } from "../../interfaces/IIdentity.sol";
import { Identity } from "./Identity.sol";
import { DataTypes } from "../../libraries/DataTypes.sol";
import { Events } from "../../libraries/Events.sol";

contract ClaimIssuer is 
    Identity,
    IClaimIssuer
{
    // ===== STORAGE =====
    mapping (bytes => bool) public revokedClaims;

    // ===== CONSTRUCTOR =====
    constructor () {
        _disableInitializers();
    }

    /** 
     * @notice Initializer function for.
     * @dev Initialized by the UUPS proxy.
     * As its inheriting from the Identity contract,
     * it will also initialize it as part of the process.
     *
     * @param managementKey_ The initial management key.
     */
    function initialize (
        address managementKey_
    ) external override initializer {
        initializeIdentity(
            managementKey_
        );
    }

    // ===== VIEW FUNCTIONS =====
    /**
     * @dev See { IClaimIssuer-isClaimRevoked }.
     */
    function isClaimRevoked (
        bytes calldata _signature
    ) public view override returns (
        bool isRevoked
    ) {
        if (revokedClaims[_signature]) {
            return true;
        }

        return false;
    }

    /**
     * @dev See { IClaimIssuer-isClaimValid }.
     */
    function isClaimValid (
        IIdentity _identity,
        uint256 _claimTopic,
        bytes calldata _signature,
        bytes calldata _data
    ) public view override returns (
        bool claimValid
    ) {
        bytes32 dataHash = keccak256(
            abi.encode(
                _identity,
                _claimTopic,
                _data
            )
        );
        // Use abi.encodePacked to concatenate the message prefix and the message to sign.
        bytes32 prefixedHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", dataHash
            )
        );

        // Recover address of data signer
        address recovered = getRecoveredAddress(
            _signature,
            prefixedHash
        );

        // Take hash of recovered address
        bytes32 hashedAddr = keccak256(
            abi.encode(
                recovered
            )
        );

        // Does the trusted identifier have they key which signed the user's claim?
        //  && (isClaimRevoked(_claimId) == false)
        if (
            keyHasPurpose(hashedAddr, 3) &&
            (isClaimRevoked(_signature) == false)
        ) {
            return true;
        }

        return false;
    }

    // ===== UTILITIES =====
    /**
     * @dev See { IClaimIssuer-getRecoveredAddress }.
     */
    function getRecoveredAddress (
        bytes memory _signature,
        bytes32 _dataHash
    ) public pure override returns (
        address signer
    ) {
        bytes32 ra;
        bytes32 sa;
        uint8 va;

        // Check the signature length
        if (
            _signature.length != 65
        ) {
            return address(0);
        }

        // Divide the signature in r, s and v variables
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ra := mload(add(_signature, 32))
            sa := mload(add(_signature, 64))
            va := byte(0, mload(add(_signature, 96)))
        }

        if (va < 27) {
            va += 27;
        }

        address recoveredAddress = ecrecover(
            _dataHash,
            va,
            ra,
            sa
        );

        return (recoveredAddress);
    }

    // ===== CORE LOGIC =====
    /**
     * @dev See { IClaimIssuer-revokeClaim }.
     */
    function revokeClaim (
        bytes32 _claimId,
        address _identity
    ) external returns (
        bool
    ) {
        DataTypes.Claim memory _claim = Identity(
            _identity
        ).getClaim(
            _claimId
        );

        require(
            !revokedClaims[_claim.signature],
            "Conflict: Claim already revoked"
        );

        revokedClaims[_claim.signature] = true;
        emit Events.ClaimRevoked(_claim.signature);
        return true;
    }

    /**
     * @dev See { IClaimIssuer-revokeClaimBySignature }.
     */
    function revokeClaimBySignature (
        bytes calldata _signature
    ) external {
        require(!revokedClaims[_signature], "Conflict: Claim already revoked");

        revokedClaims[_signature] = true;

        emit Events.ClaimRevoked(_signature);
    }
}
