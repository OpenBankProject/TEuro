// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1

pragma solidity ^0.8.17;

/**
 * @notice Provides information about the current execution context, including the
 * sender of the transaction and its data. 
 * @dev While these are generally available via msg.sender and msg.data, 
 * they should not be accessed in such a direct manner,
 * since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 */
abstract contract Context {

    /**
     * @notice Returns the sender of the transaction.
     */
    function _msgSender() 
     internal view virtual returns (
        address
    ) {
        return msg.sender;
    }

    /**
     * @notice Returns the `data` value from the transaction.
     */
    function _msgData()
     internal view virtual returns (
        bytes calldata
    ) {
        return msg.data;
    }
}