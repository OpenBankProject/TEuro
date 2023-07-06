// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TEuro
 * @author TESOBE GmbH
 *
 * @notice Implementation of Transparent Token from TESOBE GmbH.
 */
contract TEuro is ERC20, Ownable {

    struct User {
        string name;
        uint256 id;
        bool isVerified;
    }

    mapping (address => User) verifications;

    constructor (
        string memory name_,
        string memory symbol_
    ) ERC20 (
        name_,
        symbol_
    ) {
        verifications[msg.sender] = User(
            "OBP",
            1,
            true
        );
    }

    // ===== MOCK FUNCTIONS =====
    /**
     * @notice Mock function to mimick actual verification system.
     * @dev This would be replace by IdentityRegistry.
     *
     * @param _name Name of the user to include as verified.
     * @param _id Id of the user to include as verified.
     * @param _targetUser Address to include as verified.
     */
    function addVerification (
        string calldata _name,
        uint256 _id,
        address _targetUser
    ) external onlyOwner {
        if (verifications[_targetUser].isVerified == true) {
            revert ("User already verified!");
        }

        verifications[_targetUser] = User(
            _name,
            _id,
            true
        );
    }

    /**
     * @notice Mock function to mimick actual verification system.
     * @dev This would be replace by IdentityRegistry.
     *
     * @param targetUser Address to remove as verified.
     */
    function removeVerification (
        address targetUser
    ) external onlyOwner {
        if (verifications[targetUser].isVerified == false) {
            revert ("User was not verified!");
        }

        verifications[targetUser].isVerified = false;
    }

    /**
     * @notice Mock function to mimick actual verification system.
     * @dev This would be replace by IdentityRegistry.
     *
     * @param targetUser Address to remove as verified.
     */
    function isVerified (
        address targetUser
    ) external view returns (
        User memory user_
    ) {
        return verifications[targetUser];
    }

    /**
     * @notice Wrapper around `_mint` function.
     * @dev Already implements hook for verification trough
     * `_beforeTokenTransfer`.
     *
     * @param to The destination address of the tokens.
     * @param amount The number of tokens to mint.
     */
    function mint (
        address to,
        uint256 amount
    ) external onlyOwner {
        _mint(
            to,
            amount
        );
    }

    // ===== HERLPERS =====
    /**
     * @notice Backward compatibility with ERC20 transfer workflow
     * including identity validation.
     * @dev This hook will execute on every type of transfer as is used
     * by the original implementation `_transfer` and won't affect other
     * ERC20 functionalities.
     *
     * @param from The account sending the funds.
     * @param to The account recieving the funds.
     * @param amount JUST FOR COMPATIBILITY, IS NOT MEANT TO BE USED.
     */
    function _beforeTokenTransfer (
        address from,
        address to,
        uint256 amount
    ) internal virtual view override 
    {
        if (verifications[from].isVerified == false && 
            from != address(0)
        ) {
            revert("Sender address is not verified!");
        }

        if (verifications[to].isVerified == false) {
            revert("Reciever address is not verified!");
        }
    }
}
