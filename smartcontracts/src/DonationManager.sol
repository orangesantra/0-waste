// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NoWasteToken.sol";
import "./ReputationSystem.sol";
import "./ImpactNFT.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DonationManager
 * @dev Manages food donation listings, matching, and verification
 * Handles stake deposits, reward distribution, and multi-sig confirmation
 */
contract DonationManager is Ownable, ReentrancyGuard {
    
    // ============ Structs ============
    
    struct Donation {
        uint256 id;
        address restaurant;
        string foodType;               // "Veg" or "Non-Veg"
        uint256 quantity;              // Number of food packets
        uint256 marketValue;           // Value in tokens for tax purposes
        uint256 pickupTimeStart;       // Pickup window start
        uint256 pickupTimeEnd;         // Pickup window end
        string location;               // Pickup location (could be IPFS hash)
        address ngo;
        address courier;
        DonationStatus status;
        uint256 createdAt;
        uint256 claimedAt;
        uint256 completedAt;
        string photoHash;              // IPFS hash of food photo
    }
    
    enum DonationStatus {
        LISTED,              // Created by restaurant
        CLAIMED,             // Claimed by NGO
        COURIER_ASSIGNED,    // Courier accepted delivery
        PICKUP_CONFIRMED,    // Restaurant confirmed pickup
        DELIVERED,           // Courier marked as delivered
        COMPLETED,           // NGO confirmed receipt - rewards distributed
        DISPUTED,            // Dispute raised
        CANCELLED            // Cancelled by restaurant or system
    }
    
    // ============ State Variables ============
    
    NoWasteToken public token;
    ReputationSystem public reputationSystem;
    ImpactNFT public impactNFT;
    
    // Staking requirements (in tokens with 18 decimals)
    uint256 public RESTAURANT_STAKE = 1000 * 10**18;
    uint256 public NGO_STAKE = 500 * 10**18;
    uint256 public COURIER_STAKE = 750 * 10**18;
    
    // Base reward amounts (before multipliers)
    uint256 public RESTAURANT_BASE_REWARD = 100 * 10**18;
    uint256 public NGO_BASE_REWARD = 50 * 10**18;
    uint256 public COURIER_BASE_REWARD = 75 * 10**18;
    uint256 public VALIDATOR_BASE_REWARD = 10 * 10**18;
    
    // Donation tracking
    mapping(uint256 => Donation) public donations;
    mapping(address => uint256[]) public restaurantDonations;
    mapping(address => uint256[]) public ngoDonations;
    mapping(address => uint256[]) public courierDeliveries;
    
    // Active stakes
    mapping(address => mapping(uint256 => bool)) public hasActiveStake;
    mapping(uint256 => bool) public donationHasStakes;
    
    uint256 public donationCounter;
    uint256 public totalDonationsCompleted;
    uint256 public totalFoodPacketsDonated;
    uint256 public totalRewardsDistributed;
    
    // Cancellation tracking (prevent abuse)
    mapping(address => uint256) public lastCancellationTime;
    uint256 public CANCELLATION_COOLDOWN = 1 days;
    
    // ============ Events ============
    
    event DonationListed(
        uint256 indexed id,
        address indexed restaurant,
        string foodType,
        uint256 quantity,
        uint256 pickupTimeStart
    );
    event DonationClaimed(uint256 indexed id, address indexed ngo);
    event CourierAssigned(uint256 indexed id, address indexed courier);
    event PickupConfirmed(uint256 indexed id, address indexed restaurant);
    event DeliveryConfirmed(uint256 indexed id, address indexed courier);
    event DonationCompleted(
        uint256 indexed id,
        address restaurant,
        address ngo,
        address courier,
        uint256 totalRewards
    );
    event DonationCancelled(uint256 indexed id, address indexed canceller, string reason);
    event DisputeRaised(uint256 indexed id, address indexed initiator, string reason);
    event StakeDeposited(address indexed user, uint256 donationId, uint256 amount);
    event StakeReturned(address indexed user, uint256 donationId, uint256 amount);
    event StakeSlashed(address indexed user, uint256 donationId, uint256 amount);
    event RewardDistributed(address indexed user, uint256 amount, string role);
    event PhotoUploaded(uint256 indexed id, string ipfsHash);
    
    // ============ Modifiers ============
    
    modifier onlyRestaurant(uint256 donationId) {
        require(
            donations[donationId].restaurant == msg.sender,
            "Only restaurant can call"
        );
        _;
    }
    
    modifier onlyNGO(uint256 donationId) {
        require(
            donations[donationId].ngo == msg.sender,
            "Only NGO can call"
        );
        _;
    }
    
    modifier onlyCourier(uint256 donationId) {
        require(
            donations[donationId].courier == msg.sender,
            "Only courier can call"
        );
        _;
    }
    
    modifier inStatus(uint256 donationId, DonationStatus requiredStatus) {
        require(
            donations[donationId].status == requiredStatus,
            "Invalid donation status"
        );
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _tokenAddress, address _reputationSystemAddress)
    {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_reputationSystemAddress != address(0), "Invalid reputation address");
        
        token = NoWasteToken(_tokenAddress);
        reputationSystem = ReputationSystem(_reputationSystemAddress);
    }
    
    // ============ Donation Lifecycle Functions ============
    
    /**
     * @dev Create a new food donation listing
     */
    function createDonation(
        string memory foodType,
        uint256 quantity,
        uint256 marketValue,
        uint256 pickupTimeStart,
        uint256 pickupTimeEnd,
        string memory location,
        string memory photoHash
    ) external nonReentrant returns (uint256) {
        require(quantity > 0, "Quantity must be > 0");
        require(pickupTimeStart > block.timestamp, "Pickup time must be future");
        require(pickupTimeEnd > pickupTimeStart, "Invalid time window");
        require(bytes(foodType).length > 0, "Food type required");
        require(bytes(location).length > 0, "Location required");
        
        // Check staking requirement (with reputation discount)
        uint256 requiredStake = _calculateRequiredStake(msg.sender, RESTAURANT_STAKE);
        require(
            token.stakedBalance(msg.sender) >= requiredStake,
            "Insufficient stake"
        );
        
        donationCounter++;
        uint256 donationId = donationCounter;
        
        donations[donationId] = Donation({
            id: donationId,
            restaurant: msg.sender,
            foodType: foodType,
            quantity: quantity,
            marketValue: marketValue,
            pickupTimeStart: pickupTimeStart,
            pickupTimeEnd: pickupTimeEnd,
            location: location,
            ngo: address(0),
            courier: address(0),
            status: DonationStatus.LISTED,
            createdAt: block.timestamp,
            claimedAt: 0,
            completedAt: 0,
            photoHash: photoHash
        });
        
        restaurantDonations[msg.sender].push(donationId);
        hasActiveStake[msg.sender][donationId] = true;
        donationHasStakes[donationId] = true;
        
        emit DonationListed(donationId, msg.sender, foodType, quantity, pickupTimeStart);
        
        if (bytes(photoHash).length > 0) {
            emit PhotoUploaded(donationId, photoHash);
        }
        
        return donationId;
    }
    
    /**
     * @dev NGO claims a donation listing
     */
    function claimDonation(uint256 donationId) 
        external 
        nonReentrant 
        inStatus(donationId, DonationStatus.LISTED) 
    {
        Donation storage donation = donations[donationId];
        
        // Check not expired
        require(block.timestamp < donation.pickupTimeEnd, "Donation expired");
        
        // Check staking requirement
        uint256 requiredStake = _calculateRequiredStake(msg.sender, NGO_STAKE);
        require(
            token.stakedBalance(msg.sender) >= requiredStake,
            "Insufficient stake"
        );
        
        donation.ngo = msg.sender;
        donation.status = DonationStatus.CLAIMED;
        donation.claimedAt = block.timestamp;
        
        ngoDonations[msg.sender].push(donationId);
        hasActiveStake[msg.sender][donationId] = true;
        
        emit DonationClaimed(donationId, msg.sender);
    }
    
    /**
     * @dev Courier accepts delivery job
     */
    function acceptDelivery(uint256 donationId) 
        external 
        nonReentrant 
        inStatus(donationId, DonationStatus.CLAIMED) 
    {
        Donation storage donation = donations[donationId];
        
        // Check not expired
        require(block.timestamp < donation.pickupTimeEnd, "Donation expired");
        
        // Check staking requirement
        uint256 requiredStake = _calculateRequiredStake(msg.sender, COURIER_STAKE);
        require(
            token.stakedBalance(msg.sender) >= requiredStake,
            "Insufficient stake"
        );
        
        donation.courier = msg.sender;
        donation.status = DonationStatus.COURIER_ASSIGNED;
        
        courierDeliveries[msg.sender].push(donationId);
        hasActiveStake[msg.sender][donationId] = true;
        
        emit CourierAssigned(donationId, msg.sender);
    }
    
    /**
     * @dev Restaurant confirms food was picked up
     */
    function confirmPickup(uint256 donationId) 
        external 
        nonReentrant 
        onlyRestaurant(donationId)
        inStatus(donationId, DonationStatus.COURIER_ASSIGNED) 
    {
        donations[donationId].status = DonationStatus.PICKUP_CONFIRMED;
        
        emit PickupConfirmed(donationId, msg.sender);
    }
    
    /**
     * @dev Courier confirms delivery
     */
    function confirmDelivery(uint256 donationId, string memory deliveryPhotoHash) 
        external 
        nonReentrant 
        onlyCourier(donationId)
        inStatus(donationId, DonationStatus.PICKUP_CONFIRMED) 
    {
        donations[donationId].status = DonationStatus.DELIVERED;
        
        emit DeliveryConfirmed(donationId, msg.sender);
        
        if (bytes(deliveryPhotoHash).length > 0) {
            emit PhotoUploaded(donationId, deliveryPhotoHash);
        }
    }
    
    /**
     * @dev NGO confirms receipt and completes donation
     * This triggers reward distribution
     */
    function confirmReceipt(uint256 donationId) 
        external 
        nonReentrant 
        onlyNGO(donationId)
        inStatus(donationId, DonationStatus.DELIVERED) 
    {
        Donation storage donation = donations[donationId];
        
        donation.status = DonationStatus.COMPLETED;
        donation.completedAt = block.timestamp;
        
        // Distribute rewards and update reputation
        _completeDonation(donationId);
    }
    
    /**
     * @dev Cancel donation (only before claimed, or after expiry)
     */
    function cancelDonation(uint256 donationId, string memory reason) 
        external 
        nonReentrant 
        onlyRestaurant(donationId) 
    {
        Donation storage donation = donations[donationId];
        
        require(
            donation.status == DonationStatus.LISTED ||
            block.timestamp > donation.pickupTimeEnd,
            "Cannot cancel at this stage"
        );
        
        // Check cooldown to prevent abuse
        require(
            block.timestamp > lastCancellationTime[msg.sender] + CANCELLATION_COOLDOWN,
            "Cancellation cooldown active"
        );
        
        donation.status = DonationStatus.CANCELLED;
        lastCancellationTime[msg.sender] = block.timestamp;
        
        // Return stake
        hasActiveStake[msg.sender][donationId] = false;
        
        // Penalize reputation for cancellation
        reputationSystem.recordCancelledDonation(msg.sender);
        
        emit DonationCancelled(donationId, msg.sender, reason);
    }
    
    /**
     * @dev Raise dispute (callable by any party)
     */
    function raiseDispute(uint256 donationId, string memory reason) external nonReentrant {
        Donation storage donation = donations[donationId];
        
        require(
            msg.sender == donation.restaurant ||
            msg.sender == donation.ngo ||
            msg.sender == donation.courier,
            "Not a party to this donation"
        );
        
        require(
            donation.status != DonationStatus.COMPLETED &&
            donation.status != DonationStatus.CANCELLED &&
            donation.status != DonationStatus.DISPUTED,
            "Cannot dispute in current status"
        );
        
        donation.status = DonationStatus.DISPUTED;
        
        emit DisputeRaised(donationId, msg.sender, reason);
        
        // Note: Dispute resolution would be handled by DAO governance
        // For now, we just mark it as disputed
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Complete donation and distribute rewards
     */
    function _completeDonation(uint256 donationId) internal {
        Donation storage donation = donations[donationId];
        
        // Calculate rewards with multipliers
        uint256 restaurantReward = _calculateReward(
            donation.restaurant,
            RESTAURANT_BASE_REWARD,
            donation.quantity
        );
        
        uint256 ngoReward = _calculateReward(
            donation.ngo,
            NGO_BASE_REWARD,
            donation.quantity
        );
        
        uint256 courierReward = donation.courier != address(0)
            ? _calculateReward(donation.courier, COURIER_BASE_REWARD, donation.quantity)
            : 0;
        
        uint256 totalRewards = restaurantReward + ngoReward + courierReward;
        
        // Distribute rewards (using transferNoBurn to avoid double-burn)
        token.transferNoBurn(address(this), donation.restaurant, restaurantReward);
        token.transferNoBurn(address(this), donation.ngo, ngoReward);
        
        if (donation.courier != address(0)) {
            token.transferNoBurn(address(this), donation.courier, courierReward);
        }
        
        // Return stakes
        hasActiveStake[donation.restaurant][donationId] = false;
        hasActiveStake[donation.ngo][donationId] = false;
        
        if (donation.courier != address(0)) {
            hasActiveStake[donation.courier][donationId] = false;
        }
        
        donationHasStakes[donationId] = false;
        
        // Update reputation
        reputationSystem.recordSuccessfulDonation(donation.restaurant);
        reputationSystem.recordSuccessfulDonation(donation.ngo);
        
        if (donation.courier != address(0)) {
            reputationSystem.recordSuccessfulDonation(donation.courier);
        }
        
        // Update statistics
        totalDonationsCompleted++;
        totalFoodPacketsDonated += donation.quantity;
        totalRewardsDistributed += totalRewards;
        
        // Mint Impact NFT certificate to restaurant
        if (address(impactNFT) != address(0)) {
            impactNFT.mintImpactCertificate(
                donation.restaurant,
                donation.ngo,
                donation.quantity,
                donation.marketValue,
                donation.foodType,
                donationId
            );
        }
        
        emit RewardDistributed(donation.restaurant, restaurantReward, "Restaurant");
        emit RewardDistributed(donation.ngo, ngoReward, "NGO");
        
        if (donation.courier != address(0)) {
            emit RewardDistributed(donation.courier, courierReward, "Courier");
        }
        
        emit DonationCompleted(
            donationId,
            donation.restaurant,
            donation.ngo,
            donation.courier,
            totalRewards
        );
    }
    
    /**
     * @dev Calculate reward with reputation and quantity multipliers
     */
    function _calculateReward(
        address user,
        uint256 baseReward,
        uint256 quantity
    ) internal view returns (uint256) {
        // Get reputation multiplier (in basis points: 1000 = 1.0x)
        uint256 repMultiplier = reputationSystem.getRewardMultiplier(user);
        
        // Quantity multiplier: +0.2% per packet (max 1.5x at 250 packets)
        uint256 qtyMultiplier = 1000 + (quantity * 2);
        if (qtyMultiplier > 1500) {
            qtyMultiplier = 1500;
        }
        
        // Calculate final reward
        uint256 reward = baseReward;
        reward = (reward * repMultiplier) / 1000;
        reward = (reward * qtyMultiplier) / 1000;
        
        return reward;
    }
    
    /**
     * @dev Calculate required stake with reputation discount
     */
    function _calculateRequiredStake(address user, uint256 baseStake) 
        internal 
        view 
        returns (uint256) 
    {
        uint256 discount = reputationSystem.getStakingDiscount(user);
        
        if (discount == 0) {
            return baseStake;
        }
        
        uint256 discountAmount = (baseStake * discount) / 100;
        return baseStake - discountAmount;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Update staking requirements
     */
    function updateStakingRequirements(
        uint256 _restaurantStake,
        uint256 _ngoStake,
        uint256 _courierStake
    ) external onlyOwner {
        RESTAURANT_STAKE = _restaurantStake;
        NGO_STAKE = _ngoStake;
        COURIER_STAKE = _courierStake;
    }
    
    /**
     * @dev Update base reward amounts
     */
    function updateBaseRewards(
        uint256 _restaurantReward,
        uint256 _ngoReward,
        uint256 _courierReward
    ) external onlyOwner {
        RESTAURANT_BASE_REWARD = _restaurantReward;
        NGO_BASE_REWARD = _ngoReward;
        COURIER_BASE_REWARD = _courierReward;
    }
    
    /**
     * @dev Resolve dispute (DAO governance function)
     * @param donationId Donation ID
     * @param winner Address of dispute winner
     */
    function resolveDispute(uint256 donationId, address winner) 
        external 
        onlyOwner 
        inStatus(donationId, DonationStatus.DISPUTED) 
    {
        Donation storage donation = donations[donationId];
        
        require(
            winner == donation.restaurant ||
            winner == donation.ngo ||
            winner == donation.courier,
            "Invalid winner"
        );
        
        // Record dispute outcomes in reputation
        if (winner == donation.restaurant) {
            reputationSystem.recordDispute(donation.restaurant, true);
            if (donation.ngo != address(0)) {
                reputationSystem.recordDispute(donation.ngo, false);
            }
        } else if (winner == donation.ngo) {
            reputationSystem.recordDispute(donation.ngo, true);
            reputationSystem.recordDispute(donation.restaurant, false);
        }
        
        // Mark as cancelled (no rewards distributed)
        donation.status = DonationStatus.CANCELLED;
        
        // Return stakes
        hasActiveStake[donation.restaurant][donationId] = false;
        if (donation.ngo != address(0)) {
            hasActiveStake[donation.ngo][donationId] = false;
        }
        if (donation.courier != address(0)) {
            hasActiveStake[donation.courier][donationId] = false;
        }
        
        donationHasStakes[donationId] = false;
    }
    
    /**
     * @dev Emergency withdraw for contract (only owner)
     */
    function emergencyWithdraw(address recipient, uint256 amount) 
        external 
        onlyOwner 
    {
        require(recipient != address(0), "Invalid recipient");
        token.transferNoBurn(address(this), recipient, amount);
    }
    
    /**
     * @dev Fund contract with rewards (owner deposits tokens)
     */
    function fundRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be > 0");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get donation details
     */
    function getDonation(uint256 donationId) 
        external 
        view 
        returns (Donation memory) 
    {
        return donations[donationId];
    }
    
    /**
     * @dev Get all donations by restaurant
     */
    function getRestaurantDonations(address restaurant) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return restaurantDonations[restaurant];
    }
    
    /**
     * @dev Get all donations by NGO
     */
    function getNGODonations(address ngo) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return ngoDonations[ngo];
    }
    
    /**
     * @dev Get all deliveries by courier
     */
    function getCourierDeliveries(address courier) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return courierDeliveries[courier];
    }
    
    /**
     * @dev Get platform statistics
     */
    function getPlatformStats() 
        external 
        view 
        returns (
            uint256 totalDonations,
            uint256 completedDonations,
            uint256 totalPackets,
            uint256 totalRewards
        ) 
    {
        return (
            donationCounter,
            totalDonationsCompleted,
            totalFoodPacketsDonated,
            totalRewardsDistributed
        );
    }
    
    /**
     * @dev Check if user can unstake (no active donations)
     */
    function canUnstake(address user) external view returns (bool) {
        // Check restaurant donations
        uint256[] memory userDonations = restaurantDonations[user];
        for (uint256 i = 0; i < userDonations.length; i++) {
            if (hasActiveStake[user][userDonations[i]]) {
                return false;
            }
        }
        
        // Check NGO donations
        userDonations = ngoDonations[user];
        for (uint256 i = 0; i < userDonations.length; i++) {
            if (hasActiveStake[user][userDonations[i]]) {
                return false;
            }
        }
        
        // Check courier deliveries
        userDonations = courierDeliveries[user];
        for (uint256 i = 0; i < userDonations.length; i++) {
            if (hasActiveStake[user][userDonations[i]]) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @dev Get required stake for user (with discount)
     */
    function getRequiredStake(address user, uint256 role) 
        external 
        view 
        returns (uint256) 
    {
        uint256 baseStake;
        
        if (role == 0) {
            baseStake = RESTAURANT_STAKE;
        } else if (role == 1) {
            baseStake = NGO_STAKE;
        } else if (role == 2) {
            baseStake = COURIER_STAKE;
        } else {
            revert("Invalid role");
        }
        
        return _calculateRequiredStake(user, baseStake);
    }
    
    /**
     * @dev Set ImpactNFT contract address (owner only)
     */
    function setImpactNFT(address _impactNFTAddress) external onlyOwner {
        require(_impactNFTAddress != address(0), "Invalid ImpactNFT address");
        impactNFT = ImpactNFT(_impactNFTAddress);
    }
}
