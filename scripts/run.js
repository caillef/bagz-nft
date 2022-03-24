const main = async () => {
  const bagzFactory = await hre.ethers.getContractFactory('BagzNFT');
  const bagzItemFactory = await hre.ethers.getContractFactory('BagzItemNFT');

  const bagzContract = await bagzFactory.deploy();
  await bagzContract.deployed();
  console.log("Bagz Contract deployed to:", bagzContract.address);
  const bagzItemContract = await bagzItemFactory.deploy(bagzContract.address);
  await bagzItemContract.deployed();
  console.log("Bagz Item Contract deployed to:", bagzItemContract.address);

  await bagzContract.registerBagzItemContract(bagzItemContract.address)

  let txn = await bagzContract.mint()
  await txn.wait()

    txn = await bagzContract.tokenURI(1);
  console.log(txn)

  txn = await bagzContract.addItem(1, "Stone", 10);
  await txn.wait()

  txn = await bagzContract.tokenURI(1);
  console.log(txn)

  txn = await bagzContract.extractItem(1, "Stone", 3);
  await txn.wait()

  txn = await bagzContract.tokenURI(1);
  console.log(txn)

  console.log("Content of bag:")
  await bagzContract.showBag(1, ["Stone", "Gravel", "Diamond"])
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