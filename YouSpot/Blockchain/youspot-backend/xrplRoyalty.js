console.log(`XRPL_SEED: ${XRPL_SEED}`);
console.log(`XRPL_WALLET: ${XRPL_WALLET}`);
// Switch from import to require
const xrpl = require("xrpl");
const dotenv = require("dotenv");

// Load environment variables
dotenv.config();

// Load wallet details from .env
const XRPL_SEED = process.env.XRPL_SEED;
const XRPL_WALLET = process.env.XRPL_WALLET;

// Connect to XRPL Testnet
const XRPL_TESTNET = "wss://s.altnet.rippletest.net:51233";

// Function to Distribute Royalties
const distributeRoyalties = async (creatorAddress, amountXRP) => {
  try {
    const client = new xrpl.Client(XRPL_TESTNET);
    await client.connect();

    // Define payment transaction
    const paymentTxn = {
      TransactionType: "Payment",
      Account: XRPL_WALLET,
      Destination: creatorAddress,
      Amount: xrpl.xrpToDrops(amountXRP),
    };

    // Sign and submit the transaction
    const wallet = xrpl.Wallet.fromSeed(XRPL_SEED);
    const signed = wallet.sign(paymentTxn);
    const txResult = await client.submitAndWait(signed.tx_blob);

    console.log(`✅ Royalty sent successfully! Transaction: ${txResult.result.hash}`);
    await client.disconnect();
  } catch (error) {
    console.error(`❌ Error in sending royalty: ${error.message}`);
  }
};

// Export as CommonJS module
module.exports = { distributeRoyalties };
