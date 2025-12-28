// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/NoWasteToken.sol";
import "../src/ReputationSystem.sol";
import "../src/DonationManager.sol";
import "../src/ImpactNFT.sol";
import "../src/CarbonCreditRegistry.sol";
import "../src/DAOGovernance.sol";

/**
 * @title DeployAll
 * @dev Single-batch deployment - deploys ONLY 2 contracts at a time
 * Run multiple times to deploy all contracts
 */
contract DeployAll is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        uint256 nonce = vm.getNonce(deployer);
        
        console.log("=== NoWaste Deployment ===");
        console.log("Deployer:", deployer);
        console.log("Current Nonce:", nonce);
        
        // Determine which contracts to deploy based on nonce
        if (nonce == 5) {
            // BATCH 1: Token + Reputation
            console.log("\nBATCH 1: Deploying Token & Reputation");
            vm.startBroadcast(deployerPrivateKey);
            
            NoWasteToken token = new NoWasteToken(deployer);
            console.log("NoWasteToken:", address(token));
            
            ReputationSystem reputation = new ReputationSystem();
            console.log("ReputationSystem:", address(reputation));
            
            vm.stopBroadcast();
            console.log("DONE! Run again for Batch 2");
            
        } else if (nonce == 7) {
            // BATCH 2: Donation + NFT
            // Load addresses from batch 1
            address tokenAddr = vm.computeCreateAddress(deployer, 5);
            address reputationAddr = vm.computeCreateAddress(deployer, 6);
            
            console.log("\nBATCH 2: Deploying Managers");
            vm.startBroadcast(deployerPrivateKey);
            
            DonationManager donations = new DonationManager(tokenAddr, reputationAddr);
            console.log("DonationManager:", address(donations));
            
            ImpactNFT nft = new ImpactNFT(tokenAddr);
            console.log("ImpactNFT:", address(nft));
            
            vm.stopBroadcast();
            console.log("DONE! Run again for Batch 3");
            
        } else if (nonce == 9) {
            // BATCH 3: Carbon + DAO
            address tokenAddr = vm.computeCreateAddress(deployer, 5);
            address nftAddr = vm.computeCreateAddress(deployer, 8);
            
            console.log("\nBATCH 3: Deploying Governance");
            vm.startBroadcast(deployerPrivateKey);
            
            CarbonCreditRegistry carbon = new CarbonCreditRegistry(nftAddr, tokenAddr, deployer);
            console.log("CarbonCreditRegistry:", address(carbon));
            
            DAOGovernance dao = new DAOGovernance(tokenAddr, deployer);
            console.log("DAOGovernance:", address(dao));
            
            vm.stopBroadcast();
            console.log("DONE! Run again for Permissions");
            
        } else if (nonce == 11) {
            // BATCH 4: Set Permissions
            address tokenAddr = vm.computeCreateAddress(deployer, 5);
            address reputationAddr = vm.computeCreateAddress(deployer, 6);
            address donationsAddr = vm.computeCreateAddress(deployer, 7);
            address nftAddr = vm.computeCreateAddress(deployer, 8);
            
            console.log("\nBATCH 4: Setting Permissions");
            vm.startBroadcast(deployerPrivateKey);
            
            ReputationSystem(reputationAddr).setDonationManager(donationsAddr);
            ReputationSystem(reputationAddr).setTokenAddress(tokenAddr);
            ImpactNFT(nftAddr).setDonationManager(donationsAddr);
            
            vm.stopBroadcast();
            console.log("ALL DONE!");
            
            console.log("\n=== FINAL ADDRESSES ===");
            console.log("NoWasteToken:", tokenAddr);
            console.log("ReputationSystem:", reputationAddr);
            console.log("DonationManager:", donationsAddr);
            console.log("ImpactNFT:", nftAddr);
            console.log("CarbonCreditRegistry:", vm.computeCreateAddress(deployer, 9));
            console.log("DAOGovernance:", vm.computeCreateAddress(deployer, 10));
            
        } else {
            console.log("Invalid nonce. Expected 5, 7, 9, or 11");
            console.log("Current nonce:", nonce);
        }
    }
}
