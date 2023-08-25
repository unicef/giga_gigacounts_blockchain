import "@nomiclabs/hardhat-ethers";
// @ts-ignore
import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config()

async function main() {
    console.log('Getting the Gigacounts token contract...');
    const Token = await ethers.getContractFactory('GigacountsToken');
    const token = await Token.deploy();
    await token.deployed();
    const tokenSymbol = await token.symbol();
    const tokenDecimals = await token.decimals();

    console.log('Getting the Gigacounts handler contract...');
    const Handler = await ethers.getContractFactory('GigacountsContractHandlerV5');
    const handler = await Handler.deploy(Handler)

    console.log('Getting Signers...');
    const signers = await ethers.getSigners();
    const owner = signers[0]
    
    console.log('Adding supported token...');
    await handler.connect(owner).addSupportedToken(token.address, tokenSymbol, tokenDecimals);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });