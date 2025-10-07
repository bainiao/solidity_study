npm init
npm install hardhat --save-dev
npx hardhat --init
npx hardhat compile
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost

npx hardhat verify --network <network> <contract-address> <constructor-args>

npx hardhat run scripts/deploy.js --network <network>