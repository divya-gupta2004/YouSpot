// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YouSpotAccessControl is ERC1155, Ownable {
    IERC20 public youSpotToken;

    struct ContentAccess {
        uint256 pricePPV;
        uint256 subscriptionPrice;
        mapping(address => uint256) subscriptions;
    }

    mapping(uint256 => ContentAccess) public contentAccess;

    event PPVAccessGranted(address indexed user, uint256 contentId);
    event SubscriptionPurchased(address indexed user, uint256 contentId, uint256 expiry);

    constructor(address _youSpotToken) ERC1155("https://metadata.youSpot/{id}.json") {
        youSpotToken = IERC20(_youSpotToken);
    }

    function setContentPricing(
        uint256 contentId,
        uint256 pricePPV,
        uint256 subscriptionPrice
    ) public onlyOwner {
        contentAccess[contentId].pricePPV = pricePPV;
        contentAccess[contentId].subscriptionPrice = subscriptionPrice;
    }

    function purchasePPV(uint256 contentId) public {
        uint256 price = contentAccess[contentId].pricePPV;
        require(price > 0, "PPV not available");

        require(youSpotToken.transferFrom(msg.sender, owner(), price), "Payment failed");
        _mint(msg.sender, contentId, 1, ""); // Mint access NFT

        emit PPVAccessGranted(msg.sender, contentId);
    }

    function purchaseSubscription(uint256 contentId) public {
        uint256 price = contentAccess[contentId].subscriptionPrice;
        require(price > 0, "Subscription not available");

        require(youSpotToken.transferFrom(msg.sender, owner(), price), "Payment failed");

        contentAccess[contentId].subscriptions[msg.sender] = block.timestamp + 30 days;

        emit SubscriptionPurchased(msg.sender, contentId, block.timestamp + 30 days);
    }

    function hasAccess(address user, uint256 contentId) public view returns (bool) {
        return balanceOf(user, contentId) > 0 || contentAccess[contentId].subscriptions[user] > block.timestamp;
    }
}
