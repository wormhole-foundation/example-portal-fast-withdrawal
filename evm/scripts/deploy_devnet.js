const FastTransfer = artifacts.require("FastTransfer");
let addresses = {};
try {
  addresses = require("../addresses.json");
} catch (e) {}
const { CONTRACTS } = require("@certusone/wormhole-sdk");
const fs = require("fs");
module.exports = async function (callback) {
  try {
    const ft = await FastTransfer.new(
      CONTRACTS.DEVNET.ethereum.core,
      CONTRACTS.DEVNET.ethereum.token_bridge
    );
    console.log("tx: " + ft.transactionHash);
    console.log("FastTransfer address: " + ft.address);
    addresses.devnet = ft.address;
    fs.writeFileSync("./addresses.json", JSON.stringify(addresses));
    callback();
  } catch (e) {
    callback(e);
  }
};
