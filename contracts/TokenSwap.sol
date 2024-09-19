// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TokenSwap is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public token;

    struct Order {
        address user;
        address tokenOffered;
        uint256 amountOffered;
        address tokenRequested;
        uint256 amountRequested;
        uint256 timestamp;
        bool isActive;
    }

    mapping(uint256 => Order) public orders;
    uint256 public orderCount;

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function createOrder(
        uint256 amountOffered,
        uint256 amountRequested,
        address tokenOffered,
        address tokenRequested
    ) public {
        require(
            amountOffered > 0 && amountRequested > 0,
            "Amounts must be greater than zero"
        );
        require(
            tokenOffered != address(0) && tokenRequested != address(0),
            "Invalid token addresses"
        );
        require(
            IERC20(tokenOffered).balanceOf(msg.sender) >= amountOffered,
            "Insufficient amount"
        );
        require(
            IERC20(tokenOffered).transferFrom(
                msg.sender,
                address(this),
                amountOffered
            ),
            "Transfer failed"
        );

        orderCount++;
        orders[orderCount] = Order({
            user: msg.sender,
            amountOffered: amountOffered,
            amountRequested: amountRequested,
            tokenOffered: tokenOffered,
            tokenRequested: tokenRequested,
            timestamp: block.timestamp,
            isActive: true
        });
    }

    function cancelOrder(uint256 id) public {
        require(
            orders[id].user == msg.sender,
            "Only the creator can cancel the order"
        );
        require(orders[id].isActive, "Order is already cancelled");

        IERC20(orders[id].tokenOffered).transfer(
            msg.sender,
            orders[id].amountOffered
        );
        orders[id].isActive = false;
    }

    function executeOrder(uint256 id) public nonReentrant {
        require(orders[id].isActive, "Order is already cancelled");
        require(
            orders[id].user != msg.sender,
            "Only the counterparty can execute the order"
        );
        require(
            IERC20(orders[id].tokenRequested).balanceOf(msg.sender) >=
                orders[id].amountRequested,
            "You do not have sufficient balance"
        );

        require(
            IERC20(orders[id].tokenRequested).transferFrom(
                msg.sender,
                orders[id].user,
                orders[id].amountRequested
            ),
            "Transfer failed"
        );

        require(
            IERC20(orders[id].tokenOffered).transfer(
                msg.sender,
                orders[id].amountOffered
            ),
            "Failed to transfer token"
        );

        orders[id].isActive = false;
    }

    function getOrder(uint256 id) public view returns (Order memory) {
        return orders[id];
    }

    function getOrderCount() public view returns (uint256) {
        return orderCount;
    }

    function getTokenOffered(uint256 id) public view returns (address) {
        return orders[id].tokenOffered;
    }

    function getTokenRequested(uint256 id) public view returns (address) {
        return orders[id].tokenRequested;
    }
}
