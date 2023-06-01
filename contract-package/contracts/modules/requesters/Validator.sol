// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Validator
 * @author OBP - Open Bank Project
 *
 * @notice RrpRequesterV0 implementation for validation API that would
 * provide oracle functionalities for identity verification.
 */
contract Validator is 
    RrpRequesterV0,
    AccessControl
{
    // ====== STORAGE ======
    bytes32 public constant READER = keccak256("READER");        // Role for accessing user data.
    bytes32 public constant REQUESTER = keccak256("REQUESTER");  // Role for requesting user data.

    /**
     * @notice Definitions for posible user statuses.
     *
     * @param INVALID - If the user address has not been KYC validated.
     * @param VALID - If the user address has been KYC validated.
     */
    enum UserStatus {
        INVALID,
        VALID
    }

    address public airnode;              // The address of the airnode.
    bytes32 internal endpointId;         // The endpointId to be use by the requester.
    address internal derivedAddress;     // The derived address to be sponsored.
    address internal sponsorAddress;     // The sponsored wallet address that will pay for fulfillments.

    mapping(bytes32 => bool) public fulfillments; // Mapping of request ID to fulfillment status.
    mapping(bytes32 => address) internal requestToUser; // Mapping of request ID to user address.
    mapping(address => UserStatus) internal userStatus; // Mapping of user address to user latest user status.

    // ====== EVENTS ======
    /** 
     * @dev Emitted when we set airnode related paramters.
     * 
     * @param airnodeAddress - The Airnode address being use.
     * @param endpointId - The endpointId being used.
     * @param derivedAddress - The derived address from the airnode-sponsor.
     * @param sponsorAddress - The actual sponsor address.
     */ 
    event SetRequestParameters ( 
        address airnodeAddress,
        bytes32 endpointId,
        address derivedAddress,
        address sponsorAddress
    );

    /**
     * @dev Emitted when the status of a user is updated.
     *
     * @param userAddress - The address of the user.
     * @param status - The new status of the user.
     */
    event UserStatusUpdated (
        address userAddress,
        UserStatus status
    );

    /**
     * @dev Emitted when an update request is made.
     *
     * @param _requestId The requestId being used.
     * @param _targetUser The user address being updated.
     * @param _userId The user id being used.
     */
    event UpdateRequest (
        bytes32 _requestId,
        address _targetUser,
        uint256 _userId
    );

    // ====== ERRORS ======
    error RequestIdNotKnown ();

    // ====== CONSTRUCTOR ======
    /** 
     * @notice Constructor function for requester contract.
     *
     * @param _rrpV0address The AirnodeRrpV0 address for the selected network.
     */
    constructor (
        address _rrpV0address
    ) RrpRequesterV0(
        _rrpV0address
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(READER, msg.sender);
        _setupRole(REQUESTER, msg.sender);
    }

    // ====== MODIFIERS ======
    /**
     * @notice Validates if the given requestId exists.
     *
     * @param _requestId The requestId being used.
     */
    modifier validRequest (
        bytes32 _requestId
    ) {
        if (fulfillments[_requestId] == false) {
            revert RequestIdNotKnown();
        }
        _;
    }

    // ====== CORE LOGIC ======
    /**                                                                                           
     * @notice Sets parameters used for calling the airnode.
     *
     * @param _airnode - The airnode address.
     * @param _sponsorAddress - The sponsore address.
     * @param _derivedAddress - The derived address to sponsor.
     */
    function setRequestParameters (
        address _airnode,
        bytes32 _endpointId,
        address _derivedAddress,
        address _sponsorAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        airnode = _airnode;
        endpointId = _endpointId;
        derivedAddress = _derivedAddress;
        sponsorAddress = _sponsorAddress;

        emit SetRequestParameters(
            _airnode,
            _endpointId,
            _derivedAddress,
            _sponsorAddress
        );
    }

    /** 
     * @notice Calls the airnode to validate a user address.
     */
    function callAirnode (
        address _targetUser,
        uint256 _userId
    ) external onlyRole(REQUESTER) {
        bytes memory _parameters = abi.encode(
            uint256(_userId)
        );

        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointId,
            sponsorAddress,
            derivedAddress,
            address(this),
            this.updateUserStatus.selector,
            _parameters
        );

        requestToUser[requestId] = _targetUser;
        fulfillments[requestId] = true;

        emit UpdateRequest(
            requestId,
            _targetUser,
            _userId
        );
    }

    /**
     * @notice Callback function to index api data onchain.
     *
     * @param requestId - The request ID.
     * @param data - The data returned by the fulfillment.
     */
    function updateUserStatus (
        bytes32 requestId,
        bytes calldata data
    ) external onlyAirnodeRrp validRequest(requestId) {
        UserStatus status = abi.decode(data, (bool)) == true ? UserStatus.VALID : UserStatus.INVALID;
        address userAddress = requestToUser[requestId];

        if (status != userStatus[requestToUser[requestId]]) {
            userStatus[userAddress] = status;
            emit UserStatusUpdated(
                userAddress,
                status
            );
        }

        delete requestToUser[requestId];
        delete fulfillments[requestId];
    }

    // ====== VIEW FUNCTIONS ======
    /**
     * @notice Returns whether an address is valid or not.
     * @dev Is up to the user to verify if the given address has been recently
     * validated. So running an update could change the results.
     *
     * @param _userAddress - The target user address.
     *
     * @return _status - Whether the address has been validated or not.
     */
    function getUserStatus (
        address _userAddress
    ) external view onlyRole(READER) returns (
        bool _status
    ) {
        if (userStatus[_userAddress] == UserStatus.VALID) return true;
        else return false;
    }
}
