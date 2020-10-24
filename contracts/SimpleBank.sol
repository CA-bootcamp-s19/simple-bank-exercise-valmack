/// SPDX-License-Identifier: Unlicense

pragma solidity ^0.6.12;


contract SimpleBank {

    //
    // State variables
    //
    
    /* We want to protect our users balance from other contracts. */
    mapping (address => uint) private balances;
    
    /* We want to create a getter function and allow contracts to be able to see if a user is enrolled. */
    mapping (address => bool) public enrolled;

    /* Let's make sure everyone knows who owns the bank. */
    address public owner;
    
    //
    // Events - publicize actions to external listeners
    //
    
    /* Add an argument for this event, an accountAddress. */
    event LogEnrolled(address indexed accountAddress);

    /* Add 2 arguments for this event, an accountAddress and an amount. */
    event LogDepositMade(address indexed accountAddress, uint amount);

    /* Create an event called LogWithdrawal. */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance. */
    event LogWithdrawal(address indexed accountAddress, uint withdrawAmount, uint newBalance);


    //
    // Functions
    //

    /* Use the appropriate global variable to get the sender of the transaction */
    /* Sets the owner to the creator of this contract */
    constructor() public {
        owner = msg.sender;
    }

    fallback() external {
        revert();
    }

    receive() external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the sender
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    function enroll() public returns (bool) {
        enrolled[msg.sender] = true;

        emit LogEnrolled(msg.sender);

        return enrolled[msg.sender];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint) {
        require(msg.value > 0, 'Deposit amount must be great than 0');
        require(enrolled[msg.sender] == true, 'Message sender must be enrolled before they can make deposits');

        uint startingBalance = getBalance();
        balances[msg.sender] = 0;
        balances[msg.sender] = startingBalance + msg.value;

        emit LogDepositMade(msg.sender, msg.value);

        return getBalance();
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public payable returns (uint) {
        require(withdrawAmount > 0, 'Withdraw amount must be greater than 0');
        require(address(this).balance >= withdrawAmount, 'Bank has insuffient funds');
        uint startingBalance = getBalance();
        require(startingBalance >= withdrawAmount, 'Message sender has insufficient funds');

        balances[msg.sender] = 0;
        balances[msg.sender] = startingBalance - withdrawAmount;
        msg.sender.transfer(withdrawAmount);
        uint endingBalance = getBalance();

        emit LogWithdrawal(msg.sender, withdrawAmount, endingBalance);

        return endingBalance;
    }

}
