// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/ReputationSystem.sol";
import "../src/CarbonCreditRegistry.sol";
import "../src/DAOGovernance.sol";
import "../src/NoWasteToken.sol";
import "../src/ImpactNFT.sol";

/**
 * @title DeployRemaining
 * @dev Deploy only the remaining 3 contracts that aren't deployed yet
 */
contract DeployRemaining is Script {
    
    // Already deployed addresses
    address constant TOKEN_ADDRESS = 0xD9cDF18D0d819E4bC83BAc3eabfbE564976fEc55;
    address constant DONATION_MANAGER_ADDRESS = 0x0a9E38B50C3776C16764344DF5c752B1dB8ec604;
    address constant IMPACT_NFT_ADDRESS = 0xE83644803B4b9C427033909274D20229C088D2a1;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("==============================================");
        console.log("Deploying Remaining Contracts to VeryChain");
        console.log("==============================================");
        console.log("Deployer Address:", deployer);
        console.log("==============================================\n");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ReputationSystem
        console.log("Deploying ReputationSystem...");
        ReputationSystem reputation = new ReputationSystem();
        console.log("ReputationSystem deployed at:", address(reputation), "\n");
        
        // Deploy CarbonCreditRegistry
        console.log("Deploying CarbonCreditRegistry...");
        CarbonCreditRegistry carbon = new CarbonCreditRegistry(
            IMPACT_NFT_ADDRESS,
            TOKEN_ADDRESS,
            deployer
        );
        console.log("CarbonCreditRegistry deployed at:", address(carbon), "\n");
        
        // Deploy DAOGovernance
        console.log("Deploying DAOGovernance...");
        DAOGovernance dao = new DAOGovernance(
            TOKEN_ADDRESS,
            deployer
        );
        console.log("DAOGovernance deployed at:", address(dao), "\n");
        
        vm.stopBroadcast();
        
        console.log("==============================================");
        console.log("DEPLOYMENT COMPLETE!");
        console.log("==============================================");
        console.log("ReputationSystem:", address(reputation));
        console.log("CarbonCreditRegistry:", address(carbon));
        console.log("DAOGovernance:", address(dao));
        console.log("==============================================");
    }
}
