// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TCoinERC20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("TCoin", "TC") {
        _mint(msg.sender, initialSupply);
    }
}
    