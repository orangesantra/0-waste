// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ReputationSystem
 * @dev Manages user reputation scores and calculates reward multipliers
 * Reputation ranges from 0-1000 and affects staking requirements and rewards
 */
contract ReputationSystem is Ownable {
    
    // ============ Enums ============
    
    enum Tier {
        BRONZE,
        SILVER,
        GOLD,
        PLATINUM
    }
    
    // ============ Constants ============
    
    uint256 public constant MAX_SCORE = 1000;
    uint256 public constant MIN_SCORE = 0;
    uint256 public constant INITIAL_SCORE = 0; // New users start at 0
    
    // Reputation tier thresholds
    uint256 public constant TIER_BRONZE = 0;
    uint256 public constant TIER_SILVER = 200;
    uint256 public constant TIER_GOLD = 600;
    uint256 public constant TIER_PLATINUM = 900;
    
    // ============ Structs ============
    
    struct UserReputation {
        uint256 score;                    // Current reputation score (0-1000)
        uint256 totalDonations;           // Total successful donations
        uint256 successfulDonations;      // Completed donations
        uint256 cancelledDonations;       // Cancelled by user
        uint256 totalDisputes;            // All disputes (won + lost)
        uint256 disputesLost;             // Disputes resolved against user
        uint256 lastUpdated;              // Timestamp of last update
        uint256 consecutiveSuccesses;     // Streak counter
        uint256 maxStreak;                // Maximum streak achieved
        bool initialized;                 // Track if user has been initialized
    }
    
    // ============ State Variables ============
    
    mapping(address => UserReputation) public userReputations;
    
    // Authorized contracts that can update reputation
    address public donationManagerAddress;
    address public tokenAddress;
    
    // Global statistics
    uint256 public totalUsers;
    uint256 public totalReputationUpdates;
    
    // ============ Events ============
    
    event ReputationInitialized(address indexed user, uint256 initialScore);
    event ScoreUpdated(address indexed user, uint256 oldScore, uint256 newScore, string reason);
    event DonationRecorded(address indexed user, bool successful);
    event DisputeRecorded(address indexed user, bool won);
    event StreakUpdated(address indexed user, uint256 newStreak);
    event ContractAuthorized(string contractType, address contractAddress);
    
    // ============ Modifiers ============
    
    modifier onlyAuthorized() {
        require(
            msg.sender == donationManagerAddress ||
            msg.sender == owner(),
            "Not authorized"
        );
        _;
    }
    
    modifier userExists(address user) {
        require(userReputations[user].initialized, "User not initialized");
        _;
    }
    
    // ============ Constructor ============
    
    constructor() Ownable(msg.sender) {}
    
    // ============ Initialization ============
    
    /**
     * @dev Initialize reputation for a new user
     * @param user User address
     */
    function initializeUser(address user) external onlyAuthorized {
        require(!userReputations[user].initialized, "User already initialized");
        
        userReputations[user] = UserReputation({
            score: INITIAL_SCORE,
            totalDonations: 0,
            successfulDonations: 0,
            cancelledDonations: 0,
            totalDisputes: 0,
            disputesLost: 0,
            lastUpdated: block.timestamp,
            consecutiveSuccesses: 0,
            maxStreak: 0,
            initialized: true
        });
        
        totalUsers++;
        
        emit ReputationInitialized(user, INITIAL_SCORE);
    }
    
    /**
     * @dev Auto-initialize if not exists (for convenience)
     */
    function _ensureInitialized(address user) internal {
        if (!userReputations[user].initialized) {
            userReputations[user] = UserReputation({
                score: INITIAL_SCORE,
                totalDonations: 0,
                successfulDonations: 0,
                cancelledDonations: 0,
                totalDisputes: 0,
                disputesLost: 0,
                lastUpdated: block.timestamp,
                consecutiveSuccesses: 0,
                maxStreak: 0,
                initialized: true
            });
            totalUsers++;
            emit ReputationInitialized(user, INITIAL_SCORE);
        }
    }
    
    // ============ Reputation Update Functions ============
    
    /**
     * @dev Record a successful donation
     * @param user User address
     */
    function recordSuccessfulDonation(address user) external onlyAuthorized {
        _ensureInitialized(user);
        
        UserReputation storage rep = userReputations[user];
        uint256 oldScore = rep.score;
        
        rep.totalDonations++;
        rep.successfulDonations++;
        rep.consecutiveSuccesses++;
        
        // Update max streak if current streak is higher
        if (rep.consecutiveSuccesses > rep.maxStreak) {
            rep.maxStreak = rep.consecutiveSuccesses;
        }
        
        rep.lastUpdated = block.timestamp;
        
        // Increase score by 10 per successful donation
        rep.score = _capScore(rep.score + 10);
        
        totalReputationUpdates++;
        
        emit DonationRecorded(user, true);
        emit ScoreUpdated(user, oldScore, rep.score, "Successful donation");
    }
    
    /**
     * @dev Record a cancelled donation
     * @param user User address
     */
    function recordCancelledDonation(address user) external onlyAuthorized {
        _ensureInitialized(user);
        
        UserReputation storage rep = userReputations[user];
        uint256 oldScore = rep.score;
        
        rep.totalDonations++;
        rep.cancelledDonations++;
        rep.consecutiveSuccesses = 0; // Reset streak
        rep.lastUpdated = block.timestamp;
        
        // Decrease score by 5
        uint256 penalty = 5;
        rep.score = rep.score > penalty ? rep.score - penalty : MIN_SCORE;
        
        totalReputationUpdates++;
        
        emit DonationRecorded(user, false);
        emit ScoreUpdated(user, oldScore, rep.score, "Cancelled donation");
        emit StreakUpdated(user, 0);
    }
    
    /**
     * @dev Record a dispute outcome
     * @param user User address
     * @param lost Whether user lost the dispute (true = lost, false = won)
     */
    function recordDispute(address user, bool lost) external onlyAuthorized {
        _ensureInitialized(user);
        
        UserReputation storage rep = userReputations[user];
        uint256 oldScore = rep.score;
        
        rep.totalDisputes++;
        
        if (lost) {
            rep.disputesLost++;
            rep.consecutiveSuccesses = 0; // Reset streak
            
            // Penalty for losing disputes
            uint256 penalty = 15;
            rep.score = rep.score > penalty ? rep.score - penalty : MIN_SCORE;
            
            emit StreakUpdated(user, 0);
        }
        
        rep.lastUpdated = block.timestamp;
        totalReputationUpdates++;
        
        emit DisputeRecorded(user, !lost);
        emit ScoreUpdated(user, oldScore, rep.score, lost ? "Dispute lost" : "Dispute won");
    }
    
    /**
     * @dev Manual score adjustment (admin only, for special cases)
     * @param user User address
     * @param newScore New reputation score
     * @param reason Reason for adjustment
     */
    function adjustScore(address user, uint256 newScore, string calldata reason) 
        external 
        onlyOwner 
    {
        _ensureInitialized(user);
        require(newScore <= MAX_SCORE, "Score too high");
        
        UserReputation storage rep = userReputations[user];
        uint256 oldScore = rep.score;
        
        rep.score = newScore;
        rep.lastUpdated = block.timestamp;
        
        totalReputationUpdates++;
        
        emit ScoreUpdated(user, oldScore, newScore, reason);
    }
    
    /**
     * @dev Increment score by specific amount
     * @param user User address
     * @param points Points to add
     */
    function incrementScore(address user, uint256 points) external onlyAuthorized {
        _ensureInitialized(user);
        
        UserReputation storage rep = userReputations[user];
        uint256 oldScore = rep.score;
        
        rep.score = _capScore(rep.score + points);
        rep.lastUpdated = block.timestamp;
        
        totalReputationUpdates++;
        
        emit ScoreUpdated(user, oldScore, rep.score, "Score increment");
    }
    
    /**
     * @dev Decrement score by specific amount
     * @param user User address
     * @param points Points to subtract
     */
    function decrementScore(address user, uint256 points) external onlyAuthorized {
        _ensureInitialized(user);
        
        UserReputation storage rep = userReputations[user];
        uint256 oldScore = rep.score;
        
        rep.score = rep.score > points ? rep.score - points : MIN_SCORE;
        rep.lastUpdated = block.timestamp;
        
        totalReputationUpdates++;
        
        emit ScoreUpdated(user, oldScore, rep.score, "Score decrement");
    }
    
    // ============ Calculation Functions ============
    
    /**
     * @dev Get reward multiplier based on reputation (in basis points)
     * @param user User address
     * @return Multiplier in basis points (1000 = 1.0x, 2000 = 2.0x)
     */
    function getRewardMultiplier(address user) external view returns (uint256) {
        if (!userReputations[user].initialized) {
            return 1000; // 1.0x for new users
        }
        
        uint256 score = userReputations[user].score;
        
        // Tiered multiplier system
        if (score >= TIER_PLATINUM) return 2000; // 2.0x
        if (score >= TIER_GOLD) return 1500;     // 1.5x
        if (score >= TIER_SILVER) return 1250;   // 1.25x
        return 1000;                              // 1.0x (Bronze and below)
    }
    
    /**
     * @dev Get user tier based on reputation
     * @param user User address
     * @return User's tier enum
     */
    function getTier(address user) public view returns (Tier) {
        if (!userReputations[user].initialized) {
            return Tier.BRONZE;
        }
        
        uint256 score = userReputations[user].score;
        
        if (score >= TIER_PLATINUM) return Tier.PLATINUM;
        if (score >= TIER_GOLD) return Tier.GOLD;
        if (score >= TIER_SILVER) return Tier.SILVER;
        return Tier.BRONZE;
    }
    
    /**
     * @dev Get staking discount percentage based on reputation (in basis points)
     * @param user User address
     * @return Discount in basis points (5000 = 50%)
     */
    function getStakingDiscount(address user) external view returns (uint256) {
        if (!userReputations[user].initialized) {
            return 0;
        }
        
        uint256 score = userReputations[user].score;
        
        if (score >= TIER_PLATINUM) return 5000; // 50% discount (900+)
        if (score >= TIER_GOLD) return 2500;     // 25% discount (600+)
        if (score >= TIER_SILVER) return 1000;   // 10% discount (300+)
        return 0;                                 // No discount
    }
    
    /**
     * @dev Get user tier based on reputation
     * @param user User address
     * @return Tier name (0=None, 1=Bronze, 2=Silver, 3=Gold, 4=Platinum)
     */
    function getUserTier(address user) external view returns (uint256) {
        if (!userReputations[user].initialized) {
            return 0;
        }
        
        uint256 score = userReputations[user].score;
        
        if (score >= TIER_PLATINUM) return 4;
        if (score >= TIER_GOLD) return 3;
        if (score >= TIER_SILVER) return 2;
        if (score >= TIER_BRONZE) return 1;
        return 0;
    }
    
    /**
     * @dev Calculate success rate percentage
     * @param user User address
     * @return Success rate (0-100)
     */
    function getSuccessRate(address user) external view returns (uint256) {
        if (!userReputations[user].initialized || userReputations[user].totalDonations == 0) {
            return 0;
        }
        
        UserReputation memory rep = userReputations[user];
        return (rep.successfulDonations * 100) / rep.totalDonations;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Set authorized contract addresses
     */
    function setDonationManager(address _donationManager) external onlyOwner {
        require(_donationManager != address(0), "Invalid address");
        donationManagerAddress = _donationManager;
        emit ContractAuthorized("DonationManager", _donationManager);
    }
    
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid address");
        tokenAddress = _tokenAddress;
        emit ContractAuthorized("Token", _tokenAddress);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get complete user reputation data
     */
    function getUserReputation(address user) 
        external 
        view 
        returns (
            uint256 score,
            uint256 totalDonationsCount,
            uint256 successfulDonations,
            uint256 cancelledDonations,
            uint256 disputesLost,
            uint256 consecutiveSuccesses,
            uint256 lastUpdated
        ) 
    {
        UserReputation memory rep = userReputations[user];
        return (
            rep.initialized ? rep.score : INITIAL_SCORE,
            rep.totalDonations,
            rep.successfulDonations,
            rep.cancelledDonations,
            rep.disputesLost,
            rep.consecutiveSuccesses,
            rep.lastUpdated
        );
    }
    
    /**
     * @dev Get global reputation statistics
     */
    function getGlobalStats() 
        external 
        view 
        returns (
            uint256 users,
            uint256 updates,
            uint256 avgScore
        ) 
    {
        // Note: avgScore calculation would require iterating through all users
        // For gas efficiency, this should be calculated off-chain
        return (totalUsers, totalReputationUpdates, 0);
    }
    
    /**
     * @dev Check if user is initialized
     */
    function isInitialized(address user) external view returns (bool) {
        return userReputations[user].initialized;
    }
    
    /**
     * @dev Get current score (returns initial score if not initialized)
     */
    function getScore(address user) external view returns (uint256) {
        return userReputations[user].initialized 
            ? userReputations[user].score 
            : 0;
    }
    
    /**
     * @dev Get reputation score (alias for compatibility)
     */
    function getReputationScore(address user) external view returns (uint256) {
        return userReputations[user].initialized 
            ? userReputations[user].score 
            : 0;
    }
    
    /**
     * @dev Get total donations
     */
    function totalDonations(address user) external view returns (uint256) {
        return userReputations[user].totalDonations;
    }
    
    /**
     * @dev Get total cancellations
     */
    function totalCancellations(address user) external view returns (uint256) {
        return userReputations[user].cancelledDonations;
    }
    
    /**
     * @dev Get total disputes
     */
    function totalDisputes(address user) external view returns (uint256) {
        return userReputations[user].totalDisputes;
    }
    
    /**
     * @dev Get current streak
     */
    function currentStreak(address user) external view returns (uint256) {
        return userReputations[user].consecutiveSuccesses;
    }
    
    /**
     * @dev Get max streak
     */
    function maxStreak(address user) external view returns (uint256) {
        return userReputations[user].maxStreak;
    }
    
    /**
     * @dev Get comprehensive user statistics
     */
    function getUserStats(address user) 
        external 
        view 
        returns (
            uint256 score,
            Tier tier,
            uint256 donations,
            uint256 cancellations,
            uint256 disputes,
            uint256 streak,
            uint256 maxStreakVal,
            uint256 multiplier,
            uint256 discount
        ) 
    {
        UserReputation memory rep = userReputations[user];
        score = rep.initialized ? rep.score : 0;
        tier = this.getTier(user);
        donations = rep.successfulDonations;
        cancellations = rep.cancelledDonations;
        disputes = rep.disputesLost;
        streak = rep.consecutiveSuccesses;
        maxStreakVal = rep.maxStreak;
        multiplier = this.getRewardMultiplier(user);
        discount = this.getStakingDiscount(user);
    }
    
    // ============ Internal Helper Functions ============
    
    /**
     * @dev Cap score between MIN_SCORE and MAX_SCORE
     */
    function _capScore(uint256 score) internal pure returns (uint256) {
        if (score > MAX_SCORE) return MAX_SCORE;
        if (score < MIN_SCORE) return MIN_SCORE;
        return score;
    }
}
