# Bagz NFT

## How to run locally

3 terminals

```bash
npm install
npx hardhat node
```

```bash
npx hardhat run scripts/deploy.js --network localhost
```

```bash
cd web3-react-boilerplate
npm install
npm start
```


hardhat.config.js
```js
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts: [ private_key (from generated accounts) ]  
    },
    rinkeby: {
      url: eth-rinkeby.alchemyapi.io_URL,
      accounts: [ private_key ]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  }
};
```