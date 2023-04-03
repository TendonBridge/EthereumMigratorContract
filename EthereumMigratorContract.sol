// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract EthereumLockingContract {
    IERC20 public erc20Token;
    IERC20 public feeToken;
    address public owner;
    uint256 public feeRate = 10000; // 0.01% fee rate (1 / 10000)

    event TokenLocked(address indexed user, uint256 amount, bytes32 indexed operationId);
    event TokenUnlocked(address indexed user, uint256 amount, bytes32 indexed operationId);

     constructor(IERC20 _erc20Token) {
        erc20Token = _erc20Token;
        feeToken = IERC20(0x98682e633F1283919315a600Ac1570901D5A59EC);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }

    function lockTokens(uint256 amount, bytes32 operationId) external {
        uint256 fee = amount * feeRate / 1000000;
        uint256 amountAfterFee = amount - fee;
        require(erc20Token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        require(feeToken.transferFrom(msg.sender, owner, fee), "Fee transfer failed");
        emit TokenLocked(msg.sender, amountAfterFee, operationId);
    }

    function unlockTokens(address user, uint256 amount, bytes32 operationId) external onlyOwner {
        erc20Token.transfer(user, amount);
        emit TokenUnlocked(user, amount, operationId);
    }
}
