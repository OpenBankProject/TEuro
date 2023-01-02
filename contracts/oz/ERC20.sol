// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.8.0

pragma solidity ^0.8.17;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

/**
 * @notice Implementation of the { IERC20 } interface.
 * @dev This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using { _mint }.
 * Additionally, an { IERC20-Approval } event is emitted on calls to { IERC20-transferFrom }.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 * Finally, the non-standard { decreaseAllowance } and { increaseAllowance }
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See { IERC20-approve }.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {

    string private _name;           // The name for the token.
    string private _symbol;         // The symbol for the token.
    uint256 private _totalSupply;             // The latest value for total supply of tokens.

    // The token balances for each address.
    mapping(address => uint256) private _balances;
    // The token allowance of each address (owner) per `spender` address.
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @notice Sets the values for { _name } and { _symbol }.
     * @dev The default value of { decimals } is 18. To select a different value for
     * { decimals } you should overload it.
     *
     * @param name_ The name for the token.
     * @param symbol_ The symbol for the token. Usually a shorter version of the name.
     */
    constructor (
        string memory name_,
        string memory symbol_
    ) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @notice Returns the name of the token.
     */
    function name ()
     public view virtual override returns (
        string memory
    ) {
        return _name;
    }

    /**
     * @notice Returns the symbol of the token.
     */
    function symbol()
     public view virtual override returns (
        string memory
    ) {
        return _symbol;
    }

    /**
     * @notice Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     * @dev This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * { IERC20-balanceOf } and { IERC20-transfer }.
     */
    function decimals ()
     public view virtual override returns (
        uint8
    ) {
        return 18;
    }

    /**
     * @notice See { IERC20-totalSupply }.
     */
    function totalSupply ()
     public view virtual override returns (
        uint256
    ) {
        return _totalSupply;
    }

    /**
     * @notice See { IERC20-balanceOf }.
     */
    function balanceOf (
        address account
    )
     public view virtual override returns (
        uint256
    ) {
        return _balances[account];
    }

    /**
     * @notice See { IERC20-transfer }.
     */
    function transfer (
        address to,
        uint256 amount
    ) public virtual override returns (
        bool
    ) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @notice See { IERC20-allowance }.
     */
    function allowance (
        address owner,
        address spender
    ) public view virtual override returns (
        uint256
    ) {
        return _allowances[owner][spender];
    }

    /**
     * @notice See { IERC20-approve }.
     */
    function approve (
        address spender,
        uint256 amount
    ) public virtual override returns (
        bool
    ) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @notice See { IERC20-transferFrom }.
     */
    function transferFrom (
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @notice Atomically increases the allowance granted to `spender` by the caller.
     * @dev Requirements:
     * - `spender` cannot be the zero address.
     *
     * @param spender The authorized address to use the funds on behalf of the owner.
     * @param addedValue The additional amount of tokens to approve as allowance.
     */
    function increaseAllowance (
        address spender,
        uint256 addedValue
    ) public virtual returns (
        bool
    ) {
        address owner = _msgSender();
        _approve(
            owner, 
            spender, 
            allowance(owner, spender) + addedValue
        );
        return true;
    }

    /**
     * @notice Atomically decreases the allowance granted to `spender` by the caller.
     * @dev Requirements:
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     *
     * @param spender The authorized address to use the funds on behalf of the owner.
     * @param subtractedValue The amount of tokens to reduce from total allowance.
     */
    function decreaseAllowance (
        address spender, 
        uint256 subtractedValue
    ) public virtual returns (
        bool
    ) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(
                owner,
                spender,
                currentAllowance - subtractedValue
            );
        }

        return true;
    }

    /**
     * @notice Moves `amount` of tokens from `from` to `to`.
     * @dev This internal function is equivalent to { transfer }, 
     * and can be overwritten to be used for
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     * Emits a { IERC20-Transfer } event.
     * Requirements:
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     *
     * @param from The address that is sending the tokens.
     * @param to The destination address for the transfer.
     * @param amount The amount of tokens being transferred.
     */
    function _transfer (
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(
            from != address(0),
            "ERC20: transfer from the zero address"
        );
        require(
            to != address(0),
            "ERC20: transfer to the zero address"
        );

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        // decrementing then incrementing.
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** 
     * @notice Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     * @dev Emits a { IERC20-Transfer } event with `from` set to the zero address.
     * Requirements:
     * - `account` cannot be the zero address.
     *
     * @param account The target account to add the tokens to.
     * @param amount The amount of tokens to be minted.
     */
    function _mint (
        address account,
        uint256 amount
    ) internal virtual {
        require(
            account != address(0),
            "ERC20: mint to the zero address"
        );

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;

        // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @notice Destroys `amount` tokens from `account`, reducing the
     * total supply.
     * @dev Emits a { IERC20-Transfer } event with `to` set to the zero address.
     * Requirements:
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     *
     * @param account The target account to reduce the tokens from.
     * @param amount The amount of tokens to be burned.
     */
    function _burn (
        address account,
        uint256 amount
    ) internal virtual {
        require(
            account != address(0),
            "ERC20: burn from the zero address"
        );

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(
            accountBalance >= amount,
            "ERC20: burn amount exceeds balance"
        );

        // Overflow not possible: amount <= accountBalance <= totalSupply.
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @notice Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * @dev This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     * Emits an { IERC20-Approval } event.
     * Requirements:
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * @param owner The owner of the funds to be used by the spender.
     * @param spender The authorized address to use the funds on behalf of the owner.
     * @param amount The amount of tokens to approve as allowance.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            owner != address(0),
            "ERC20: approve from the zero address"
        );
        require(
            spender != address(0),
            "ERC20: approve to the zero address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Updates `owner` s allowance for `spender` based on spent `amount`.
     * @dev Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     * Might emit an { Approval } event.
     *
     * @param owner The owner of the funds to be used by the spender.
     * @param spender The authorized address to use the funds on behalf of the owner.
     * @param amount The amount of tokens to approve as allowance.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @notice Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     * @dev Calling conditions:
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * @param from The address that is sending the tokens.
     * @param to The destination address for the transfer.
     * @param amount The amount of tokens being transferred.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @notice Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     * @dev Calling conditions:
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * @param from The address that is sending the tokens.
     * @param to The destination address for the transfer.
     * @param amount The amount of tokens being transferred.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}