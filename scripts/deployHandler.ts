import "@nomiclabs/hardhat-ethers";
import { ethers, network } from "hardhat"; 

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const ContractHandler = await ethers.getContractFactory("GigacountsContractHandler");
  const contractHandler = await ContractHandler.deploy();
  await contractHandler.deployed();
  console.log("Gigacounts Contract Handler address:", contractHandler.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });