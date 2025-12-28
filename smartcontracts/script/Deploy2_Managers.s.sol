// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/DonationManager.sol";
import "../src/ImpactNFT.sol";

contract Deploy2_Managers is Script {
    // Update these with addresses from Batch 1
    address constant TOKEN_ADDRESS = 0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9;
    address constant REPUTATION_ADDRESS = 0xfDfA8774DdCfb201a7D6265aE5033e630B3c4473;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("=== BATCH 2: Managers ===");
        
        vm.startBroadcast(deployerPrivateKey);
        
        DonationManager donations = new DonationManager(TOKEN_ADDRESS, REPUTATION_ADDRESS);
        console.log("DonationManager:", address(donations));
        
        ImpactNFT nft = new ImpactNFT(TOKEN_ADDRESS);
        console.log("ImpactNFT:", address(nft));
        
        vm.stopBroadcast();
        console.log("\nBATCH 2 COMPLETE!");
    }
}
