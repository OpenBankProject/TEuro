// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @notice ERC734 (Key Holder) Interface.
 * Standard defined at https://github.com/ethereum/EIPs/issues/734.
 */
interface IERC734 {
    // ===== EVENTS =====
    /**
     * @notice Emitted when an execution request was approved.
     * @dev MUST be triggered when approve was successfully called.
     *
     * @param executionId The id for the execution.
     * @param approved If the execution was approved or not.
     */
    event Approved (
        uint256 indexed executionId,
        bool approved
    );

    /**
     * @notice Emitted when an execute operation was approved and successfully performed.
     * @dev MUST be triggered when approve was called and the execution was successfully approved.
     */
    event Executed (
        uint256 indexed executionId,
        address indexed to,
        uint256 indexed value,
        bytes data
    );

    /**
     * @notice Emitted when an execution request was performed via `execute`.
     * @dev MUST be triggered when execute was successfully called.
     */
    event ExecutionRequested (
        uint256 indexed executionId,
        address indexed to,
        uint256 indexed value,
        bytes data
    );

    /**
     * @notice Emitted when an execution requested via `execute` fail at runtime.
     * @dev MUST be triggered when execute is not successfully due to any reason.
     */
    event ExecutionFailed (
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
     */
    event KeyRemoved (
        bytes32 indexed key,
        uint256 indexed purpose,
        uint256 indexed keyType
    );

    /**
     * @notice Emitted when the list of required keys to perform an action was updated.
     * @dev MUST be triggered when changeKeysRequired was successfully called.
     */
    event KeysRequiredChanged (
        uint256 purpose,
        uint256 number
    );

    // ====== CORE LOGIC ======
    /**
     * @notice Adds a key to the identity.
     * 
     * The 'Purposes' are the following ones:
     * 1- MANAGEMENT keys, which can manage the identity.
     * 2- ACTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
     * 3- CLAIM signer keys, used to sign claims on other identities which need to be revokable.
     * 4- ENCRYPTION keys, used to encrypt data e.g. hold in claims.
     * @dev Triggers event `KeyAdded`.
     * This call MUST only be done by keys of purpose 1, 
     * or the identity itself. If it's the identity itself, 
     * the approval process will determine its approval.
     *
     * @param _key Keccak256 representation of an ethereum address.
     * @param _purpose The key type as specified above.
     * @param _keyType Tpe of key used. e.g. 1 = ECDSA, 2 = RSA, etc.
     *
     * @return success Returns `True` if the addition was successful and `False` if not.
     */
    function addKey (
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    ) external returns (
        bool success
    );

    /**
     * @notice Removes the purpose of a specific _key from the identity.
     * @dev Triggers event `KeyRemoved`.
     * Must only be done by keys of purpose 1, or the identity itself.
     * If it's the identity itself, the approval process will determine its approval.
     */
    function removeKey (
        bytes32 _key,
        uint256 _purpose
    ) external returns (
        bool success
    );

    /**
    * @notice Approves an execution or claim addition.
    * @dev Triggers event `Approved`, `Executed`.
    * This SHOULD require n of m approvals of keys purpose 1, 
    * if the _to of the execution is the identity contract itself, to successfully approve an execution.
    * And COULD require n of m approvals of keys purpose 2, 
    * if the _to of the execution is another contract, to successfully approve an execution.
    */
    function approve (
        uint256 _id,
        bool _approve
    ) external returns (
        bool success
    );

    /**
     * @notice Passes an execution instruction to an ERC725 identity.
     * @dev Triggers event `ExecutionRequested`
     * SHOULD require approve to be called with one or more keys of purpose 1 or 2 to approve this execution.
     * Execute COULD be used as the only accessor for `addKey` and `removeKey`.
     */
    function execute (
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external payable returns (
        uint256 executionId
    );

    // ===== VIEW FUNCTIONS ======
    /**
     * @notice Returns the full key data, if present in the identity.
     * @dev The key for non-hex and long keys, its the Keccak256 hash of the key.
     *
     * @param _key The desired public key value.
     *
     * @return purposes Returns the full key data, if present in the identity.
     * @return keyType Returns the full key data, if present in the identity.
     * @return key Returns the full key data, if present in the identity.
     */
    function getKey (
        bytes32 _key
    ) external view returns (
        uint256[] memory purposes,
        uint256 keyType,
        bytes32 key
    );

    /**
     * @notice Returns the list of purposes associated with a key.
     *
     * @param _key The desired public key value.
     *
     * @return _purposes Returns the purposes of the specified key
     */
    function getKeyPurposes (
        bytes32 _key
    ) external view returns (
        uint256[] memory _purposes
    );

    /**
     * @notice Returns an array of public key bytes32 held by this identity.
     *
     * @param _purpose Purpose filter to get keys by.
     *
     * @return keys Array of public key hold by this identity.
     */
    function getKeysByPurpose (
        uint256 _purpose
    ) external view returns (
        bytes32[] memory keys
    );

    /**
     * @notice Returns TRUE if a key is present and has the given purpose.
     * If the key is not present it returns FALSE.
     */
    function keyHasPurpose (
        bytes32 _key,
        uint256 _purpose
    ) external view returns (
        bool exists
    );
}