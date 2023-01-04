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
     /**
     * @notice Mints a given amount of tokens to the provided target account.
     *
     * @param account The address to recieve the tokens.
     * @param amount The number of tokens to mint.
     */
    function mint (
        address account,
        uint256 amount
    ) external {
        _mint(account, amount);
    }

    /**
     * @notice Burns a given amount of tokens from the provided target account.
     *
     * @param account The address to burn the tokens from.
     * @param amount The number of tokens to burn.
     */
    function burn (
        address account,
        uint256 amount
    ) external {
        _burn(account, amount);
    }
}