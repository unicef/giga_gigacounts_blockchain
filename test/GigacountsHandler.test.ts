const { expect } = require('chai');
const { ethers } = require("hardhat");

describe('GigacountsHandler Unit Tests', function () {
  before(async function () {
    this.GigacountsToken = await ethers.getContractFactory('GigacountsToken');
    this.GigacountsContractHandler = await ethers.getContractFactory('GigacountsContractHandlerV4');
    this.GigacountsContractHandlerProxy = await ethers.getContractFactory('GigacountsContractHandlerProxy');
  });

  beforeEach(async function () {
    this.gigacountsToken = await this.GigacountsToken.deploy();
    await this.gigacountsToken.deployed();

    this.GigacountsContractHandler = await this.GigacountsContractHandler.deploy();
    await this.GigacountsContractHandler.deployed();

    this.gigacountsContractHandlerProxy = await this.GigacountsContractHandlerProxy.deploy(this.GigacountsContractHandler.address);
    await this.gigacountsContractHandlerProxy.deployed();

    this.decimals = await this.gigacountsToken.decimals();
    this.symbol = await this.gigacountsToken.symbol();
    const signers = await ethers.getSigners();
    this.ownerAddress = signers[0].address;
    this.recipientAddress = signers[1].address;

    this.signerContractToken = this.gigacountsToken.connect(signers[1]);
    this.signerContractHandler = this.GigacountsContractHandler.connect(signers[1]);

  });

  it('fund contract with handler', async function () {

    const initialAmount = 100;
    const incrementAmount = 10000;
    await this.signerContractToken.approve(this.ownerAddress, ethers.utils.parseUnits(initialAmount.toString(), this.decimals))
    const previousAllowance = await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress);
    await this.signerContractToken.increaseAllowance(this.ownerAddress, ethers.utils.parseUnits(incrementAmount.toString(), this.decimals));
    const expectedAllowance = ethers.BigNumber.from(previousAllowance).add(ethers.BigNumber.from(ethers.utils.parseUnits(incrementAmount.toString(), this.decimals)))
    expect((await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress))).to.equal(expectedAllowance);

    const signers = await ethers.getSigners();
    const signerContractToken = this.gigacountsToken.connect(signers[0]);
    const signerContractHandler = this.GigacountsContractHandler.connect(signers[0]);
    await signerContractToken.increaseAllowance(this.GigacountsContractHandler.address, ethers.utils.parseUnits(incrementAmount.toString(), this.decimals));
    await signerContractHandler.addSupportedToken(this.gigacountsToken.address, this.symbol, this.decimals);
    await signerContractHandler.createContractAndFund(1, this.gigacountsToken.address, ethers.BigNumber.from(ethers.utils.parseUnits(incrementAmount.toString(), this.decimals)))

  });

});