// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GigacountsContractHandler {
    address public owner;
    mapping(address => bool) public owners;
    uint8 totalSupportedTokens;
    bool checkHowCandSendFunds;
    bool checkHowCanReceiveFunds;
    bool private locked;

    struct TokenData {
        string symbol;
        uint8 decimals;
        address tokenAddress;
        bool enabled;
    }

    struct TokenFundsOut {
        address to;
        uint256 amount;
    }

    struct TokenFundsIn {
        address from;
        uint256 amount;
    }

    struct TokenFunds {
        address tokenAddress;
        uint256 totalFunds;
        uint256 receivedFunds;
        uint256 payoutFunds;
        uint256 cashbackFunds;
        mapping(address => TokenFundsOut) fundsOut;
        mapping(address => TokenFundsIn) fundsIn;
        uint16 totalFundsOut;
        uint16 totalFundsIn;
        address lastPayoutAddress;
        address lastFundInAddress;
        address cashbackAddress;
    }

    struct ContractData {
        uint256 contractId;
        mapping(address => TokenFunds) contractFunds;
        mapping(address => bool) canSendFunds;
        mapping(address => bool) canReceiveFunds;
    }

    mapping(address => TokenData) public supportedTokens; 
    mapping(uint256 => ContractData) public contractData;

    constructor() {
        owner = msg.sender;
        owners[msg.sender] = true;
        checkHowCandSendFunds = false;
        checkHowCanReceiveFunds = false;
        totalSupportedTokens = 0;
	locked = false;
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Only owners can call this function");
        _;
    }

    modifier tokenSupported(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        require(supportedTokens[_tokenAddress].enabled, "Token not supported");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function addOwner(address _newOwner) external onlyOwner returns (bool) {
        require(_newOwner != address(0), "Invalid owner address");
        owners[_newOwner] = true;
        return true;
    }

    function removeOwner(address _ownerToRemove) external onlyOwner returns (bool) {
        require(_ownerToRemove != address(0), "Invalid owner address");
        require(_ownerToRemove != msg.sender, "You cannot remove yourself as an owner");
        owners[_ownerToRemove] = false;
        return true;
    }

    function addSupportedToken(address _tokenAddress, string memory _symbol, uint8 _decimals) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        supportedTokens[_tokenAddress] = TokenData(_symbol, _decimals, _tokenAddress, true);
        totalSupportedTokens += 1;
    }

    function removeSupportedToken(address _tokenAddress) external tokenSupported(_tokenAddress) onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        supportedTokens[_tokenAddress].enabled = false;
    }

    function getSupportedTokens() external view returns (address[] memory) {
        address[] memory supportedTokenAddresses = new address[](totalSupportedTokens);
        uint8 currentIndex = 0;
        for (uint8 i = 0; i < totalSupportedTokens; i++) {
            address tokenAddress = supportedTokenAddresses[i];
            if (supportedTokens[tokenAddress].enabled) {
                supportedTokenAddresses[currentIndex] = tokenAddress;
                currentIndex++;
            }
        }
        address[] memory enabledTokenAddresses = new address[](currentIndex);
        for (uint8 i = 0; i < currentIndex; i++) {
            enabledTokenAddresses[i] = supportedTokenAddresses[i];
        }
        return enabledTokenAddresses;
    }

    function allowSendFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_walletAddress != address(0), "Invalid wallet address");
        contractData[_contractId].canSendFunds[_walletAddress] = true;
        return true;
    }

    function disallowSendFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_walletAddress != address(0), "Invalid wallet address");
        contractData[_contractId].canSendFunds[_walletAddress] = false;
        return true;
    }

    function allowReceiveFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_walletAddress != address(0), "Invalid wallet address");
        contractData[_contractId].canReceiveFunds[_walletAddress] = true;
        return true;
    }

    function disallowReceiveFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_walletAddress != address(0), "Invalid wallet address");
        contractData[_contractId].canReceiveFunds[_walletAddress] = false;
        return true;
    }

    function createContract(uint256 _contractId) external returns (bool) {
        contractData[_contractId].contractId = _contractId;
        return true;
    }

    function getFunds(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (uint256) {
        require(_tokenAddress != address(0), "Invalid token address");
        return contractData[_contractId].contractFunds[_tokenAddress].totalFunds;
    }

    function getPayoutFunds(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (uint256) {
        require(_tokenAddress != address(0), "Invalid token address");
        return contractData[_contractId].contractFunds[_tokenAddress].payoutFunds;
    }

    function getReceivedFunds(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (uint256) {
        require(_tokenAddress != address(0), "Invalid token address");
        return contractData[_contractId].contractFunds[_tokenAddress].receivedFunds;
    }

    function getCashbackFunds(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (uint256) {
        require(_tokenAddress != address(0), "Invalid token address");
        return contractData[_contractId].contractFunds[_tokenAddress].cashbackFunds;
    }

    function getCashbackAddress(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (address) {
        require(_tokenAddress != address(0), "Invalid token address");
        return contractData[_contractId].contractFunds[_tokenAddress].cashbackAddress;
    }

    function getlastFundInAddress(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (address) {
        require(_tokenAddress != address(0), "Invalid token address");
        return contractData[_contractId].contractFunds[_tokenAddress].lastFundInAddress;
    }

    function getAllFunds(uint256 _contractId, address _tokenAddress) external view tokenSupported(_tokenAddress) returns (uint256, uint256, uint256, uint256) {
        require(_tokenAddress != address(0), "Invalid token address");
        return (
            contractData[_contractId].contractFunds[_tokenAddress].totalFunds,
            contractData[_contractId].contractFunds[_tokenAddress].receivedFunds,
            contractData[_contractId].contractFunds[_tokenAddress].payoutFunds,
            contractData[_contractId].contractFunds[_tokenAddress].cashbackFunds);
    }

    function createContractAndFund(uint256 _contractId, address _tokenAddress, uint256 _amount) external tokenSupported(_tokenAddress) returns (bool) {
        require(_tokenAddress != address(0), "Invalid token address");
        contractData[_contractId].contractId = _contractId;
        return fundContract(_contractId, _tokenAddress, _amount);
    }

    function sendFunds(uint256 _contractId, address _tokenAddress, uint256 _amount) external tokenSupported(_tokenAddress) returns (bool) {
        require(_tokenAddress != address(0), "Invalid token address");
        return fundContract(_contractId, _tokenAddress, _amount);
    }

    function fundContract(uint256 _contractId, address _tokenAddress, uint256 _amount) internal tokenSupported(_tokenAddress) returns (bool) {
        if (checkHowCandSendFunds) {
            require(contractData[_contractId].canSendFunds[msg.sender], "You are not allowed to send funds to this contract");
        }
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_tokenAddress != address(0), "Invalid token address");

        IERC20 erc20Token = IERC20(_tokenAddress);
        require(erc20Token.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        bool success = erc20Token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token transfer error");

        TokenFunds storage tokenFunds = contractData[_contractId].contractFunds[_tokenAddress];
    
        tokenFunds.tokenAddress = address(_tokenAddress);
        tokenFunds.totalFunds += _amount;
        tokenFunds.receivedFunds += _amount;
        tokenFunds.lastFundInAddress = msg.sender;

        TokenFundsIn memory newFundsIn = TokenFundsIn({from: msg.sender, amount: _amount});
        tokenFunds.fundsIn[msg.sender] = newFundsIn;
        tokenFunds.totalFundsIn++;
        
        return true;
    }

    function makePayment(uint256 _contractId, address _tokenAddress, uint256 _amount, address _walletAddress) external onlyOwner tokenSupported(_tokenAddress) nonReentrant returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_tokenAddress != address(0), "Invalid token address");
        require(_walletAddress != address(0), "Invalid wallet address");
        require(contractData[_contractId].contractFunds[_tokenAddress].totalFunds >= _amount, "Insufficient balance for the contractId");

        IERC20 erc20Token = IERC20(_tokenAddress);
        require(erc20Token.balanceOf(address(this)) >= _amount, "Insufficient balance in SC");

        bool success = erc20Token.transfer(_walletAddress, _amount);
        require(success, "Payment transfer error");

        TokenFunds storage tokenFunds = contractData[_contractId].contractFunds[_tokenAddress];
        tokenFunds.totalFunds -= _amount;
        tokenFunds.payoutFunds += _amount;
        tokenFunds.lastPayoutAddress = _walletAddress;

        TokenFundsOut memory newFundsOut = TokenFundsOut({to: _walletAddress, amount: _amount});
        tokenFunds.fundsOut[_walletAddress] = newFundsOut;
        tokenFunds.totalFundsOut++;

        return true;
    }

    function cashback(uint256 _contractId, address _tokenAddress) external onlyOwner tokenSupported(_tokenAddress) nonReentrant returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_tokenAddress != address(0), "Invalid token address");

        uint256 payoutFunds = contractData[_contractId].contractFunds[_tokenAddress].payoutFunds;
        uint256 cashbackFunds = contractData[_contractId].contractFunds[_tokenAddress].cashbackFunds;
        uint256 receivedFunds = contractData[_contractId].contractFunds[_tokenAddress].receivedFunds;

        uint256 cashbackToTransfer = receivedFunds-payoutFunds-cashbackFunds;
        require(cashbackToTransfer > 0, "Insufficient balance to proceed with cashback");

        address lastFundContractAddress = contractData[_contractId].contractFunds[_tokenAddress].lastFundInAddress;
        IERC20 erc20Token = IERC20(_tokenAddress);
        bool success = erc20Token.transfer(lastFundContractAddress, cashbackToTransfer);
        require(success, "Cashback transfer error");

        contractData[_contractId].contractFunds[_tokenAddress].cashbackFunds += cashbackToTransfer;
        contractData[_contractId].contractFunds[_tokenAddress].totalFunds = 0;

        TokenFundsOut memory newFundsOut = TokenFundsOut({to: lastFundContractAddress, amount: cashbackToTransfer});
        contractData[_contractId].contractFunds[_tokenAddress].fundsOut[lastFundContractAddress] = newFundsOut;
        contractData[_contractId].contractFunds[_tokenAddress].totalFundsOut++;

        return true;
    }

    function withdrawFunds(uint256 _contractId, address payable _recipient, address _tokenAddress) external onlyOwner tokenSupported(_tokenAddress) nonReentrant returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist");
        require(_tokenAddress != address(0), "Invalid token address");

        if (checkHowCanReceiveFunds) {
            require(contractData[_contractId].canReceiveFunds[_recipient], "Recipient is not allowed to receive funds from this contract");
        }

        IERC20 erc20Token = IERC20(_tokenAddress);
        uint256 balance = erc20Token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        bool success = erc20Token.transfer(_recipient, balance);
        require(success, "Token transfer failed");

        contractData[_contractId].contractFunds[_tokenAddress].totalFunds = 0;
        return true;
    }

    function withdrawAllFunds() external onlyOwner nonReentrant returns (bool) {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        return true;
    }
}
