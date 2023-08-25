// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GigacountsContractHandlerV1 {
    address public owner;

    struct ContractData {
        uint256 contractId;
        uint256 contractFunds;
    }

    mapping(uint256 => ContractData) public contractData;
    IERC20 public token;

    constructor() {
        owner = msg.sender;
    }

    function createContract(uint256 _contractId) external returns (bool) {
        contractData[_contractId].contractId = _contractId;
        return true;
    }

    function getFunds(uint256 _contractId) external view returns (uint256) {
        return contractData[_contractId].contractFunds;
    }

    function sendFunds(uint256 _contractId, uint256 _amount) external returns (bool) {
        contractData[_contractId].contractFunds = _amount;
        return true;
    }

    function createContractAndFund (uint256 _contractId, address _tokenAddress, uint256 _amount) external returns (bool) {
        contractData[_contractId].contractId = _contractId;
        return fundContract(_contractId, _tokenAddress, _amount);
    }

    function fundContract(uint256 _contractId, address _tokenAddress, uint256 _amount) internal returns (bool) {
        IERC20 erc20Token = IERC20(_tokenAddress);
        require(erc20Token.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        bool success = erc20Token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token transfer error");

        contractData[_contractId].contractFunds += _amount;
        return true;
    }

}
