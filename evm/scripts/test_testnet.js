const {
  CONTRACTS,
  CHAIN_ID_ETH,
  parseSequencesFromLogEth,
  transferFromEthNative,
  tryNativeToUint8Array,
  getSignedVAAWithRetry,
  getEmitterAddressEth,
} = require("@certusone/wormhole-sdk");
const {
  NodeHttpTransport,
} = require("@improbable-eng/grpc-web-node-http-transport");
const addresses = require("../addresses.json");
const { ethers } = require("ethers");

(async () => {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.ankr.com/eth_goerli"
  );
  const signer = new ethers.Wallet(process.env.MNEMONIC, provider);
  // the fast transfer contract shares the same interface with the token bridge
  const receipt = await transferFromEthNative(
    addresses.testnet,
    signer,
    ethers.utils.parseEther(".00000001"),
    4,
    tryNativeToUint8Array(await signer.getAddress(), CHAIN_ID_ETH),
    0
  );
  const [fastSeq, portalSeq] = parseSequencesFromLogEth(
    receipt,
    CONTRACTS.TESTNET.ethereum.core
  );
  console.log("fast seq", fastSeq, "portal seq", portalSeq);
  await getSignedVAAWithRetry(
    ["https://wormhole-v2-testnet-api.certus.one"],
    CHAIN_ID_ETH,
    getEmitterAddressEth(addresses.testnet),
    fastSeq,
    {
      transport: NodeHttpTransport(),
    }
  );
  console.log("fast", new Date().toISOString());
  await getSignedVAAWithRetry(
    ["https://wormhole-v2-testnet-api.certus.one"],
    CHAIN_ID_ETH,
    getEmitterAddressEth(CONTRACTS.TESTNET.ethereum.token_bridge),
    portalSeq,
    {
      transport: NodeHttpTransport(),
    }
  );
  console.log("portal", new Date().toISOString());
})();
