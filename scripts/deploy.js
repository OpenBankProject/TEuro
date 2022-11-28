const hre = require("hardhat");

async function main() {

  const TCoin = await hre.ethers.getContractFactory("TCoinERC20");
  console.log('Deploying TCoin...');
  const token = await TCoinERC20.deploy('10000000000000000000000');

  await token.deployed();
  console.log("TCoin deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
