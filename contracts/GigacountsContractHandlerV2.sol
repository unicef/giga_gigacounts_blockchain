// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GigacountsContractHandlerV2 {
    address public owner;
    mapping(address => bool) public owners;
    uint8 totalSupportedTokens;
    bool checkHowCandSendFunds;
    bool checkHowCanReceiveFunds;

    struct TokenData {
        string symbol;
        uint8 decimals;
        address tokenAddress;
        bool enabled;
    }

    struct ContractData {
        uint256 contractId;
        uint256 contractFunds;
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
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Only owners can call this function.");
        _;
    }

    modifier tokenSupported(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid address");
        require(supportedTokens[_tokenAddress].enabled, "Token not supported");
        _;
    }

    function addOwner(address _newOwner) external onlyOwner returns (bool) {
        require(_newOwner != address(0), "Invalid address");
        owners[_newOwner] = true;
        return true;
    }

    function removeOwner(address _ownerToRemove) external onlyOwner returns (bool) {
        require(_ownerToRemove != address(0), "Invalid address");
        require(_ownerToRemove != msg.sender, "You cannot remove yourself as an owner");
        owners[_ownerToRemove] = false;
        return true;
    }

    function addSupportedToken(address _tokenAddress, string memory _symbol, uint8 _decimals) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid address");
        supportedTokens[_tokenAddress] = TokenData(_symbol, _decimals, _tokenAddress, true);
        totalSupportedTokens += 1;
    }

    function removeSupportedToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid address");
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
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist.");
        require(_walletAddress != address(0), "Invalid address");
        contractData[_contractId].canSendFunds[_walletAddress] = true;
        return true;
    }

    function disallowSendFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist.");
        require(_walletAddress != address(0), "Invalid address");
        contractData[_contractId].canSendFunds[_walletAddress] = false;
        return true;
    }

    function allowReceiveFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist.");
        require(_walletAddress != address(0), "Invalid address");
        contractData[_contractId].canReceiveFunds[_walletAddress] = true;
        return true;
    }

    function disallowReceiveFunds(uint256 _contractId, address _walletAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist.");
        require(_walletAddress != address(0), "Invalid address");
        contractData[_contractId].canReceiveFunds[_walletAddress] = false;
        return true;
    }

    function createContract(uint256 _contractId) external returns (bool) {
        contractData[_contractId].contractId = _contractId;
        return true;
    }

    function getFunds(uint256 _contractId) external view returns (uint256) {
        return contractData[_contractId].contractFunds;
    }

    function sendFunds(uint256 _contractId, uint256 _amount) external returns (bool) {
        if (checkHowCandSendFunds) {
            require(contractData[_contractId].canSendFunds[msg.sender], "You are not allowed to send funds to this contract.");
        }
        contractData[_contractId].contractFunds += _amount;
        return true;
    }

    function createContractAndFund(uint256 _contractId, address _tokenAddress, uint256 _amount) external returns (bool) {
        require(_tokenAddress != address(0), "Invalid address");
        contractData[_contractId].contractId = _contractId;
        return fundContract(_contractId, _tokenAddress, _amount);
    }

    function fundContract(uint256 _contractId, address _tokenAddress, uint256 _amount) internal tokenSupported(_tokenAddress) returns (bool) {
        if (checkHowCandSendFunds) {
            require(contractData[_contractId].canSendFunds[msg.sender], "You are not allowed to send funds to this contract.");
        }
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist.");
        require(_tokenAddress != address(0), "Token not supported.");

        IERC20 erc20Token = IERC20(_tokenAddress);
        require(erc20Token.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        bool success = erc20Token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token transfer error");

        contractData[_contractId].contractFunds += _amount;
        return true;
    }

    function createPayment(uint256 _contractId) external onlyOwner returns (bool) {
        // TODO
    }

    function cashback(uint256 _contractId) external onlyOwner returns (bool) {
        // TODO
    }

    function withdrawFunds(uint256 _contractId, address payable _recipient, address _tokenAddress) external onlyOwner returns (bool) {
        require(contractData[_contractId].contractId != 0, "Contract with this contractId does not exist.");
        if (checkHowCanReceiveFunds) {
            require(contractData[_contractId].canReceiveFunds[_recipient], "Recipient is not allowed to receive funds from this contract.");
        }
        require(_tokenAddress != address(0), "Token not supported.");

        IERC20 erc20Token = IERC20(_tokenAddress);
        uint256 balance = erc20Token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw.");

        bool success = erc20Token.transfer(_recipient, balance);
        require(success, "Token transfer failed.");

        contractData[_contractId].contractFunds = 0;

        return true;
    }

    function withdrawAllFunds() external onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        return true;
    }
}
