// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./IERC734.sol";
import "./IERC735.sol";

interface IIdentity is IERC734, IERC735 {
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