// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import { Validator } from "../modules/requesters/Validator.sol";

/**
 * @title MockValidator
 * @author TESOBE GmbH
 *
 * @notice This is a mock contract for Validator with the purpose
 * of testing additional features not accessible from the original
 * contract like `internal` storage variables and functions.
 */
contract MockValidator is Validator {
    // ====== CONSTRUCTOR ======
    /** 
     * @notice Constructor function for requester contract.
     *
     * @param _rrpV0address The AirnodeRrpV0 address for the selected network.
     */
    constructor (
        address _rrpV0address
    ) Validator (
        _rrpV0address
    ) {}

    // ====== VIEW FUNCTIONS ======
    /**
     * @notice Returns the user a given requestId is mapped to.
     *
     * @param _requestId The target request ID.
     *
     * @return _userAddress Target user address.
     */
    function getUserByRequestId (
        bytes32 _requestId
    ) external view returns (
        address _userAddress
    ) {
        return requestToUser[_requestId];
    }

    /**
     * @notice Returns the private `endpointId` value.
     *
     * @return _endpointId The endpointId set for this contract.
     */
    function getEndpointId () 
     external view returns (
        bytes32
    ) {
        return endpointId;
    }

    /**
     * @notice Returns the internal `derivedAddress` value.
     *
     * @return _derivedAddress The derivedAddress set for this contract.
     */
    function getDerivedAddress ()
     external view returns (
        address
    ) {
        return derivedAddress;
    }

    /**
     * @notice Returns the internal `sponsorAddress` value.
     *
     * @return _sponsorAddress The sponsorAddress set for this contract.
     */
    function getSponsorAddress ()
     external view returns (
        address
    ) {
        return sponsorAddress;
    }
}
