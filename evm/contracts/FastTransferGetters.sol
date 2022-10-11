// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "./libraries/external/BytesLib.sol";

import "./interfaces/ITokenBridge.sol";

import "./FastTransferState.sol";

contract FastTransferGetters is FastTransferState {
    function owner() public view returns (address) {
        return _state.owner;
    }

    function isInitialized(address impl) public view returns (bool) {
        return _state.initializedImplementations[impl];
    }

    function chainId() public view returns (uint16) {
        return _state.chainId;
    }

    function wormhole() internal view returns (IWormhole) {
        return _state.wormhole;
    }

    function portal() public view returns (ITokenBridge) {
        return _state.portal;
    }

    function finality(bool isFast) public view returns (uint8) {
        return isFast ? _state.fastFinality : _state.finality;
    }
}
