// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/TokenFaucet.sol";

contract DeployFaucet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = 0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9; // NoWasteToken
        
        vm.startBroadcast(deployerPrivateKey);
        
        TokenFaucet faucet = new TokenFaucet(tokenAddress);
        
        console.log("TokenFaucet deployed at:", address(faucet));
        
        vm.stopBroadcast();
    }
}
