# Gigacounts blockchain

## Requirements

The App requires:

- [Node.js](https://nodejs.org/) v16+ to run (^16.14.2).
- [Yarn.js](https://classic.yarnpkg.com/en/docs/install) v1+ to run (^1.22.19).
- [hardhat](https://hardhat.org/)

- You could check the version of packages (node, yarn) with these commands:

```sh
node -v
yarn -v
```

## Install the dependencies

```sh
- yarn install # with yarn
- npm i OR npm i --legacy-peer-deps # with NPM
```

If you have some trouble with dependencies, try this:

```sh
set http_proxy=
set https_proxy=
npm config rm https-proxy
npm config rm proxy
npm config set registry "https://registry.npmjs.org"
yarn cache clean
yarn config delete proxy
yarn --network-timeout 100000
```

Create a .env file running the command in terminal

```sh
touch .env
```

## Environment variables

The environment variables below needs to be set in the .env file when the project is running locally.

```sh
INFURA_ID={your infura project id}
ALCHEMY_ID={your infura api key}
PUBLIC_ADDRESS={your wallet address}
PRIVATE_KEY={your private key to deploy SCs}
```

> Note: You can find more info about the other required `.env` variables inside the `example_env` file.


## Commands

```shell
# Run testnet
yarn hardhat node

# Compile
npx hardhat compile

# Test
npx hardhat test

# Deploy to local
npx hardhat run scripts/deploy.ts --network localhost

# Deploy to Mumnbai 
npx hardhat run scripts/deploy.ts --network mumbai

# Solidity Security and Style guides validations with solhint [https://protofire.github.io/solhint/]
npm install -g solhint
solhint 'contracts/**/*.sol'

# Solidity Static Analysis [https://github.com/crytic/slither]
slither .
```

## Deployment 

When deploying the handler contract: 

- Update the handler contract address in settings table in database.
- Update the ABI code of the handler to both the frontend and backend.
- Add the user scheduler's wallet as an owner. 
- Add the user admin's wallet as an owner. 
- Call the 'addSupportedToken' function with the address of the GIGA ERC20 Token. 
- Increase the allowance in the ERC20 Token contract for the handler's address.


## Development Smart Contracts Addresses

- Gigacounts Token Address: 0x5c9b946cCc153db707C4D72C15338122FBf830bf
- Handler Token Address: 0x75F3DdDC86905c2e202DD2c9260B341D0be5aa9C

## TODO (Improvements)

- Separate data logic into two smart contracts.
- Maintain history of smart contract implementations (logic and data) to have the physical contract + SC relationship (due to changes in the ABI).
