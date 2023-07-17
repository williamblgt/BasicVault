// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./IBasicVault.sol";

/*Error section*/
error Vault_AmountZero();
error Vault_InsufficientBalance();
error Vault_NoUsers();
error Vault_ErrorOnTransfer();
error Vault_NotOwner();

contract BasicVault is IBasicVault {
    address private OWNER;
    mapping(address _user => uint _balance) private balances;
    uint public usersInVault;
    uint private ETH = 1 ether;

    constructor(){
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != OWNER) 
            revert Vault_NotOwner();
        _;
    }

    function deposit(address _user, uint _amount) external payable {
        uint amountEth = _amount * ETH;
        if(amountEth == 0) {
            //Error message, amount must be greater than 0
            revert Vault_AmountZero();
        }

        if(balances[_user] == 0) {
            usersInVault++;
        } 

        balances[_user] += amountEth;
        emit Deposit(_user, amountEth);
    }

    function withdraw(address _user, uint _amount) external onlyOwner {
        uint amountEth = _amount * ETH;

        if((balances[_user] - amountEth) >= 0) {
            balances[_user] -= amountEth;

            (bool success, ) = payable(_user).call{value: amountEth}("");
            if (!success) revert Vault_ErrorOnTransfer();

            emit Withdraw(_user, amountEth);
        } 
        else {
            //Error message, insufficient balance
            revert Vault_InsufficientBalance();
        }
    }

    function withdrawAll(address _user) external {
        _removeUser(_user);
    }

    function balanceOf(address _user) external view returns (uint) {
        return balances[_user];
    }

    function _removeUser(address _user) internal {
        if(usersInVault == 0) {
            revert Vault_NoUsers();
        }

        if(balances[_user] == 0) {
            revert Vault_InsufficientBalance();
        }

        uint userBalance = balances[_user];

        balances[_user] = 0;
        usersInVault--;

        (bool success, ) = payable(_user).call{value: userBalance}("");
        if (!success) revert Vault_ErrorOnTransfer();

        emit Withdraw(_user, userBalance);
    }
}