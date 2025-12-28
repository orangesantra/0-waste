// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/NoWasteToken.sol";

contract DeployToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying NoWasteToken...");
        console.log("Deployer:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        NoWasteToken token = new NoWasteToken(deployer);
        vm.stopBroadcast();
        
        console.log("NoWasteToken deployed at:", address(token));
    }
}
