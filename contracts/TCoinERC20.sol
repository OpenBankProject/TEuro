// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract TCoin is ERC20 {
    mapping(address => uint256) public balances;
    constructor() ERC20("TCoin", "TC") {
    _mint(msg.sender, 1000000000000) ;
    }

    function balanceOf(address _user) public view override returns(uint256) {
        return balances[_user];
    }
}
    