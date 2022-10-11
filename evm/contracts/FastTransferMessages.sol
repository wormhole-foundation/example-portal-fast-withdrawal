// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "./libraries/external/BytesLib.sol";

import "./FastTransferGetters.sol";

contract FastTransferMessages is FastTransferGetters {
    function encodeFastTransfer(ITokenBridge.Transfer memory transfer) public view returns (bytes memory) {
        return portal().encodeTransfer(transfer);
    }
}
