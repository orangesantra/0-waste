// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/CarbonCreditRegistry.sol";
import "../src/DAOGovernance.sol";

contract Deploy3_Governance is Script {
    // Update these with addresses from previous batches
    address constant TOKEN_ADDRESS = 0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9;
    address constant NFT_ADDRESS = 0x42B0559ECE9AdE6c5eB1dD39D91b9E2705F1f7f9;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== BATCH 3: Governance ===");
        
        vm.startBroadcast(deployerPrivateKey);
        
        CarbonCreditRegistry carbon = new CarbonCreditRegistry(NFT_ADDRESS, TOKEN_ADDRESS, deployer);
        console.log("CarbonCreditRegistry:", address(carbon));
        
        DAOGovernance dao = new DAOGovernance(TOKEN_ADDRESS, deployer);
        console.log("DAOGovernance:", address(dao));
        
        vm.stopBroadcast();
        console.log("\nBATCH 3 COMPLETE!");
    }
}
