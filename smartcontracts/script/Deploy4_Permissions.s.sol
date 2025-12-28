// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/ReputationSystem.sol";
import "../src/ImpactNFT.sol";

contract Deploy4_Permissions is Script {
    // Update these with deployed addresses
    address constant TOKEN_ADDRESS = 0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9;
    address constant REPUTATION_ADDRESS = 0xfDfA8774DdCfb201a7D6265aE5033e630B3c4473;
    address constant DONATION_MANAGER_ADDRESS = 0x7eF9886012D57c4b2444E17055B6341ceB0894Db;
    address constant NFT_ADDRESS = 0x42B0559ECE9AdE6c5eB1dD39D91b9E2705F1f7f9;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("=== BATCH 4: Permissions ===");
        
        vm.startBroadcast(deployerPrivateKey);
        
        ReputationSystem reputation = ReputationSystem(REPUTATION_ADDRESS);
        ImpactNFT nft = ImpactNFT(NFT_ADDRESS);
        
        reputation.setDonationManager(DONATION_MANAGER_ADDRESS);
        console.log("DonationManager set in ReputationSystem");
        
        reputation.setTokenAddress(TOKEN_ADDRESS);
        console.log("Token set in ReputationSystem");
        
        nft.setDonationManager(DONATION_MANAGER_ADDRESS);
        console.log("DonationManager set in ImpactNFT");
        
        vm.stopBroadcast();
        console.log("\nBATCH 4 COMPLETE!");
    }
}
