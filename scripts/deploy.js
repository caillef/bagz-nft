const fs = require('fs')

const main = async () => {
  const bagzFactory = await hre.ethers.getContractFactory('BagzNFT');
  const bagzItemFactory = await hre.ethers.getContractFactory('BagzItemNFT');

  const bagzContract = await bagzFactory.deploy();
  await bagzContract.deployed();
  console.log("Bagz Contract deployed to:", bagzContract.address);

  // Used by script to deploy frontend
  try {
    fs.writeFileSync('./address.tmp', bagzContract.address)
  } catch (err) {
    console.error(err)
  }
  
  // const bagzItemContract = await bagzItemFactory.deploy(bagzContract.address);
  // await bagzItemContract.deployed();
  // console.log("Bagz Item Contract deployed to:", bagzItemContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();