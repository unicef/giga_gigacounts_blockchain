// SPDX-License-Identifier: MIT
// UUPS (Universal Upgradeable Proxy Standard)
pragma solidity ^0.8.0;

contract GigacountsContractHandlerProxy {
    address public logicContract;
    address public owner;
    mapping(address => bool) public owners;

    constructor(address _logicContract) {
        logicContract = _logicContract;
        owner = msg.sender;
        owners[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Only owners can call this function.");
        _;
    }

    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owners[_newOwner] = true;
    }

    function removeOwner(address _ownerToRemove) external onlyOwner {
        require(_ownerToRemove != address(0), "Invalid address");
        require(_ownerToRemove != msg.sender, "You cannot remove yourself as an owner");
        owners[_ownerToRemove] = false;
    }

    fallback() external {
        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result 
            case 0 {
                revert(0, returndatasize())
            } 
            default {
                return (0, returndatasize())
            }
        }
    }

    function updateLogicContract(address _newLogicContract) external {
        require(msg.sender == owner, "only owner could update logic");
        logicContract = _newLogicContract;
    }
}
