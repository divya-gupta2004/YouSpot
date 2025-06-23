// Add this at the top or inside your purchaseHandler.js file
const xrpl = require("xrpl");

// Test if xrpToDrops() is working
console.log(xrpl.xrpToDrops(10)); // Should print "10000000"
// Switch from import to require
const { distributeRoyalties } = require("./xrplRoyalty.js");

// Simulate content purchase
const handlePurchase = async (userAddress, creatorAddress, price) => {
  console.log("✅ Content purchased successfully!");

  // Define royalty percentage (e.g., 10%)
  const royaltyPercentage = 10;
  const royaltyAmountXRP = (price * royaltyPercentage) / 100;

  // Send royalty to the creator using XRPL
  await distributeRoyalties(creatorAddress, royaltyAmountXRP);
};

// Call the function to test
const userAddress = "rExampleUserWallet123";
const creatorAddress = "rExampleCreatorWallet456";
const price = 100; // Example content price in XRP

handlePurchase(userAddress, creatorAddress, price);
