const { task } = require("hardhat/config");
const { getProvider, writeJsonFile } = require("../scripts/utils");

task("deploy", "Deploys TCoin contract")
  .addParam(
    "networkname",
    "The network to deploy to"
    )
  .setAction(async (taskArgs, hre) => {
    const provider = getProvider(taskArgs.networkname);
    const tCoinFactory = await hre.ethers.getContractFactory(
      "TCoin",
      provider
    );
    const tCoin = await tCoinFactory.deploy(
      "Test TCoin",
      "TEST"
    );
    console.log("TCoin deployed to: ", tCoin.address); 
    writeJsonFile(
      {"TCoin": tCoin.address},
      `addresses/${taskArgs.networkname}.json`,
      "w"
    );
  });
