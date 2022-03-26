#!/bin/bash

npx hardhat run scripts/deploy.js --network localhost
./scripts/updateContractForFrontend.sh `cat address.tmp`
rm address.tmp