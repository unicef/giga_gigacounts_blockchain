// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GigacountsContractHandlerV0 {
    address public owner;

    struct ContractData {
        uint256 contractId;
        uint256 contractFunds;
    }

    mapping(uint256 => ContractData) public contractData;

    constructor() {
        owner = msg.sender;
    }

    function createContract(uint256 _contractId) external {
        contractData[_contractId].contractId = _contractId;
    }

    function sendFunds(uint256 _contractId, uint256 _amount) external {
        contractData[_contractId].contractFunds = _amount;
    }

    function getFunds(uint256 _contractId) external view returns (uint256) {
        return contractData[_contractId].contractFunds;
    }

}
