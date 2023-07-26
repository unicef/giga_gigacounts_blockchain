import "@nomiclabs/hardhat-ethers";
import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config()

async function main() {
    console.log('Getting the gigacounts token contract...');
    const contractAddress = process.env.DEPLOYED_GIGACOUNTS_CONTRACT_ADDRESS || '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';
    console.log(contractAddress)
    const token = await ethers.getContractAt('GigacountsToken', contractAddress);
    const tokenName = await token.name();
    const tokenSymbol = await token.name();
    console.log(`Token Name: ${tokenName}\n`);
    console.log(`Token Symbol: ${tokenSymbol}\n`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });