// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TokenSwap is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
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

    constructor() Ownable(msg.sender) {}

    function createOrder(
        uint256 _amountOffered,
        uint256 _amountRequested,
        address _tokenOffered,
        address _tokenRequested
    ) public {
        require(
            _amountOffered > 0 && _amountRequested > 0,
            "Amounts must be greater than zero"
        );
        require(
            _tokenOffered != address(0) && _tokenRequested != address(0),
            "Invalid token addresses"
        );
        require(
            IERC20(_tokenOffered).balanceOf(msg.sender) >= _amountOffered,
            "Insufficient amount"
        );
        require(
            IERC20(_tokenOffered).transferFrom(
                msg.sender,
                address(this),
                _amountOffered
            ),
            "Transfer failed"
        );

        orderCount++;
        orders[orderCount] = Order({
            user: msg.sender,
            amountOffered: _amountOffered,
            amountRequested: _amountRequested,
            tokenOffered: _tokenOffered,
            tokenRequested: _tokenRequested,
            timestamp: block.timestamp,
            isActive: true
        });
    }

    function cancelOrder(uint256 _id) public {
        require(
            orders[_id].user == msg.sender,
            "Only the creator can cancel the order"
        );
        require(orders[_id].isActive, "Order is already cancelled");

        IERC20(orders[_id].tokenOffered).transfer(
            msg.sender,
            orders[_id].amountOffered
        );
        orders[_id].isActive = false;
    }

    function executeOrder(uint256 _id) public nonReentrant {
        require(orders[_id].isActive, "Order is already cancelled");
        require(
            orders[_id].user != msg.sender,
            "Only the counterparty can execute the order"
        );
        require(
            IERC20(orders[_id].tokenRequested).balanceOf(msg.sender) >=
                orders[_id].amountRequested,
            "You do not have sufficient balance"
        );

        require(
            IERC20(orders[_id].tokenRequested).transferFrom(
                msg.sender,
                orders[_id].user,
                orders[_id].amountRequested
            ),
            "Transfer failed"
        );

        require(
            IERC20(orders[_id].tokenOffered).transfer(
                msg.sender,
                orders[_id].amountOffered
            ),
            "Failed to transfer token"
        );

        orders[_id].isActive = false;
    }

    function getOrder(uint256 _id) public view returns (Order memory) {
        return orders[_id];
    }

    function getOrderCount() public view returns (uint256) {
        return orderCount;
    }

    function getTokenOffered(uint256 _id) public view returns (address) {
        return orders[_id].tokenOffered;
    }

    function getTokenRequested(uint256 _id) public view returns (address) {
        return orders[_id].tokenRequested;
    }
}
