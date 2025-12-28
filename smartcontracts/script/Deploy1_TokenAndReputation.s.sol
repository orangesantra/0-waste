// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/NoWasteToken.sol";
import "../src/ReputationSystem.sol";

contract Deploy1_TokenAndReputation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== BATCH 1: Token & Reputation ===");
        console.log("Deployer:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        
        NoWasteToken token = new NoWasteToken(deployer);
        console.log("NoWasteToken:", address(token));
        
        ReputationSystem reputation = new ReputationSystem();
        console.log("ReputationSystem:", address(reputation));
        
        vm.stopBroadcast();
        console.log("\nBATCH 1 COMPLETE!");
    }
}
