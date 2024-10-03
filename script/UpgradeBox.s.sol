// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {BoxV1} from "../src/BoxV1.sol";

contract UpgradeBox is Script {
    function run(address proxy) external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        vm.startBroadcast();
        BoxV2 newBox = new BoxV2();
    
        vm.stopBroadcast();

        address proxy = upgradeBox(mostRecentlyDeployed, address(newBox));
        return proxy;
    }

    function upgradeBox(address proxyAddr, address newBoxAddr) public returns (address) {
        vm.startBroadcast();
        ERC1967Proxy proxy = ERC1967Proxy(payable(proxyAddr));
        (bool success, ) = address(proxy).call(abi.encodeWithSignature("upgradeTo(address)", newBoxAddr));
        require(success, "Upgrade failed");
        vm.stopBroadcast();
        return address(proxy);
    }
}
