// contracts/FastTransfer.sol
// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "./libraries/external/BytesLib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWormhole {
    function publishMessage(
        uint32 nonce,
        bytes memory payload,
        uint8 consistencyLevel
    ) external payable returns (uint64 sequence);
    function messageFee() external view returns (uint256);
}
interface ITokenBridge {
    function wrapAndTransferETH(
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) external payable returns (uint64 sequence);
    function chainId() external view returns (uint16);
    function WETH() external view returns (IWETH);
}
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint amount) external;
}

// reuse Portal Transfer struct for convenience
struct Transfer {
    // PayloadID uint8 = 1
    uint8 payloadID;
    // Amount being transferred (big-endian uint256)
    uint256 amount;
    // Address of the token. Left-zero-padded if shorter than 32 bytes
    bytes32 tokenAddress;
    // Chain ID of the token
    uint16 tokenChain;
    // Address of the recipient. Left-zero-padded if shorter than 32 bytes
    bytes32 to;
    // Chain ID of the recipient
    uint16 toChain;
    // Amount of tokens (big-endian uint256) that the user is willing to pay as relayer fee. Must be <= Amount.
    uint256 fee;
}

contract FastTransfer {

    IWormhole wormhole;
    ITokenBridge portal;

    constructor(address wormholeAddress, address portalAddress) {
        wormhole = IWormhole(wormholeAddress);
        portal = ITokenBridge(portalAddress);
    }

    function wrapAndTransferETH(
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) public payable returns (uint64 fastSequence, uint64 portalSequence) {
        // Portal accounts for 1 fee, but we must account for 2
        uint wormholeFee = wormhole.messageFee();
        require(wormholeFee * 2 < msg.value, "value is smaller than wormhole fees");
        uint amount = msg.value - wormholeFee * 2;
        // Portal will normalize the amount to 8 decimals, so we should do the same
        uint normalizedAmount = normalizeAmount(amount, 18);
        Transfer memory fastTransfer = Transfer({
            payloadID: 1,
            amount: normalizedAmount,
            tokenAddress: bytes32(uint256(uint160(address(portal.WETH())))),
            tokenChain: portal.chainId(),
            to: recipient,
            toChain: recipientChain,
            fee: 0
        });
        fastSequence = wormhole.publishMessage{
            value : wormholeFee
        }(
            0,
            abi.encodePacked(
                fastTransfer.payloadID,
                fastTransfer.amount,
                fastTransfer.tokenAddress,
                fastTransfer.tokenChain,
                fastTransfer.to,
                fastTransfer.toChain,
                fastTransfer.fee
            ), 
            200
        );
        // Forward the remaining value sans the first fee
        portalSequence = portal.wrapAndTransferETH{
            value: msg.value - wormholeFee
        }(
            recipientChain,
            recipient, // TODO: receiving chain pool
            arbiterFee,
            nonce
        );
    }

    function normalizeAmount(uint256 amount, uint8 decimals) internal pure returns(uint256){
        if (decimals > 8) {
            amount /= 10 ** (decimals - 8);
        }
        return amount;
    }

}
