// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/ReputationSystem.sol";

contract DeployReputation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("Deploying ReputationSystem...");
        
        vm.startBroadcast(deployerPrivateKey);
        ReputationSystem reputation = new ReputationSystem();
        vm.stopBroadcast();
        
        console.log("ReputationSystem deployed at:", address(reputation));
    }
}
