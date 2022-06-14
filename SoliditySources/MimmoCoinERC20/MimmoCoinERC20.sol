// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract MimmoCoinERC20 is IERC20 {

    string public constant name = "MimmoCoin";
    string public constant symbol = "MMC"; 
    uint256 public immutable override totalSupply; 
    uint8 public constant decimals = 0;  

    mapping(address => uint) private balances; 
    mapping(address => mapping(address => uint)) private allowances;

    modifier amountInBalance(address account, uint amount) {
        require(balances[account] >= amount, "Non hai abbastanza MimmoCoin");
        _; 
    }

    modifier amountInSenderBalance(uint amount){
        require(balances[msg.sender] >= amount, "Non hai abbastanza MimmoCoin");
        _; 
    }

    constructor() {
        totalSupply = 1000; 
        balances[msg.sender] = 1000;  
    }

    function balanceOf(address account) external view override returns(uint) {
        return balances[account]; 
    }

    function transfer(address to, uint256 amount) 
        external override amountInSenderBalance(amount) returns (bool) {
        balances[msg.sender] -= amount; 
        balances[to] += amount; 
        return true; 
    }

    function allowance(address owner, address spender) external view override returns(uint256) {
        return allowances[owner][spender];        
    }

    function approve(address spender, uint256 amount) 
        external override amountInSenderBalance(amount) returns(bool) {
        allowances[msg.sender][spender] = amount; 
        return true; 
    }

    function transferFrom(address from, address to, uint256 amount) 
        external override amountInBalance(from, amount) returns(bool) {
        require(allowances[from][msg.sender] >= amount, "Non sei autorizzato a spendere questo ammontare."); 
        balances[from] -= amount; 
        allowances[from][msg.sender] -= amount; 
        balances[to] += amount; 
        return true;  
    }
}