// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import { IERC734 } from "./IERC734.sol";
import { IERC735 } from "./IERC735.sol";

/**
 * @title IIdentity.
 * @author TESOBE GmbH.
 *
 * @notice Interface for Identity Contract.
 * Represents the identity of a single user in the system.
 * Contains all the keys and claims for the given user.
 * @dev This contract is intended to be cloned trough a factory pattern.
 */
interface IIdentity is IERC734, IERC735 {
    // ===== UPGRADES =====
    /**
     * @notice Gets the current version of the contract.
     *
     * @return _version The current version of the contract.
     */
    function version ()
     external pure returns (
        uint256 _version
    );
}