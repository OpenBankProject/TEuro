// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract TCoin is ERC20 {
    constructor() ERC20("TCoin", "TC") {
    _mint(msg.sender, 200000000 * 10 ** decimals());
    }
}
    