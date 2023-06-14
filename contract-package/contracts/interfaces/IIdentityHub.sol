// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IIdentity } from "../identity/IIdentity.sol";
import '../registry/ITrustedIssuersRegistry.sol';
import '../registry/IClaimTopicsRegistry.sol';

/**
 * @title IIdentityHub.
 * @author TESOBE GmbH.
 *
 * @notice Interface for Identity Hub.
 * Manages all the lifecycle for identites of the platform.
 * @dev This contract is intended to be used by authorized operators.
 * The contract is intended to be used as a UUPS proxy.
 */
interface IIdentityHub {
    // ===== EVENTS =====
    /**
     * @notice Emitted when the ClaimTopicsRegistry has been set.
     * 
     * @param claimTopicsRegistry Address of the setted Claim Topics Registry contract.
     * @param timestamp Timestamp of the event.
     */
    event ClaimTopicsRegistrySet (
        address indexed claimTopicsRegistry,
        uint256 timestamp
    );

    /**
     * @notice Emitted when the ClaimTopicsRegistry has been set.
     * 
     * @param trustedIssuersRegistry Address of the setted Trusted Issuers Registry contract.
     * @param timestamp Timestamp of the event.
     */
    event TrustedIssuersRegistrySet (
        address indexed trustedIssuersRegistry,
        uint256 timestamp
    );

    /**
     * @notice Emitted when an Identity is registered into the registry.
     * @dev Should be emitted by the `registerIdentity` function.
     * 
     * @param userAddress Address of the user's wallet.
     * @param identity Address of the Identity's contract.
     * @param timestamp Timestamp of the event.
     */
    event IdentityRegistered (
        address indexed userAddress,
        address indexed identity,
        uint256 timestamp
    );

    /**
     * @notice Emitted when an Identity is removed from the registry.
     * @dev Should be emitted by the `deleteIdentity` function.
     * 
     * @param userAddress Address of the user's wallet.
     * @param identity Address of the Identity's contract.
     * @param timestamp Timestamp of the event.
     */
    event IdentityRemoved (
        address indexed userAddress,
        address indexed identity,
        uint256 timestamp
    );

    /**
     * @notice Emitted when an Identity contract address has been updated.
     * @dev Should be emitted by the `updateIdentity` function.
     * 
     * @param oldIdentity Old Identity contract's address.
     * @param newIdentity New Identity contract's address set.
     * @param timestamp Timestamp of the event.
     */
    event IdentityUpdated (
        address indexed oldIdentity,
        address indexed newIdentity,
        uint256 timestamp
    );

    /**
     * @notice Emitted when an Identity's country has been updated.
     * @dev Should be emitted by the `updateCountry` function.
     * 
     * @param userAddress Address of the user on which the country has been updated.
     * @param country Numeric code (ISO 3166-1) of the new country.
     * @param timestamp Timestamp of the event.
     */
    event CountryUpdated (
        address indexed userAddress,
        uint16 indexed country,
        uint256 timestamp
    );

    // ===== VIEWS =====
    /**
     * @notice This functions checks whether a wallet has its Identity registered or not.
     * 
     * @param _userAddress The address of the user to be checked.
     * 
     * @return 'True' if the address is contained in the registry, 'false' if not.
     */
    function isRegistered (
        address _userAddress
    ) external view returns (
        bool
    );

    /**
     * @notice This functions checks whether an identity contract
     * corresponding to the provided user address has the required claims or not based
     * on the data fetched from trusted issuers registry and from the claim topics registry.
     * 
     * @param _userAddress The address of the user to be verified.
     *
     * @return _isVerified 'True' if the address is verified, 'false' if not.
     */
    function isVerified (
        address _userAddress
    ) external view returns (
        bool _isVerified
    );

    /**
     * @notice Returns the Identity's contract of a user.
     * 
     * @param _userAddress The wallet of the user.
     *
     * @return _identityContract Instance of the Identity's contract for the given user.
     */
    function getIdentity (
        address _userAddress
    ) external view returns (
        address _identityContract
    );

    /**
     * @notice Returns the country code of a user.
     * 
     * @param _userAddress The wallet of the user.
     *
     * @return _investorCountry Numeric code (ISO 3166-1) of the country of the user.
     */
    function getInvestorCountry (
        address _userAddress
    ) external view returns (
        uint16 _investorCountry
    );

    /**
     * @notice Returns the TrustedIssuersRegistry contract address.
     *
     * @return _trustedIssuersRegistry Address of the TrustedIssuersRegistry contract.
     */
    function getIssuersRegistry ()
     external view returns (
        address _trustedIssuersRegistry
    );

    /**
     * @notice Returns the ClaimTopicsRegistry contract address.
     */
    function topicsRegistry ()
     external view returns (
        address _claimTopicsRegistry
    );

    // ===== HELPER FUNCTIONS =====
    /**
     * @notice Replace the current 'ClaimTopicsRegistry' contract with a new one.
     * @dev This function should be ownable.
     * 
     * @param _claimTopicsRegistry The new address of the ClaimTopicsRegistry.
     */
    function setClaimTopicsRegistry (
        address _claimTopicsRegistry
    ) external;

    /**
     * @notice Replace the current 'TrustedIssuersRegistry' contract with a new one.
     * @dev This function should be ownable.
     *
     * @param _trustedIssuersRegistry The new address of the TrustedIssuersRegistry.
     */
    function setTrustedIssuersRegistry (
        address _trustedIssuersRegistry
    ) external;

    /**
     * @notice Adds an address as an agent of the hub.
     * @dev This function should be ownable.
     * 
     * @param _agent The agent's address to add.
     */
    function addAgent (
        address _agent
    ) external;

    /**
     * @notice Removes an address from being an agent of the hub.
     * @dev This function should be ownable.
     *
     * @param _agent The agent's address to remove.
     */
    function removeAgent (
        address _agent
    ) external;

    // ===== CORE FUNCTIONS =====
    /**
     * @notice Generates an identity contract corresponding to a new user address.
     * @dev Requires that the user doesn't have an identity contract already registered.
     * This function can only be called by a wallet set as agent.
     *
     * @param _userAddress The address of the user.
     * @param _country The country of the investor.
     */
    function registerIdentity (
        address _userAddress,
        uint16 _country
    ) external;

    /**
     * @notice Removes a user from the registry.
     * @dev Requires that the user have an identity contract already deployed that will be deleted.
     * This function can only be called by a wallet set as agent.
     * 
     * @param _userAddress The address of the user to be removed.
     */
    function deleteIdentity (
        address _userAddress
    ) external;

    /**
     * @notice Updates the country corresponding to a user address.
     * @dev Requires that the user should have an identity contract already deployed that will be replaced.
     * This function can only be called by a wallet set as agent of the smart contract
     * 
     * @param _userAddress The address of the user
     * @param _country The new country of the user
     */
    function updateCountry (
        address _userAddress,
        uint16 _country
    ) external;

    /**
     * @notice Creates a new identity contract for the given user address.
     * Requires that the user address should be the owner of the old identity contract.
     * This function can only be called by a wallet set as agent of the smart contract.
     *
     * @param _userAddress The address of the user.
     */
    function updateIdentity (
        address _userAddress
    ) external;
}