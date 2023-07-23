// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// Package
import { IIdentity } from "../../interfaces/IIdentity.sol";
import { IClaimIssuer } from "../../interfaces/IClaimIssuer.sol";
import { IdentityStorage } from "../../storage/IdentityStorage.sol";
import { DataTypes } from "../../libraries/DataTypes.sol";
import { Errors } from "../../libraries/Errors.sol";
import { Events } from "../../libraries/Events.sol";
// Others
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
     * @notice Verifies if caller has MANAGEMENT key.
     * @dev Reverts with `UnauthorizedCaller`.
     */
    modifier onlyManager() {
        if (
            msg.sender != address(this) ||
            !(
                keyHasPurpose(
                    keccak256(
                        abi.encode(
                            msg.sender
                        )
                    ),
                    1
                )
            )
        ) revert Errors.UnauthorizedCaller();
        _;
    }

    /**
     * @notice Verifies if caller has CLAIM key.
     * @dev Reverts with `UnauthorizedCaller`.
     */
    modifier onlyClaimKey() {
        if (
            msg.sender != address(this) ||
            !(
                keyHasPurpose(
                    keccak256(
                        abi.encode(
                            msg.sender
                        )
                    ),
                    3
                )
            )
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
     * @notice Initializer logic for Identities.
     * @dev This one is used for contracts inheriting from Identity
     * and also for the Identity contract itself.
     *
     * @param managementKey First address to be set as with the MANAGER
     * purpose for this identity.
     */
    function initializeIdentity (
        address managementKey
    ) internal onlyInitializing {
        bytes32 _key = keccak256(
            abi.encode(
                managementKey
            )
        );

        keys[_key].key = _key;
        keys[_key].purposes = [1];
        keys[_key].keyType = 1;

        keysByPurpose[1].push(_key);

        emit Events.KeyAdded(
            _key,
            1,
            1
        );

        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
    }

    /** 
     * @notice Initializer function for the contract.
     * @dev Initialized by the UUPS proxy.
     *
     * @param managementKey_ First address to be set as with the MANAGER
     * purpose for this identity.
     */
    function initialize (
        address managementKey_
    ) external virtual initializer nonReentrant {
        initializeIdentity(
            managementKey_
        );
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
        if (
            key.key == 0
        ) {
            return false;
        }

        for (
            uint keyPurposeIndex = 0;
            keyPurposeIndex < key.purposes.length;
            keyPurposeIndex++
        ) {
            uint256 purpose = key.purposes[keyPurposeIndex];

            if (
                purpose == 1 ||
                purpose == _purpose
            ) {
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
    ) public override nonReentrant onlyManager returns (
        bool success
    ) {
        // If the key already exists, add the purpose to the key.
        // Otherwise, create a new key.
        if (
            keys[_key].key == _key
        ) {
            uint256[] memory _purposes = keys[_key].purposes;
            for (
                uint keyPurposeIndex = 0;
                keyPurposeIndex < _purposes.length;
                keyPurposeIndex++
            ) {
                uint256 purpose = _purposes[keyPurposeIndex];

                if (purpose == _purpose) {
                    revert Errors.KeyAlreadyHavePurpose();
                }
            }

            keys[_key].purposes.push(_purpose);
        } else {
            keys[_key].key = _key;
            keys[_key].purposes = [_purpose];
            keys[_key].keyType = _keyType;
        }

        keysByPurpose[_purpose].push(_key);

        emit Events.KeyAdded(
            _key,
            _purpose,
            _keyType
        );

        return true;
    }

    /**
     * @dev See { IERC734-removeKey }.
     */
    function removeKey (
        bytes32 _key,
        uint256 _purpose
    ) public override nonReentrant onlyManager returns (
        bool success
    ) {
        // Check if key exists.
        if(
            keys[_key].key != _key
        ) revert Errors.NonexistentKey();

        uint256[] memory _purposes = keys[_key].purposes;
        uint purposeIndex = 0;

        while (
            _purposes[purposeIndex] != _purpose
        ) {
            purposeIndex++;

            if (
                purposeIndex == _purposes.length
            ) revert Errors.KeyNotHavePurpose();
        }

        // We replace the key we want to remove with the last key in the array.
        // Then we delete the last key in the array.
        _purposes[purposeIndex] = _purposes[_purposes.length - 1];
        keys[_key].purposes = _purposes;
        keys[_key].purposes.pop();

        uint keyIndex = 0;
        uint arrayLength = keysByPurpose[_purpose].length;

        while (
            keysByPurpose[_purpose][keyIndex] != _key
        ) {
            keyIndex++;

            if (
                keyIndex >= arrayLength
            ) {
                break;
            }
        }

        // Same as before but for the keysByPurpose array.
        keysByPurpose[_purpose][keyIndex] = keysByPurpose[_purpose][arrayLength - 1];
        keysByPurpose[_purpose].pop();

        uint keyType = keys[_key].keyType;

        // Completely delete the key if it has no purposes left.
        if (
            _purposes.length == 0
        ) {
            delete keys[_key];
        }

        emit Events.KeyRemoved(
            _key,
            _purpose,
            keyType
        );

        return true;
    }

    /**
     * @dev See { IERC734-approve }.
     */
    function approve (
        uint256 _id,
        bool _approve
    ) public override nonReentrant returns (
        bool success
    ) {
        // Validate execution `id`.
        if(
            _id > executionNonce
        ) revert Errors.NonexistentExecution();
        if(
            executions[_id].executed
        ) revert Errors.RequestAlreadyExecuted();

        // Emit execution approval resolution.
        emit Events.Approved(
            _id,
            _approve
        );

        // In case of approval execute a call for the request.
        if (_approve == true) {
            executions[_id].approved = true;

            (success,) = executions[_id].to.call{
                value: (executions[_id].value)
                }(
                    executions[_id].data
                );

            if (success) {
                executions[_id].executed = true;

                emit Events.Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );

                return true;
            } else {
                emit Events.ExecutionFailed(
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
        return false;
    }

    /**
     * @dev See { IERC734-execute }.
     */
    function execute (
        address _to,
        uint256 _value,
        bytes memory _data
    ) public override payable nonReentrant returns (
        uint256 executionId
    ) {
        uint256 _executionId = executionNonce;

        // Create entry in storage for this execution
        executions[executionNonce] = DataTypes.Execution(
            _to,
            _value,
            _data,
            false,
            false
        );

        executionNonce++;

        emit Events.ExecutionRequested(
            executionNonce,
            _to,
            _value,
            _data
        );

        // If the sender is a MANAGEMENT key, then approves.
        if (
            keyHasPurpose(
                keccak256(
                    abi.encode(
                        msg.sender
                    )
                ),
                1
            )
        ) {
            approve(
                _executionId,
                true
            );
        } else if (
            // Validates wheter the sender is an ACTION key and the destination
            // is not the contract itself.
            _to != address(this) &&
            keyHasPurpose(
                keccak256(
                    abi.encode(
                        msg.sender
                    )
                ),
                2
            )
        ){
            approve(
                _executionId,
                true
            );
        }

        return _executionId;
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
    ) public override nonReentrant onlyClaimKey returns (
        bytes32 _claimId
    ) {
        // Validate claim topic.
        if (_issuer != address(this)) {
            if(!
                IClaimIssuer(
                    _issuer
                ).isClaimValid(
                    IIdentity(
                        address(this)
                    ),
                    _topic,
                    _signature,
                    _data
                )
            ) revert Errors.InvalidClaim();
        }

        // Add or update storage for claim.
        bytes32 claimId = keccak256(
            abi.encode(
                _issuer,
                _topic
            )
        );
        claims[claimId].topic = _topic;
        claims[claimId].scheme = _scheme;
        claims[claimId].signature = _signature;
        claims[claimId].data = _data;
        claims[claimId].uri = _uri;

        // Validate if issuer should be updated.
        if (
            claims[claimId].issuer != _issuer
        ) {
            claimsByTopic[_topic].push(claimId);
            claims[claimId].issuer = _issuer;

            emit Events.ClaimAdded(
                claimId,
                _topic,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        } else {
            emit Events.ClaimChanged(
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
    ) public override nonReentrant onlyClaimKey returns (
        bool success
    ) {
        uint256 _topic = claims[_claimId].topic;
        if (
            _topic == 0
        ) {
            revert Errors.NonexistentClaim();
        }

        uint claimIndex = 0;
        uint arrayLength = claimsByTopic[_topic].length;
        // Retrieve the index of the claim to be deleted in the claimsByTopic array.
        while (
            claimsByTopic[_topic][claimIndex] != _claimId
        ) {
            claimIndex++;
            if (
                claimIndex >= arrayLength
            ) {
                break;
            }
        }

        // We move the last claim in the array to the index of the claim to be deleted.
        claimsByTopic[_topic][claimIndex] = claimsByTopic[_topic][arrayLength - 1];
        claimsByTopic[_topic].pop();

        emit Events.ClaimRemoved(
            _claimId,
            _topic,
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