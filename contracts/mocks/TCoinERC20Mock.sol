// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC20 } from "../oz/ERC20.sol";

/**
 * @notice Implementation of the { ERC20 } for testing purposes.
 * @dev Implements a simple mechanism to access minting and burning functionalities.
 */
contract MockERC20 is ERC20 {
    
    /**
     * @notice Initializes the token with the ERC20 inheritance,
     * and mints an initial supply of tokens.
     *
     * @param name The name for the token.
     * @param symbol The symbol for the token.
     * @param initialBalance The amount of tokens to mint at the beginning.
     */
    constructor (
        string memory name,
        string memory symbol,
        uint256 initialBalance
    ) ERC20 (
        name,
        symbol
    ) {
        _mint(msg.sender, initialBalance);
    }
}