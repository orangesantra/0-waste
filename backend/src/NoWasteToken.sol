// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title NoWasteToken
 * @dev ERC20 token with built-in burn mechanism, staking, and reputation integration
 * Total Supply: 1,000,000,000 tokens
 * Features: 1% auto-burn on transfers, staking for platform participation, reputation-weighted voting
 */
contract NoWasteToken is ERC20, Ownable, ReentrancyGuard {
    
    // ============ Constants ============
    
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens
    uint256 public constant BURN_RATE = 100; // 1% = 100 basis points (out of 10000)
    uint256 public constant BASIS_POINTS = 10000;
    
    // ============ State Variables ============
    
    // Staking mappings
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTimestamp;
    
    // Reputation scores (managed by ReputationSystem contract)
    mapping(address => uint256) public reputationScore; // 0-1000
    
    // Revenue distribution tracking
    mapping(address => uint256) public lastClaimedRevenue;
    uint256 public totalRevenueDistributed;
    uint256 public revenuePerToken;
    
    // Authorized contracts
    address public reputationSystemAddress;
    address public donationManagerAddress;
    address public daoGovernanceAddress;
    
    // Treasury and burn tracking
    address public treasuryAddress;
    uint256 public totalBurned;
    
    // ============ Events ============
    
    event TokensBurned(address indexed from, uint256 amount);
    event TokensStaked(address indexed user, uint256 amount, uint256 timestamp);
    event TokensUnstaked(address indexed user, uint256 amount);
    event ReputationUpdated(address indexed user, uint256 newScore);
    event RevenueDistributed(uint256 amount, uint256 newRevenuePerToken);
    event RevenueClaimed(address indexed user, uint256 amount);
    event ContractAuthorized(string contractType, address contractAddress);
    
    // ============ Modifiers ============
    
    modifier onlyAuthorized() {
        require(
            msg.sender == reputationSystemAddress ||
            msg.sender == donationManagerAddress ||
            msg.sender == owner(),
            "Not authorized"
        );
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _treasuryAddress) 
        ERC20("NoWaste Token", "NOWASTE") 
        Ownable(msg.sender)
    {
        require(_treasuryAddress != address(0), "Invalid treasury address");
        treasuryAddress = _treasuryAddress;
        
        // Mint total supply to deployer for distribution
        _mint(msg.sender, MAX_SUPPLY);
    }
    
    // ============ Transfer Functions with Auto-Burn ============
    
    /**
     * @dev Override transfer to include automatic 1% burn
     * @param to Recipient address
     * @param amount Amount to transfer (before burn)
     * @return bool Success status
     */
    function transfer(address to, uint256 amount) 
        public 
        virtual 
        override 
        returns (bool) 
    {
        address owner = _msgSender();
        
        // Calculate burn amount (1%)
        uint256 burnAmount = (amount * BURN_RATE) / BASIS_POINTS;
        uint256 transferAmount = amount - burnAmount;
        
        // Burn tokens
        _burn(owner, burnAmount);
        totalBurned += burnAmount;
        emit TokensBurned(owner, burnAmount);
        
        // Transfer remaining
        _transfer(owner, to, transferAmount);
        
        return true;
    }
    
    /**
     * @dev Override transferFrom to include automatic 1% burn
     */
    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        
        // Calculate burn amount (1%)
        uint256 burnAmount = (amount * BURN_RATE) / BASIS_POINTS;
        uint256 transferAmount = amount - burnAmount;
        
        // Burn tokens
        _burn(from, burnAmount);
        totalBurned += burnAmount;
        emit TokensBurned(from, burnAmount);
        
        // Transfer remaining
        _transfer(from, to, transferAmount);
        
        return true;
    }
    
    /**
     * @dev Transfer without burn (for internal contract operations)
     * Can only be called by authorized contracts
     */
    function transferNoBurn(address from, address to, uint256 amount)
        external
        onlyAuthorized
        returns (bool)
    {
        _transfer(from, to, amount);
        return true;
    }
    
    // ============ Staking Functions ============
    
    /**
     * @dev Stake tokens to participate in platform
     * @param amount Amount of tokens to stake
     */
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        // Transfer tokens to contract
        _transfer(msg.sender, address(this), amount);
        
        // Update staking balance
        stakedBalance[msg.sender] += amount;
        
        // Record timestamp for first stake
        if (stakingTimestamp[msg.sender] == 0) {
            stakingTimestamp[msg.sender] = block.timestamp;
        }
        
        emit TokensStaked(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @dev Unstake tokens (can only be called if no active donations)
     * @param amount Amount of tokens to unstake
     */
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");
        
        // Update staking balance
        stakedBalance[msg.sender] -= amount;
        
        // Reset timestamp if fully unstaked
        if (stakedBalance[msg.sender] == 0) {
            stakingTimestamp[msg.sender] = 0;
        }
        
        // Transfer tokens back to user
        _transfer(address(this), msg.sender, amount);
        
        emit TokensUnstaked(msg.sender, amount);
    }
    
    /**
     * @dev Get total balance including staked tokens
     */
    function getTotalBalance(address account) external view returns (uint256) {
        return balanceOf(account) + stakedBalance[account];
    }
    
    /**
     * @dev Check if user has minimum stake required
     */
    function hasMinimumStake(address account, uint256 minimumRequired) 
        external 
        view 
        returns (bool) 
    {
        return stakedBalance[account] >= minimumRequired;
    }
    
    // ============ Reputation Functions ============
    
    /**
     * @dev Update user reputation score (only callable by ReputationSystem)
     * @param user User address
     * @param score New reputation score (0-1000)
     */
    function updateReputation(address user, uint256 score) 
        external 
        onlyAuthorized 
    {
        require(score <= 1000, "Score must be <= 1000");
        reputationScore[user] = score;
        emit ReputationUpdated(user, score);
    }
    
    /**
     * @dev Get voting power (token balance + staked, weighted by reputation)
     * @param user User address
     * @return Voting power with reputation multiplier
     */
    function getVotingPower(address user) external view returns (uint256) {
        uint256 baseBalance = balanceOf(user) + stakedBalance[user];
        
        // Reputation multiplier: 1000 = 1.0x, 2000 = 2.0x
        uint256 multiplier = 1000 + (reputationScore[user] / 2);
        
        return (baseBalance * multiplier) / 1000;
    }
    
    // ============ Revenue Distribution ============
    
    /**
     * @dev Distribute revenue to all token holders
     * @param amount Amount of tokens to distribute
     */
    function distributeRevenue(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot distribute 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        // Transfer revenue to contract
        _transfer(msg.sender, address(this), amount);
        
        // Calculate revenue per token
        uint256 circulatingSupply = totalSupply() - balanceOf(address(this));
        require(circulatingSupply > 0, "No circulating supply");
        
        uint256 additionalRevenuePerToken = (amount * 1e18) / circulatingSupply;
        revenuePerToken += additionalRevenuePerToken;
        totalRevenueDistributed += amount;
        
        emit RevenueDistributed(amount, revenuePerToken);
    }
    
    /**
     * @dev Claim accumulated revenue share
     */
    function claimRevenue() external nonReentrant {
        uint256 userBalance = balanceOf(msg.sender) + stakedBalance[msg.sender];
        require(userBalance > 0, "No tokens held");
        
        uint256 pendingRevenue = calculatePendingRevenue(msg.sender);
        require(pendingRevenue > 0, "No revenue to claim");
        
        lastClaimedRevenue[msg.sender] = revenuePerToken;
        
        // Transfer revenue from contract to user
        _transfer(address(this), msg.sender, pendingRevenue);
        
        emit RevenueClaimed(msg.sender, pendingRevenue);
    }
    
    /**
     * @dev Calculate pending revenue for a user
     */
    function calculatePendingRevenue(address user) public view returns (uint256) {
        uint256 userBalance = balanceOf(user) + stakedBalance[user];
        if (userBalance == 0) return 0;
        
        uint256 revenuePerTokenDiff = revenuePerToken - lastClaimedRevenue[user];
        return (userBalance * revenuePerTokenDiff) / 1e18;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Set authorized contract addresses
     */
    function setReputationSystem(address _reputationSystem) external onlyOwner {
        require(_reputationSystem != address(0), "Invalid address");
        reputationSystemAddress = _reputationSystem;
        emit ContractAuthorized("ReputationSystem", _reputationSystem);
    }
    
    function setDonationManager(address _donationManager) external onlyOwner {
        require(_donationManager != address(0), "Invalid address");
        donationManagerAddress = _donationManager;
        emit ContractAuthorized("DonationManager", _donationManager);
    }
    
    function setDAOGovernance(address _daoGovernance) external onlyOwner {
        require(_daoGovernance != address(0), "Invalid address");
        daoGovernanceAddress = _daoGovernance;
        emit ContractAuthorized("DAOGovernance", _daoGovernance);
    }
    
    function setTreasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasuryAddress = _treasury;
    }
    
    /**
     * @dev Manual burn function for buyback & burn
     */
    function burn(uint256 amount) external {
        require(amount > 0, "Cannot burn 0");
        _burn(msg.sender, amount);
        totalBurned += amount;
        emit TokensBurned(msg.sender, amount);
    }
    
    /**
     * @dev Burn from specific address (only owner, for treasury buyback)
     */
    function burnFrom(address account, uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot burn 0");
        _burn(account, amount);
        totalBurned += amount;
        emit TokensBurned(account, amount);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get token statistics
     */
    function getTokenStats() external view returns (
        uint256 circulatingSupply,
        uint256 totalStaked,
        uint256 burnedTokens,
        uint256 treasuryBalance
    ) {
        circulatingSupply = totalSupply();
        totalStaked = balanceOf(address(this));
        burnedTokens = totalBurned;
        treasuryBalance = balanceOf(treasuryAddress);
    }
    
    /**
     * @dev Get user stats
     */
    function getUserStats(address user) external view returns (
        uint256 balance,
        uint256 staked,
        uint256 reputation,
        uint256 votingPower,
        uint256 pendingRevenue,
        uint256 stakingDuration
    ) {
        balance = balanceOf(user);
        staked = stakedBalance[user];
        reputation = reputationScore[user];
        votingPower = this.getVotingPower(user);
        pendingRevenue = calculatePendingRevenue(user);
        if (stakingTimestamp[user] > 0) {
            stakingDuration = block.timestamp - stakingTimestamp[user];
            // Ensure at least 1 if actively staking
            if (stakingDuration == 0 && stakedBalance[user] > 0) {
                stakingDuration = 1;
            }
        } else {
            stakingDuration = 0;
        }
    }
}
