require("@nomiclabs/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-etherscan");
require("@typechain/hardhat");
const dotenv = require("dotenv");

require("./tasks");

dotenv.config();

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            accounts: {}
        }
    },
    paths: {
        artifacts: "./artifacts",
        cache: "./cache",
        sources: "./contracts",
        tests: "./tests",
    },
    typechain: {
        outDir: "./typechain",
        target: "ethers-v5",
    },
    solidity: { 
        compilers: [
            {
                version: "0.8.17",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 500
                    }
                }
            }
        ]
    }
};