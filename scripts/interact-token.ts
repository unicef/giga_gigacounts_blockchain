import "@nomiclabs/hardhat-ethers";
import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config()

async function main() {
    console.log('Getting the Gigacounts token contract...');

    const Token = await ethers.getContractFactory('GigacountsToken');
    const token = await Token.deploy();
    await token.deployed();

    console.log('Getting the Gigacounts token info...');
    const tokenAddress = await token.address;
    const tokenName = await token.name();
    const tokenSymbol = await token.symbol();
    const tokenDecimals = await token.decimals();
    console.log(`Contract Address: ${tokenAddress}`);
    console.log(`Token Name: ${tokenName}`);
    console.log(`Token Symbol: ${tokenSymbol}`);
    console.log(`Token Decimals: ${tokenDecimals}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });