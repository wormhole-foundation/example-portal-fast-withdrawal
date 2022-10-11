// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/ITokenBridge.sol";

import "./FastTransferState.sol";

contract FastTransferSetters is FastTransferState {
    function setOwner(address owner) internal {
        _state.owner = owner;
    }

    function setInitialized(address implementatiom) internal {
        _state.initializedImplementations[implementatiom] = true;
    }

    function setChainId(uint16 chainId) internal {
        _state.chainId = chainId;
    }

    function setWormhole(address wormholeAddress) internal {
        _state.wormhole = IWormhole(payable(wormholeAddress));
    }

    function setPortal(address portalAddress) internal {
        _state.portal = ITokenBridge(payable(portalAddress));
    }

    function setFinality(uint8 finality_) internal {
        _state.finality = finality_;
    }

    function setFastFinality(uint8 fastFinality_) internal {
        _state.fastFinality = fastFinality_;
    }
}
