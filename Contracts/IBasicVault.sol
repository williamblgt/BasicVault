// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IBasicVault {
    function deposit(address _user, uint _amount) external payable;
    function withdraw(address _user, uint _amount) external;
    function withdrawAll(address _user) external;
    function balanceOf(address _user) external returns (uint);

    event Deposit(address _user, uint _amount);
    event Withdraw(address _user, uint _amount);
    event WithdrawAll(address _user);
}