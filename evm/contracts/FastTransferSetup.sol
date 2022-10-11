// SPDX-License-Identifier: Apache 2

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

import "./FastTransferSetters.sol";

contract FastTransferSetup is FastTransferSetters, ERC1967Upgrade, Context {
    function setup(
        address implementation,
        uint16 chainId,
        address wormhole,
        address portal,
        uint8 finality
    ) public {
        require(wormhole != address(0), "invalid wormhole address");
        require(portal != address(0), "invalid portal address");
        require(implementation != address(0), "invalid implementation");

        setOwner(_msgSender());

        setChainId(chainId);

        setWormhole(wormhole);

        setPortal(portal);

        setFinality(finality);

        // fast finality is always 200
        setFastFinality(200);

        _upgradeTo(implementation);

        /// @dev call initialize function of the new implementation
        (bool success, bytes memory reason) = implementation.delegatecall(abi.encodeWithSignature("initialize()"));
        require(success, string(reason));
    }
}