const FastTransfer = artifacts.require("FastTransfer");
module.exports = async function (callback) {
  try {
    const ft = await FastTransfer.new();
    console.log("tx: " + ft.transactionHash);
    console.log("FastTransfer address: " + ft.address);
    callback();
  } catch (e) {
    callback(e);
  }
};
