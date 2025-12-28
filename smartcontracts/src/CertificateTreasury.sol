// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NoWasteToken.sol";
import "./CertificateMarketplace.sol";

/**
 * @title CertificateTreasury
 * @dev Treasury pool providing liquidity guarantee for certificate marketplace
 * Ensures restaurants always get compensated even if no users buy
 */
contract CertificateTreasury is Ownable, ReentrancyGuard {
    
    // ============ Structs ============
    
    struct Depositor {
        uint256 totalDeposited;
        uint256 depositTime;
        uint256 rewardsClaimed;
        bool active;
    }
    
    // ============ State Variables ============
    
    NoWasteToken public token;
    CertificateMarketplace public marketplace;
    
    mapping(address => Depositor) public depositors;
    address[] public depositorList;
    
    // Treasury parameters
    uint256 public totalDeposited;
    uint256 public totalWithdrawn;
    uint256 public treasuryBalance;
    
    // APY parameters (10% annual)
    uint256 public annualAPY = 10; // 10%
    uint256 public constant SECONDS_PER_YEAR = 365 days;
    
    // Auto-redemption reserve
    uint256 public reserveRatio = 20; // Keep 20% for auto-redemptions
    uint256 public minReserveAmount = 10000 * 10**18; // 10k tokens minimum
    
    // Statistics
    uint256 public totalRewardsPaid;
    uint256 public totalAutoRedemptions;
    uint256 public totalAutoRedemptionVolume;
    
    // ============ Events ============
    
    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed depositor, uint256 amount, uint256 rewards);
    event RewardsClaimed(address indexed depositor, uint256 rewards);
    event AutoRedemptionExecuted(uint256 indexed nftId, uint256 price);
    event APYUpdated(uint256 oldAPY, uint256 newAPY);
    event EmergencyWithdrawal(address indexed admin, uint256 amount);
    
    // ============ Constructor ============
    
    constructor(address _tokenAddress, address _marketplaceAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_marketplaceAddress != address(0), "Invalid marketplace address");
        
        token = NoWasteToken(_tokenAddress);
        marketplace = CertificateMarketplace(_marketplaceAddress);
    }
    
    // ============ Deposit Functions ============
    
    /**
     * @dev Deposit tokens to treasury and earn APY
     * @param amount Amount to deposit
     */
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        
        // Transfer tokens to treasury
        token.transferFrom(msg.sender, address(this), amount);
        
        Depositor storage depositor = depositors[msg.sender];
        
        // If first deposit, add to list
        if (!depositor.active) {
            depositorList.push(msg.sender);
            depositor.active = true;
            depositor.depositTime = block.timestamp;
        } else {
            // Claim pending rewards before new deposit
            _claimPendingRewards(msg.sender);
        }
        
        depositor.totalDeposited += amount;
        depositor.depositTime = block.timestamp;
        
        totalDeposited += amount;
        treasuryBalance += amount;
        
        emit Deposited(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw deposited tokens and rewards
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant {
        Depositor storage depositor = depositors[msg.sender];
        require(depositor.active, "No deposits");
        require(amount <= depositor.totalDeposited, "Insufficient balance");
        
        // Calculate and claim all pending rewards
        uint256 rewards = calculatePendingRewards(msg.sender);
        
        // Check treasury has enough (excluding reserve)
        uint256 availableBalance = getAvailableBalance();
        require(amount + rewards <= availableBalance, "Insufficient treasury balance");
        
        depositor.totalDeposited -= amount;
        totalWithdrawn += amount;
        treasuryBalance -= (amount + rewards);
        
        // If fully withdrawn, mark inactive
        if (depositor.totalDeposited == 0) {
            depositor.active = false;
        } else {
            // Reset deposit time for remaining balance
            depositor.depositTime = block.timestamp;
        }
        
        // Transfer tokens + rewards
        token.transfer(msg.sender, amount + rewards);
        
        emit Withdrawn(msg.sender, amount, rewards);
    }
    
    /**
     * @dev Claim rewards without withdrawing principal
     */
    function claimRewards() external nonReentrant {
        _claimPendingRewards(msg.sender);
    }
    
    /**
     * @dev Internal function to claim pending rewards
     */
    function _claimPendingRewards(address depositorAddress) internal {
        uint256 rewards = calculatePendingRewards(depositorAddress);
        
        if (rewards > 0) {
            Depositor storage depositor = depositors[depositorAddress];
            
            depositor.rewardsClaimed += rewards;
            depositor.depositTime = block.timestamp; // Reset time
            
            totalRewardsPaid += rewards;
            treasuryBalance -= rewards;
            
            token.transfer(depositorAddress, rewards);
            
            emit RewardsClaimed(depositorAddress, rewards);
        }
    }
    
    // ============ Auto-Redemption Functions ============
    
    /**
     * @dev Execute auto-redemption for expired listing
     * @param nftId NFT token ID
     */
    function executeAutoRedemption(uint256 nftId) external nonReentrant {
        // Get listing details
        CertificateMarketplace.Listing memory listing = marketplace.getListing(nftId);
        require(listing.active, "Not active listing");
        require(
            block.timestamp >= listing.listedAt + marketplace.autoRedeemPeriod(),
            "Redemption period not reached"
        );
        
        uint256 redemptionPrice = (listing.price * marketplace.autoRedeemDiscount()) / 100;
        
        // Check reserve can cover it
        require(getReserveBalance() >= redemptionPrice, "Insufficient reserve");
        
        // Approve marketplace to spend treasury tokens
        token.approve(address(marketplace), redemptionPrice);
        
        // Execute auto-redemption through marketplace
        marketplace.autoRedeemCertificate(nftId);
        
        // Update stats
        totalAutoRedemptions++;
        totalAutoRedemptionVolume += redemptionPrice;
        treasuryBalance -= redemptionPrice;
        
        emit AutoRedemptionExecuted(nftId, redemptionPrice);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Calculate pending rewards for depositor
     * @param depositorAddress Address to check
     * @return Pending rewards amount
     */
    function calculatePendingRewards(address depositorAddress) 
        public 
        view 
        returns (uint256) 
    {
        Depositor memory depositor = depositors[depositorAddress];
        
        if (!depositor.active || depositor.totalDeposited == 0) {
            return 0;
        }
        
        uint256 timeElapsed = block.timestamp - depositor.depositTime;
        uint256 annualReward = (depositor.totalDeposited * annualAPY) / 100;
        uint256 reward = (annualReward * timeElapsed) / SECONDS_PER_YEAR;
        
        return reward;
    }
    
    /**
     * @dev Get depositor information
     */
    function getDepositorInfo(address depositorAddress) 
        external 
        view 
        returns (
            uint256 deposited,
            uint256 pendingRewards,
            uint256 claimedRewards,
            uint256 depositTime,
            bool active
        ) 
    {
        Depositor memory depositor = depositors[depositorAddress];
        uint256 pending = calculatePendingRewards(depositorAddress);
        
        return (
            depositor.totalDeposited,
            pending,
            depositor.rewardsClaimed,
            depositor.depositTime,
            depositor.active
        );
    }
    
    /**
     * @dev Get reserve balance (for auto-redemptions)
     */
    function getReserveBalance() public view returns (uint256) {
        uint256 reserve = (treasuryBalance * reserveRatio) / 100;
        return reserve < minReserveAmount ? minReserveAmount : reserve;
    }
    
    /**
     * @dev Get available balance (for withdrawals)
     */
    function getAvailableBalance() public view returns (uint256) {
        uint256 reserve = getReserveBalance();
        return treasuryBalance > reserve ? treasuryBalance - reserve : 0;
    }
    
    /**
     * @dev Get treasury statistics
     */
    function getTreasuryStats() 
        external 
        view 
        returns (
            uint256 _totalDeposited,
            uint256 _totalWithdrawn,
            uint256 _treasuryBalance,
            uint256 _totalRewardsPaid,
            uint256 _totalAutoRedemptions,
            uint256 _depositorCount
        ) 
    {
        return (
            totalDeposited,
            totalWithdrawn,
            treasuryBalance,
            totalRewardsPaid,
            totalAutoRedemptions,
            depositorList.length
        );
    }
    
    /**
     * @dev Calculate current APY rate
     */
    function getCurrentAPY() external view returns (uint256) {
        return annualAPY;
    }
    
    /**
     * @dev Get all depositors
     */
    function getAllDepositors() external view returns (address[] memory) {
        return depositorList;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Update APY rate
     */
    function setAPY(uint256 newAPY) external onlyOwner {
        require(newAPY <= 50, "APY too high"); // Max 50%
        
        uint256 oldAPY = annualAPY;
        annualAPY = newAPY;
        
        emit APYUpdated(oldAPY, newAPY);
    }
    
    /**
     * @dev Update reserve ratio
     */
    function setReserveRatio(uint256 newRatio) external onlyOwner {
        require(newRatio <= 50, "Ratio too high"); // Max 50%
        reserveRatio = newRatio;
    }
    
    /**
     * @dev Update minimum reserve amount
     */
    function setMinReserve(uint256 amount) external onlyOwner {
        minReserveAmount = amount;
    }
    
    /**
     * @dev Update marketplace address
     */
    function setMarketplace(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "Invalid address");
        marketplace = CertificateMarketplace(_marketplaceAddress);
    }
    
    /**
     * @dev Add funds to treasury (from platform fees, donations, etc.)
     */
    function addFunds(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        treasuryBalance += amount;
    }
    
    /**
     * @dev Emergency withdraw (admin only, for upgrades/migrations)
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount <= treasuryBalance, "Insufficient balance");
        
        treasuryBalance -= amount;
        token.transfer(owner(), amount);
        
        emit EmergencyWithdrawal(owner(), amount);
    }
}
