// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NoWasteToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenFaucet
 * @dev Distributes NOWASTE tokens to new users (one-time claim)
 */
contract TokenFaucet is Ownable {
    
    NoWasteToken public token;
    
    uint256 public CLAIM_AMOUNT = 3000 * 10**18; // 3000 tokens
    uint256 public CLAIM_COOLDOWN = 7 days; // Can claim once per week
    uint256 public MAX_TREASURY = 1000000 * 10**18; // 1M token limit
    
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public totalClaimed;
    
    uint256 public totalDistributed;
    bool public faucetActive = true;
    
    event TokensClaimed(address indexed user, uint256 amount);
    event FaucetFunded(address indexed funder, uint256 amount);
    event FaucetStatusChanged(bool active);
    
    constructor(address _tokenAddress) Ownable() {
        token = NoWasteToken(_tokenAddress);
    }
    
    /**
     * @dev Claim tokens (3000 NOWASTE)
     * Can only claim once per cooldown period
     */
    function claimTokens() external {
        require(faucetActive, "Faucet is currently inactive");
        require(
            block.timestamp >= lastClaimTime[msg.sender] + CLAIM_COOLDOWN,
            "Claim cooldown not elapsed"
        );
        require(
            token.balanceOf(address(this)) >= CLAIM_AMOUNT,
            "Faucet empty - please try again later"
        );
        require(
            totalDistributed + CLAIM_AMOUNT <= MAX_TREASURY,
            "Treasury limit reached"
        );
        
        lastClaimTime[msg.sender] = block.timestamp;
        totalClaimed[msg.sender] += CLAIM_AMOUNT;
        totalDistributed += CLAIM_AMOUNT;
        
        require(
            token.transfer(msg.sender, CLAIM_AMOUNT),
            "Transfer failed"
        );
        
        emit TokensClaimed(msg.sender, CLAIM_AMOUNT);
    }
    
    /**
     * @dev Check if user can claim
     */
    function canClaim(address user) external view returns (bool) {
        if (!faucetActive) return false;
        if (token.balanceOf(address(this)) < CLAIM_AMOUNT) return false;
        if (totalDistributed + CLAIM_AMOUNT > MAX_TREASURY) return false;
        if (block.timestamp < lastClaimTime[user] + CLAIM_COOLDOWN) return false;
        return true;
    }
    
    /**
     * @dev Get time until user can claim again
     */
    function timeUntilNextClaim(address user) external view returns (uint256) {
        if (lastClaimTime[user] == 0) return 0;
        uint256 nextClaimTime = lastClaimTime[user] + CLAIM_COOLDOWN;
        if (block.timestamp >= nextClaimTime) return 0;
        return nextClaimTime - block.timestamp;
    }
    
    /**
     * @dev Owner can fund the faucet
     */
    function fundFaucet(uint256 amount) external {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        emit FaucetFunded(msg.sender, amount);
    }
    
    /**
     * @dev Update claim amount (owner only)
     */
    function setClaimAmount(uint256 newAmount) external onlyOwner {
        CLAIM_AMOUNT = newAmount;
    }
    
    /**
     * @dev Update cooldown period (owner only)
     */
    function setCooldown(uint256 newCooldown) external onlyOwner {
        CLAIM_COOLDOWN = newCooldown;
    }
    
    /**
     * @dev Toggle faucet active status (owner only)
     */
    function setFaucetActive(bool active) external onlyOwner {
        faucetActive = active;
        emit FaucetStatusChanged(active);
    }
    
    /**
     * @dev Emergency withdraw (owner only)
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "Transfer failed");
    }
    
    /**
     * @dev Get faucet statistics
     */
    function getFaucetStats() external view returns (
        uint256 balance,
        uint256 distributed,
        uint256 remaining,
        bool active
    ) {
        balance = token.balanceOf(address(this));
        distributed = totalDistributed;
        remaining = MAX_TREASURY > totalDistributed ? MAX_TREASURY - totalDistributed : 0;
        active = faucetActive;
    }
}
