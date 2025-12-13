// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/NoWasteToken.sol";
import "../src/ReputationSystem.sol";
import "../src/DonationManager.sol";
import "../src/ImpactNFT.sol";
import "../src/CarbonCreditRegistry.sol";
import "../src/DAOGovernance.sol";

/**
 * @title DeployNoWaste
 * @dev Deployment script for NoWaste Protocol on VeryChain (Chain ID: 4613)
 * Deploys all 6 core contracts in correct dependency order
 */
contract DeployNoWaste is Script {
    
    // Deployment addresses (will be set after deployment)
    NoWasteToken public token;
    ReputationSystem public reputation;
    DonationManager public donations;
    ImpactNFT public nft;
    CarbonCreditRegistry public carbon;
    DAOGovernance public dao;
    
    // Configuration parameters
    uint256 public constant INITIAL_TOKEN_SUPPLY = 1_000_000_000 * 10**18; // 1B tokens
    uint256 public constant PROPOSAL_THRESHOLD = 100_000 * 10**18; // 100k tokens to create proposal
    uint256 public constant VOTING_PERIOD = 3 days;
    uint256 public constant EXECUTION_DELAY = 1 days;
    
    function run() external {
        // Load deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("==============================================");
        console.log("Deploying NoWaste Protocol to VeryChain");
        console.log("==============================================");
        console.log("Deployer Address:", deployer);
        console.log("Chain ID: 4613 (VeryChain Mainnet)");
        console.log("==============================================\n");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // ============ Step 1: Deploy NoWasteToken ============
        console.log("Step 1: Deploying NoWasteToken...");
        token = new NoWasteToken(deployer);
        console.log("NoWasteToken deployed at:", address(token));
        console.log("Total Supply:", token.totalSupply() / 10**18, "NOWASTE\n");
        
        // ============ Step 2: Deploy ReputationSystem ============
        console.log("Step 2: Deploying ReputationSystem...");
        reputation = new ReputationSystem();
        console.log("ReputationSystem deployed at:", address(reputation));
        console.log("Max Score:", reputation.MAX_SCORE(), "\n");
        
        // ============ Step 3: Deploy DonationManager ============
        console.log("Step 3: Deploying DonationManager...");
        donations = new DonationManager(
            address(token),
            address(reputation)
        );
        console.log("DonationManager deployed at:", address(donations));
        console.log("Restaurant Stake:", donations.RESTAURANT_STAKE() / 10**18, "NOWASTE");
        console.log("NGO Stake:", donations.NGO_STAKE() / 10**18, "NOWASTE");
        console.log("Courier Stake:", donations.COURIER_STAKE() / 10**18, "NOWASTE\n");
        
        // ============ Step 4: Deploy ImpactNFT ============
        console.log("Step 4: Deploying ImpactNFT...");
        nft = new ImpactNFT(
            address(token)
        );
        console.log("ImpactNFT deployed at:", address(nft));
        console.log("NFT Name:", nft.name());
        console.log("NFT Symbol:", nft.symbol());
        console.log("Burn Amount:", nft.BURN_AMOUNT() / 10**18, "NOWASTE\n");
        
        // ============ Step 5: Deploy CarbonCreditRegistry ============
        console.log("Step 5: Deploying CarbonCreditRegistry...");
        carbon = new CarbonCreditRegistry(
            address(nft),
            address(token),
            deployer
        );
        console.log("CarbonCreditRegistry deployed at:", address(carbon));
        console.log("Treasury Address:", deployer, "\n");
        
        // ============ Step 6: Deploy DAOGovernance ============
        console.log("Step 6: Deploying DAOGovernance...");
        dao = new DAOGovernance(
            address(token),
            deployer
        );
        console.log("DAOGovernance deployed at:", address(dao));
        console.log("Treasury Address:", deployer, "\n");
        
        // ============ Step 7: Set Contract Permissions ============
        console.log("Step 7: Setting contract permissions...");
        
        // Set DonationManager address in ReputationSystem
        reputation.setDonationManager(address(donations));
        console.log("DonationManager set in ReputationSystem");
        
        // Set token address in ReputationSystem
        reputation.setTokenAddress(address(token));
        console.log("Token address set in ReputationSystem");
        
        // Allow DonationManager to mint NFTs
        nft.setDonationManager(address(donations));
        console.log("DonationManager set in ImpactNFT");
        
        console.log("Permissions configured\n");
        
        vm.stopBroadcast();
        
        // ============ Step 8: Deployment Summary ============
        console.log("==============================================");
        console.log("DEPLOYMENT COMPLETE!");
        console.log("==============================================");
        console.log("NoWasteToken:", address(token));
        console.log("ReputationSystem:", address(reputation));
        console.log("DonationManager:", address(donations));
        console.log("ImpactNFT:", address(nft));
        console.log("CarbonCreditRegistry:", address(carbon));
        console.log("DAOGovernance:", address(dao));
        console.log("==============================================\n");
        
        // ============ Save addresses to file ============
        string memory deploymentInfo = string(abi.encodePacked(
            "# NoWaste Protocol - VeryChain Deployment\n\n",
            "**Deployed on:** VeryChain Mainnet (Chain ID: 4613)\n",
            "**RPC:** https://rpc.verylabs.io\n",
            "**Explorer:** https://veryscan.io\n\n",
            "## Contract Addresses\n\n",
            "```json\n",
            "{\n",
            '  "NoWasteToken": "', vm.toString(address(token)), '",\n',
            '  "ReputationSystem": "', vm.toString(address(reputation)), '",\n',
            '  "DonationManager": "', vm.toString(address(donations)), '",\n',
            '  "ImpactNFT": "', vm.toString(address(nft)), '",\n',
            '  "CarbonCreditRegistry": "', vm.toString(address(carbon)), '",\n',
            '  "DAOGovernance": "', vm.toString(address(dao)), '"\n',
            "}\n",
            "```\n\n",
            "## Next Steps\n\n",
            "1. Verify contracts on VeryChain explorer\n",
            "2. Update frontend/src/utils/constants.js with these addresses\n",
            "3. Test all contract interactions\n",
            "4. Initialize DAO with initial proposals\n"
        ));
        
        vm.writeFile("deployment-addresses.md", deploymentInfo);
        console.log("Deployment addresses saved to: deployment-addresses.md\n");
        
        console.log("IMPORTANT: Update frontend constants with these addresses!");
        console.log("File: frontend/src/utils/constants.js\n");
    }
    
    // Helper function to verify deployment
    function verifyDeployment() internal view {
        require(address(token) != address(0), "Token not deployed");
        require(address(reputation) != address(0), "Reputation not deployed");
        require(address(donations) != address(0), "DonationManager not deployed");
        require(address(nft) != address(0), "ImpactNFT not deployed");
        require(address(carbon) != address(0), "CarbonCreditRegistry not deployed");
        require(address(dao) != address(0), "DAOGovernance not deployed");
        
        console.log("All contracts verified!");
    }
}
