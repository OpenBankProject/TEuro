// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import  "@api3/airnode-protocol/contracts/rrp/interfaces/IAirnodeRrpV0.sol";

/**
 * @title MockAirnodeRrpV0
 * @author TESOBE GmbH
 *
 * @notice Mock version from API3 Contract for testing purposes.
 * @dev Security checks have been removed.
 */
contract MockAirnodeRrpV0 is IAirnodeRrpV0 {
    mapping(bytes32 => bytes32) public requestIdToFulfillmentParameters;

    function makeFullRequest (
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external override returns (
        bytes32 requestId
    ) {
        requestId = keccak256(
            abi.encodePacked(
                address(this),
                msg.sender,
                airnode,
                endpointId,
                sponsor,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId,
                parameters
            )
        );
        requestIdToFulfillmentParameters[requestId] = keccak256(
            abi.encodePacked(
                airnode,
                fulfillAddress,
                fulfillFunctionId
            )
        );
    }

    function fulfill (
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external override returns (
        bool callSuccess,
        bytes memory callData
    ) {
        require(
            keccak256(
                abi.encodePacked(
                    airnode,
                    fulfillAddress,
                    fulfillFunctionId
                )
            ) == requestIdToFulfillmentParameters[requestId],
            "Invalid request fulfillment"
        );

        delete requestIdToFulfillmentParameters[requestId];
        (callSuccess, callData) = fulfillAddress.call(
            abi.encodeWithSelector(
                fulfillFunctionId,
                requestId,
                data
            )
        );

        emit FulfilledRequest(
            airnode,
            requestId,
            data
        );
    }

    function fail (
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external virtual {}

    function setSponsorshipStatus (
        address requester,
        bool sponsorshipStatus
    ) external virtual {}

    function makeTemplateRequest (
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external virtual returns (
        bytes32 requestId
    ) {}

    function sponsorToRequesterToSponsorshipStatus (
        address sponsor,
        address requester
    ) external view virtual returns (
        bool sponsorshipStatus
    ) {}

    function requesterToRequestCountPlusOne (
        address requester
    ) external view virtual returns (
        uint256 requestCountPlusOne
    ) {}

    function requestIsAwaitingFulfillment (
        bytes32 requestId
    ) external view virtual returns (
        bool isAwaitingFulfillment
    ) {}

    function checkAuthorizationStatus (
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view virtual returns (
        bool status
    ) {}

    function checkAuthorizationStatuses (
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view virtual returns (
        bool[] memory statuses
    ) {}

    function createTemplate (
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external virtual returns (
        bytes32 templateId
    ) {}

    function getTemplates (
        bytes32[] calldata templateIds
    ) external view virtual returns (
        address[] memory airnodes,
        bytes32[] memory endpointIds,
        bytes[] memory parameters
    ) {}

    function templates (
        bytes32 templateId
    ) external view virtual returns (
        address airnode,
        bytes32 endpointId,
        bytes memory parameters
    ) {}

    function requestWithdrawal (
        address airnode,
        address sponsorWallet
    ) external virtual {}

    function fulfillWithdrawal (
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external virtual payable {}

    function sponsorToWithdrawalRequestCount (
        address sponsor
    ) external view virtual returns (
        uint256 withdrawalRequestCount
    ) {}
}