// scripts/deploy.js
async function main () {
  // We get the contract to deploy
  const TCoin = await ethers.getContractFactory('TCoinERC20');
  console.log('Deploying TCoin...');
  const tcoin = await TCoin.deploy();
  await tcoin.deployed();
  console.log('TCoin deployed to:', tcoin.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
