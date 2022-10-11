// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

import "./FastTransfer.sol";

contract FastTransferImplementation is FastTransfer, ERC1967Upgrade {
    function initialize() initializer public virtual {
        // this function needs to be exposed for an upgrade to pass
    }

    modifier initializer() {
        address impl = ERC1967Upgrade._getImplementation();

        require(
            !isInitialized(impl),
            "already initialized"
        );

        setInitialized(impl);

        _;
    }
}