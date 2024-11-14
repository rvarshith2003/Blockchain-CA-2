// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureWallet {
    mapping(address => uint256) private balances;
    
    bool private locked;
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    error InsufficientBalance();
    error ReentrancyGuard();
    error WithdrawalFailed();
    
    modifier noReentrant() {
        if (locked) revert ReentrancyGuard();
        locked = true;
        _;
        locked = false;
    }
    
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) external noReentrant {
        // Check balance
        if (balances[msg.sender] < amount) revert InsufficientBalance();
        
        balances[msg.sender] -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert WithdrawalFailed();
        
        emit Withdrawn(msg.sender, amount);
    }
    
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}