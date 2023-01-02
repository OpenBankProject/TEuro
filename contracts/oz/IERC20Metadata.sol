// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1

pragma solidity ^0.8.17;

import "./IERC20.sol";

/**
 * @notice Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    
    /**
     * @notice Returns the name of the token.
     */
    function name() 
     external view returns (
        string memory
    );

    /**
     * @notice Returns the symbol of the token.
     */
    function symbol()
     external view returns (
        string memory
    );

    /**
     * @notice Returns the decimals places of the token.
     */
    function decimals()
     external view returns (
        uint8
    );
}