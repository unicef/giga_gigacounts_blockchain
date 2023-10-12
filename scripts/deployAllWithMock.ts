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

  // deploy token
  const Token = await ethers.getContractFactory("GigacountsToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Gigacounts Token address:", token.address);

  // deploy handler
  const ContractHandler = await ethers.getContractFactory("GigacountsContractHandler");
  const contractHandler = await ContractHandler.deploy();
  await contractHandler.deployed();
  console.log("Gigacounts Contract Handler address:", contractHandler.address);

  console.log('Getting Signers...');
  const signers = await ethers.getSigners();
  const owner = signers[0]

  // add token to handler
  const tokenSymbol = await token.symbol();
  const tokenDecimals = await token.decimals();
  console.log('Adding supported token...');
  await contractHandler.connect(owner).addSupportedToken(token.address, tokenSymbol, tokenDecimals);

  // Increase allowance
  console.log('Increasing allowance...');
  await token.connect(owner).increaseAllowance(contractHandler.address, 1000000000000);

  // create mock contract and fund
  console.log('Creating and funding (5000) mock contract 1...');
  await contractHandler.connect(owner).createContractAndFund(1, token.address, 5000);
  printBalances('1', await contractHandler.getAllFunds(1, token.address))

  // send funds
  console.log('Sending funds (400) to contract 1...');
  await contractHandler.connect(owner).sendFunds(1, token.address, 400);
  printBalances('1', await contractHandler.getAllFunds(1, token.address))

  // Make payment
  console.log('Making Payment (600) to contract 1...');
  await contractHandler.connect(owner).makePayment(1, token.address, 600, signers[1].address);
  printBalances('1', await contractHandler.getAllFunds(1, token.address))

  // get last fund address
  console.log('Get last fund address for contract 1...');
  const lastAddress = await contractHandler.getlastFundInAddress(1, token.address);
  console.log(`last address to fund contract 1: ${lastAddress}`);

  // do cashback
  console.log('Cashback contract 1...');
  await contractHandler.connect(owner).cashback(1, token.address);
  printBalances('1', await contractHandler.getAllFunds(1, token.address))

}

const printBalances = (contractId: string, balances) => {
  console.log(`Contract ${contractId} balances => totalFunds: ${balances[0]}, ReceivedFunds: ${balances[1]}, PayoutFunds: ${balances[2]}, CashbackFunds: ${balances[3]}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });