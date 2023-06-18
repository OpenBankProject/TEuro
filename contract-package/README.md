# TCoin Contracts

This package implements the TCoin from TESOBE GmbH. 
Based out from an ERC20 token standard, it includes identity verification capabilities.

## Contracts
The contracts are build using Solidity 0.8.17.

- oz: Includes all the Openzeppelin contracts being used in the package.
- identity: Is the module that includes all the functionality related to the identity of the users.
- mocks: Is a set of contracts created for testing purposes.
- Token.sol: Is the main contract of the `TCoin`.

## References
- [Key Manager](https://github.com/ethereum/EIPs/issues/734)
- [Claim Holder](https://github.com/ethereum/EIPs/issues/735)
- [ERC20](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20)
