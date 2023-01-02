// SPDX-License-Identifier: MIT
// OpenZeppelin Contract v4.6.0

pragma solidity ^0.8.17;

/**
 * @notice Interface of the ERC20 standard as defined in the EIP.
 * https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {

    /**
     * @notice Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     * @dev `value` may be zero.
     *
     * @param from The address that is sending the tokens.
     * @param to The destination address for the transfer.
     * @param value The amount of tokens being transferred.
     */
    event Transfer (
        address indexed from,
        address indexed to,
        uint256 value
    );

    /**
     * @notice Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to { approve }. `value` is the new allowance.
     *
     * @param owner The owner of the funds to be used by the spender.
     * @param spender The authorized address to use the funds on behalf of the owner.
     * @param value The amount of tokens to approve as allowance.
     */
    event Approval (
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Returns the amount of tokens in existence.
     */
    function totalSupply () 
     external view returns (
        uint256
    );

    /**
     * @notice Returns the amount of tokens owned by `account`.
     */
    function balanceOf (
        address account
    ) external view returns (
        uint256
    );

    /**
     * @notice Moves `amount` tokens from the caller's account to `to`.
     * Returns a boolean value indicating whether the operation succeeded.
     * @dev Emits a { Transfer } event.
     * Requirements:
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     *
     * @param to The destination address of the transfer.
     * @param amount The amount of tokens being transferred.
     */
    function transfer (
        address to,
        uint256 amount
    ) external returns (
        bool
    );

    /**
     * @notice Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through { transferFrom }.
     * This is zero by default.
     * @dev This value changes when { approve } or { transferFrom } are called.
     *
     * @param owner The owner of the funds to be used by the spender.
     * @param spender The authorized address to use the funds on behalf of the owner.
     */
    function allowance (
        address owner,
        address spender
    ) external view returns (
        uint256
    );

    /**
     * @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * @dev Emits an { Approval } event.
     * If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * Requirements:
     * - `spender` cannot be the zero address.
     *
     * @param spender The authorized address to use the funds on behalf of the owner.
     * @param amount The amount of tokens to approve as allowance.
     */
    function approve (
        address spender,
        uint256 amount
    ) external returns (
        bool
    );

    /**
     * @notice Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * @dev Emits a { Transfer } event.
     * Does not update the allowance if the current allowance is the maximum `uint256`.
     * Requirements:
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for `from`'s tokens of at least
     * `amount`.
     *
     * @param from The address that is sending the tokens.
     * @param to The destination address for the transfer.
     * @param amount The amount of tokens being transferred.
     */
    function transferFrom (
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}