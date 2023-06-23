// Hardhat config file

require("@nomiclabs/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config()

require("./tasks");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            accounts: {}
        },
        mumbai: {
            url: process.env.MUMBAI_URL,
            accounts: [process.env.PRIVATE_KEY] || []
        }
    },
    paths: {
        artifacts: "./artifacts",
        cache: "./cache",
        sources: "./contracts",
        tests: "./tests",
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
    },
    etherscan: {
        apiKey: {
            polygonMumbai: process.env.POLYGON_SCAN || ""
        }
    }
};
