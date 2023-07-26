const { expect } = require('chai');
const { ethers } = require("hardhat");

describe('GigacountsToken Unit Tests', function () {
  before(async function () {
    this.GigacountsToken = await ethers.getContractFactory('GigacountsToken');
  });

  beforeEach(async function () {
    this.gigacountsToken = await this.GigacountsToken.deploy();
    await this.gigacountsToken.deployed();

    this.decimals = await this.gigacountsToken.decimals();

    const signers = await ethers.getSigners();

    this.ownerAddress = signers[0].address;
    this.recipientAddress = signers[1].address;

    this.signerContract = this.gigacountsToken.connect(signers[1]);
  });

  it('Creates a token with a name', async function () {
    expect(await this.gigacountsToken.name()).to.exist;
  });

  it('Creates a token with a symbol', async function () {
    expect(await this.gigacountsToken.symbol()).to.exist;
  });

  it('Has a valid decimal', async function () {
    expect((await this.gigacountsToken.decimals()).toString()).to.equal('18');
  })

  it('Has a valid total supply', async function () {
    const expectedSupply = ethers.utils.parseUnits('100000000', this.decimals);
    expect((await this.gigacountsToken.totalSupply()).toString()).to.equal(expectedSupply);
  });

  it('Is able to query account balances', async function () {
    const ownerBalance = await this.gigacountsToken.balanceOf(this.ownerAddress);
    expect(await this.gigacountsToken.balanceOf(this.ownerAddress)).to.equal(ownerBalance);
  });

  it('Transfers the right amount of tokens to/from an account', async function () {
    const transferAmount = 1000;
    await expect(this.gigacountsToken.transfer(this.recipientAddress, transferAmount)).to.changeTokenBalances(
        this.gigacountsToken,
        [this.ownerAddress, this.recipientAddress],
        [-transferAmount, transferAmount]
      );
  });

  it('Emits a transfer event with the right arguments', async function () {
    const transferAmount = 100000;
    await expect(this.gigacountsToken.transfer(this.recipientAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals)))
        .to.emit(this.gigacountsToken, "Transfer")
        .withArgs(this.ownerAddress, this.recipientAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals))
  });

  it('Allows for allowance approvals and queries', async function () {
    const approveAmount = 10000;
    await this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(approveAmount.toString(), this.decimals));
    expect((await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress))).to.equal(ethers.utils.parseUnits(approveAmount.toString(), this.decimals));
  });

  it('Emits an approval event with the right arguments', async function () {
    const approveAmount = 10000;
    await expect(this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(approveAmount.toString(), this.decimals)))
        .to.emit(this.gigacountsToken, "Approval")
        .withArgs(this.recipientAddress, this.ownerAddress, ethers.utils.parseUnits(approveAmount.toString(), this.decimals))
  }); 

  it('Allows an approved spender to transfer from owner', async function () {
    const transferAmount = 10000;
    await this.gigacountsToken.transfer(this.recipientAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals))
    await this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals))
    await expect(this.gigacountsToken.transferFrom(this.recipientAddress, this.ownerAddress, transferAmount)).to.changeTokenBalances(
        this.gigacountsToken,
        [this.ownerAddress, this.recipientAddress],
        [transferAmount, -transferAmount]
      );
  });

  it('Emits a transfer event with the right arguments when conducting an approved transfer', async function () {
    const transferAmount = 10000;
    await this.gigacountsToken.transfer(this.recipientAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals))
    await this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals))
    await expect(this.gigacountsToken.transferFrom(this.recipientAddress, this.ownerAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals)))
        .to.emit(this.gigacountsToken, "Transfer")
        .withArgs(this.recipientAddress, this.ownerAddress, ethers.utils.parseUnits(transferAmount.toString(), this.decimals))
  });

  it('Allows allowance to be increased and queried', async function () {
    const initialAmount = 100;
    const incrementAmount = 10000;
    await this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(initialAmount.toString(), this.decimals))
    const previousAllowance = await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress);
    await this.signerContract.increaseAllowance(this.ownerAddress, ethers.utils.parseUnits(incrementAmount.toString(), this.decimals));
    const expectedAllowance = ethers.BigNumber.from(previousAllowance).add(ethers.BigNumber.from(ethers.utils.parseUnits(incrementAmount.toString(), this.decimals)))
    expect((await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress))).to.equal(expectedAllowance);
  });

  it('Emits approval event when alllowance is increased', async function () {
    const incrementAmount = 10000;
    await expect(this.signerContract.increaseAllowance(this.ownerAddress, ethers.utils.parseUnits(incrementAmount.toString(), this.decimals)))
        .to.emit(this.gigacountsToken, "Approval")
        .withArgs(this.recipientAddress, this.ownerAddress, ethers.utils.parseUnits(incrementAmount.toString(), this.decimals))
  });

  it('Allows allowance to be decreased and queried', async function () {
    const initialAmount = 100;
    const decrementAmount = 10;
    await this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(initialAmount.toString(), this.decimals))
    const previousAllowance = await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress);
    await this.signerContract.decreaseAllowance(this.ownerAddress, ethers.utils.parseUnits(decrementAmount.toString(), this.decimals));
    const expectedAllowance = ethers.BigNumber.from(previousAllowance).sub(ethers.BigNumber.from(ethers.utils.parseUnits(decrementAmount.toString(), this.decimals)))
    expect((await this.gigacountsToken.allowance(this.recipientAddress, this.ownerAddress))).to.equal(expectedAllowance);
  });

  it('Emits approval event when alllowance is decreased', async function () {
    const initialAmount = 100;
    const decrementAmount = 10;
    await this.signerContract.approve(this.ownerAddress, ethers.utils.parseUnits(initialAmount.toString(), this.decimals))
    const expectedAllowance = ethers.BigNumber.from(ethers.utils.parseUnits(initialAmount.toString(), this.decimals)).sub(ethers.BigNumber.from(ethers.utils.parseUnits(decrementAmount.toString(), this.decimals)))
    await expect(this.signerContract.decreaseAllowance(this.ownerAddress, ethers.utils.parseUnits(decrementAmount.toString(), this.decimals)))
        .to.emit(this.gigacountsToken, "Approval")
        .withArgs(this.recipientAddress, this.ownerAddress, expectedAllowance)
  });

});