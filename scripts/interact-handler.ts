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
    const Handler = await ethers.getContractFactory('GigacountsContractHandlerV6');
    const handler = await Handler.deploy()

    console.log('Getting Signers...');
    const signers = await ethers.getSigners();
    const owner = signers[0]
    
    console.log('Adding supported token...');
    await handler.connect(owner).addSupportedToken(token.address, tokenSymbol, tokenDecimals);

    console.log('Adding owner...')
    await handler.connect(owner).addOwner('0x4Be90B1A5476dadc3642bE8F5de779734A4A3149');
    await handler.connect(owner).addOwner('0x7373504D50aDA578FD4bD868Aea63B0eFfe1aF32');
    
    console.log('Increasing allowance for handler...')
    await token.connect(owner).increaseAllowance (handler.address, '90000000000000000000000000')

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });