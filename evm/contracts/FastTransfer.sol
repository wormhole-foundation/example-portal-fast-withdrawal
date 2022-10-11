// contracts/FastTransfer.sol
// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "./libraries/external/BytesLib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ITokenBridge.sol";

import "./FastTransferMessages.sol";
import "./FastTransferSetters.sol";

contract FastTransfer is FastTransferMessages, FastTransferSetters {
    function wrapAndTransferETH(
        uint16 recipientChain,
        bytes32 recipient,
        uint256 arbiterFee,
        uint32 nonce
    ) public payable returns (uint64 fastSequence, uint64 portalSequence) {
        // cache Wormhole and Portal instance
        IWormhole wormhole = wormhole();
        ITokenBridge portal = portal();

        // Portal accounts for 1 fee, but we must account for 2
        uint wormholeFee = wormhole.messageFee();
        require(wormholeFee * 2 < msg.value, "value is smaller than wormhole fees");

        // compute amound less fees
        uint amount = msg.value - wormholeFee * 2;

        // normalize amount the same way that Portal does
        uint normalizedAmount = normalizeAmount(amount, 18);

        // create fast transfer message and publish it
        ITokenBridge.Transfer memory fastTransfer = ITokenBridge.Transfer({
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
            nonce,
            encodeFastTransfer(fastTransfer),
            finality(true)
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
