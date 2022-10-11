// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/ITokenBridge.sol";

contract FastTransferStorage {
    struct State {
        // address of contract owner
        address owner;

        // chainId of this contract
        uint16 chainId;

        // wormhole message finality
        uint8 finality;

        // portal finality for fast transfers
        uint8 fastFinality;

        // portal instance
        ITokenBridge portal;

        // wormhole instance
        IWormhole wormhole;

        /// mapping of initialized implementations
        mapping(address => bool) initializedImplementations;

        // storage gap
        uint256[50] ______gap;
    }
}

contract FastTransferState {
    FastTransferStorage.State _state;
}