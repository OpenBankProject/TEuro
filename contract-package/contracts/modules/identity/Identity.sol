// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import { IIdentity } from "../../interfaces/IIdentity.sol";
import { IdentityStorage } from "../../storage/IdentityStorage.sol";
import { DataTypes } from "../../libraries/DataTypes.sol";
import { Errors } from "../../libraries/Errors.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title Identity
 * @author TESOBE GmbH
 *
 * @notice Implementation of the `IERC734`(KeyHolder) and the 
 * `IERC735`(ClaimHolder) interfaces into a common identity contract.
 */
contract Identity is 
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    IdentityStorage,
    IIdentity
{
    // ===== MODIFIERS =====
    /**
     * @notice Requires management key to call this function, or internal call
     */
    modifier onlyManager() {
        if (
            msg.sender != address(this)
            || !(keyHasPurpose(keccak256(abi.encode(msg.sender)), 1))
        ) revert Errors.UnauthorizedCaller();
        _;
    }

    /**
     * @notice Requires claim key to call this function, or internal call
     */
    modifier onlyClaimKey() {
        if (
            msg.sender != address(this)
            || !(keyHasPurpose(keccak256(abi.encode(msg.sender)), 3))
        ) revert Errors.UnauthorizedCaller();
        _;
    }

    // ===== CONSTRUCTOR =====
    /**
     * @dev Disables constructor for logic contract.
     */
    constructor () {
       _disableInitializers(); 
    }

    /**
     * @notice Initializer function for contract.
     * @dev Initialized by the UUPS proxy.
     *
     * @param managementKey Initial address to be set as the management key of the identity system.
     */
    function initialize (
        address managementKey
    ) external initializer nonReentrant {
        bytes32 _key = keccak256(abi.encode(managementKey));

        keys[_key].key = _key;
        keys[_key].purposes = [1];
        keys[_key].keyType = 1;

        keysByPurpose[1].push(_key);

        emit KeyAdded(_key, 1, 1);

        __UUPSUpgradeable_init();
    }

    // ====== UPGRADE FUNCTIONS ======
    /**
     * @dev See { UUPSUpgradeable-_authorizeUpgrade }.
     */
    function _authorizeUpgrade (
        address
    ) internal override onlyManager {}

    /**
     * @dev See { IIdentity-version }.
     */
    function version ()
     external pure override returns (
        uint256 _version
    ) {
        return 1;
    }

    // ====== VIEW FUNCTIONS ======
    /**
     * @dev See { IERC734-getKey }.
     */
    function getKey (
        bytes32 _key
    ) public view override returns (
        DataTypes.Key memory key
    ) {
        return keys[_key];
    }

    /**
     * @dev See { IERC734-getKeyPurposes }.
     */
    function getKeyPurposes (
        bytes32 _key
    ) public view override returns (
        uint256[] memory _purposes
    ) {
        return (
            keys[_key].purposes
        );
    }

    /**
     * @dev See { IERC734-getKeysByPurpose }.
     */
    function getKeysByPurpose (
        uint256 _purpose
    ) public view override returns (
        bytes32[] memory keys
    ) {
        return keysByPurpose[_purpose];
    }

    /**
    * @dev See { IERC734-keyHasPurpose }.
    */
    function keyHasPurpose (
        bytes32 _key,
        uint256 _purpose
    ) public view override returns (
        bool exists
    ) {
        DataTypes.Key memory key = keys[_key];
        if (key.key == 0) {
            return false;
        }

        for (uint keyPurposeIndex = 0;
            keyPurposeIndex < key.purposes.length;
            keyPurposeIndex++
        ) {
            uint256 purpose = key.purposes[keyPurposeIndex];

            if (purpose == 1 || purpose == _purpose) {
                return true;
            }
        }

        return false;
    }

    /**
     * @dev See { IERC735-getClaim }.
     */
    function getClaim (
        bytes32 _claimId
    ) public view override returns (
        DataTypes.Claim memory claim
    ) {
        return claims[_claimId];
    }

    /**
     * @dev See { IERC735-getClaim }.
     */
    function getClaimIdsByTopic (
        uint256 _topic
    ) public view override returns(
        bytes32[] memory claimIds
    ) {
        return claimsByTopic[_topic];
    }

    // ====== CORE LOGIC ======
    /**
     * @dev See { IERC734-addKey }.
     */
    function addKey (
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    ) public override onlyManager returns (
        bool success
    ) {
        // Only the identity contract itself can add a key with purpose 1.
        if (msg.sender != address(this)) {
            require (
                keyHasPurpose(keccak256(abi.encode(msg.sender)), 1), 
                "Identity: Sender does not have management key"
            );
        }

        // If the key already exists, add the purpose to the key.
        // Otherwise, create a new key.
        if (keys[_key].key == _key) {
            for (uint keyPurposeIndex = 0;
                keyPurposeIndex < keys[_key].purposes.length;
                keyPurposeIndex++
            ) {
                uint256 purpose = keys[_key].purposes[keyPurposeIndex];

                if (purpose == _purpose) {
                    revert("Identity: Key already has purpose");
                }
            }

            keys[_key].purposes.push(_purpose);
        } else {
            keys[_key].key = _key;
            keys[_key].purposes = [_purpose];
            keys[_key].keyType = _keyType;
        }

        keysByPurpose[_purpose].push(_key);

        emit KeyAdded(_key, _purpose, _keyType);

        return true;
    }

    /**
     * @dev See { IERC734-removeKey }.
     */
    function removeKey (
        bytes32 _key,
        uint256 _purpose
    ) public override onlyManager returns (
        bool success
    ) {
        // Check if key exists.
        require(
            keys[_key].key == _key,
            "Identity: Key isn't registered"
        );

        // Only the identity contract itself can add a key with purpose 1.
        if (msg.sender != address(this)) {
            require(
                keyHasPurpose(keccak256(abi.encode(msg.sender)), 1),
                "Identity: Sender does not have management key"
            );
        }

        require(
            keys[_key].purposes.length > 0,
            "Identity: Key doesn't have such purpose"
        );

        uint purposeIndex = 0;
        while (keys[_key].purposes[purposeIndex] != _purpose) {
            purposeIndex++;

            if (purposeIndex >= keys[_key].purposes.length) {
                break;
            }
        }

        // Check if index went beyond array length for safety check.
        require(
            purposeIndex < keys[_key].purposes.length,
            "Identity: Key doesn't have such purpose"
        );

        // We replace the key we want to remove with the last key in the array.
        // Then we delete the last key in the array.
        keys[_key].purposes[purposeIndex] = keys[_key].purposes[keys[_key].purposes.length - 1];
        keys[_key].purposes.pop();

        uint keyIndex = 0;

        while (keysByPurpose[_purpose][keyIndex] != _key) {
            keyIndex++;
        }

        // Same as before but for the keysByPurpose array.
        keysByPurpose[_purpose][keyIndex] = keysByPurpose[_purpose][keysByPurpose[_purpose].length - 1];
        keysByPurpose[_purpose].pop();

        uint keyType = keys[_key].keyType;

        // Completely delete the key if it has no purposes left.
        if (keys[_key].purposes.length == 0) {
            delete keys[_key];
        }

        emit KeyRemoved(_key, _purpose, keyType);

        return true;
    }

    /**
     * @dev See { IERC734-approve }.
     */
    function approve (
        uint256 _id,
        bool _approve
    ) public override returns (
        bool success
    ) {
        require(
            keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Identity: Sender does not have action key"
        );

        emit Approved(_id, _approve);

        if (_approve == true) {
            executions[_id].approved = true;

            (success,) = executions[_id].to.call{
                value:(executions[_id].value)
                }(
                    abi.encode(executions[_id].data, 0)
                );

            if (success) {
                executions[_id].executed = true;

                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return true;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return false;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }

    /**
     * @dev See { IERC734-execute }.
     */
    function execute (
        address _to,
        uint256 _value,
        bytes memory _data
    ) public override payable returns (
        uint256 executionId
    ) {
        require(
            !executions[executionNonce].executed, "Already executed"
        );
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encode(msg.sender)), 2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }

    /**
    * @dev See { IERC735-addClaim }. 
    */
    function addClaim (
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    ) public override onlyClaimKey returns (
        bytes32 claimRequestId
    ) {
        bytes32 claimId = keccak256(abi.encode(_issuer, _topic));

        if (msg.sender != address(this)) {
            require(
                keyHasPurpose(keccak256(abi.encode(msg.sender)), 3),
                "Identity: Sender does not have claim signer key"
            );
        }

        if (claims[claimId].issuer != _issuer) {
            claimsByTopic[_topic].push(claimId);
            claims[claimId].topic = _topic;
            claims[claimId].scheme = _scheme;
            claims[claimId].issuer = _issuer;
            claims[claimId].signature = _signature;
            claims[claimId].data = _data;
            claims[claimId].uri = _uri;

            emit ClaimAdded(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        } else {
            claims[claimId].topic = _topic;
            claims[claimId].scheme = _scheme;
            claims[claimId].issuer = _issuer;
            claims[claimId].signature = _signature;
            claims[claimId].data = _data;
            claims[claimId].uri = _uri;

            emit ClaimChanged(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        }

        return claimId;
    }

    /**
    * @dev See { IERC735-removeClaim }.
    */
    function removeClaim (
        bytes32 _claimId
    ) public override onlyClaimKey returns (
        bool success
    ) {
        if (msg.sender != address(this)) {
            require(
                keyHasPurpose(keccak256(abi.encode(msg.sender)), 3),
                "Identity: Sender does not have CLAIM key"
            );
        }

        if (claims[_claimId].topic == 0) {
            revert("Identity: There is no claim with this ID");
        }

        uint claimIndex = 0;
        // Retrieve the index of the claim to be deleted in the claimsByTopic array.
        while (claimsByTopic[claims[_claimId].topic][claimIndex] != _claimId) {
            claimIndex++;
        }

        // We move the last claim in the array to the index of the claim to be deleted.
        claimsByTopic[claims[_claimId].topic][claimIndex] = claimsByTopic[
            claims[_claimId].topic
        ][
            claimsByTopic[claims[_claimId].topic].length - 1
        ];
        claimsByTopic[claims[_claimId].topic].pop();

        emit ClaimRemoved(
            _claimId,
            claims[_claimId].topic,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );

        // We set default values for the claims array.
        delete claims[_claimId];

        return true;
    }
}