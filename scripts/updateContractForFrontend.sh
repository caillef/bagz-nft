if [ $# -lt 1 ]; 
   then 
   printf "Not enough arguments - %d\n" $#
   exit 0 
fi 

sed -i "s/const BAGZ_ADDRESS.*/const BAGZ_ADDRESS = '$1'\r/g" web3-react-boilerplate/src/App.tsx
cp artifacts/contracts/BagzNFT.sol/BagzNFT.json web3-react-boilerplate/src/utils/BagzNFT.json

echo "Contract updated in App.jsx and ABI copied in src/utils"