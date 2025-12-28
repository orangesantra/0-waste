// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ImpactNFT.sol";
import "./NoWasteToken.sol";
import "./ReputationSystem.sol";

/**
 * @title CertificateMarketplace
 * @dev Decentralized marketplace for Impact NFT certificates
 * Replaces government tax compensation with direct user purchases
 */
contract CertificateMarketplace is Ownable, ReentrancyGuard {
    
    // ============ Structs ============
    
    struct Listing {
        uint256 nftId;
        address seller;
        uint256 price;
        uint256 listedAt;
        bool active;
        uint256 co2Amount;
        uint256 foodQuantity;
    }
    
    struct BuyerStats {
        uint256 totalPurchased;
        uint256 totalRetired;
        uint256 totalSpent;
        uint256 lastPurchaseTime;
        bool hasSubscription;
    }
    
    // ============ State Variables ============
    
    ImpactNFT public impactNFT;
    NoWasteToken public token;
    ReputationSystem public reputationSystem;
    
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256[]) public sellerListings;
    mapping(address => uint256[]) public buyerPurchases;
    mapping(address => BuyerStats) public buyerStats;
    
    uint256[] public activeListings;
    
    // Platform fees and rewards
    uint256 public platformFeePercent = 5; // 5% platform fee
    uint256 public treasuryFeePercent = 2; // 2% goes to treasury
    uint256 public buyerRewardPercent = 3; // 3% returned as buyer rewards
    
    address public treasuryAddress;
    
    // Buyer reward milestones
    uint256 public constant REWARD_PER_PURCHASE = 50 * 10**18; // 50 tokens
    uint256 public constant REWARD_5_PURCHASES = 300 * 10**18; // 300 bonus
    uint256 public constant REWARD_10_PURCHASES = 1000 * 10**18; // 1000 bonus
    uint256 public constant REWARD_RETIRE = 100 * 10**18; // 100 for retiring
    
    // Pricing parameters
    uint256 public basePrice = 1 * 10**18; // 1 token base
    uint256 public co2PriceMultiplier = 1 * 10**14; // 0.0001 per gram
    uint256 public foodPriceMultiplier = 5 * 10**17; // 0.5 per packet
    
    // Auto-redemption
    uint256 public autoRedeemPeriod = 7 days;
    uint256 public autoRedeemDiscount = 80; // 80% of list price
    
    // Statistics
    uint256 public totalVolume;
    uint256 public totalSales;
    uint256 public totalRetired;
    
    // ============ Events ============
    
    event CertificateListed(
        uint256 indexed nftId,
        address indexed seller,
        uint256 price,
        uint256 co2Amount,
        uint256 foodQuantity
    );
    
    event CertificateSold(
        uint256 indexed nftId,
        address indexed seller,
        address indexed buyer,
        uint256 price,
        uint256 platformFee,
        uint256 buyerReward
    );
    
    event CertificateRetired(
        uint256 indexed nftId,
        address indexed owner,
        uint256 co2Amount,
        uint256 reward
    );
    
    event ListingCancelled(uint256 indexed nftId, address indexed seller);
    event PriceUpdated(uint256 indexed nftId, uint256 oldPrice, uint256 newPrice);
    event BuyerMilestoneReached(address indexed buyer, uint256 milestone, uint256 reward);
    event AutoRedeemed(uint256 indexed nftId, uint256 price);
    
    // ============ Modifiers ============
    
    modifier onlyNFTOwner(uint256 nftId) {
        require(impactNFT.ownerOf(nftId) == msg.sender, "Not NFT owner");
        _;
    }
    
    // ============ Constructor ============
    
    constructor(
        address _impactNFTAddress,
        address _tokenAddress,
        address _reputationAddress,
        address _treasuryAddress
    ) {
        require(_impactNFTAddress != address(0), "Invalid NFT address");
        require(_tokenAddress != address(0), "Invalid token address");
        require(_reputationAddress != address(0), "Invalid reputation address");
        require(_treasuryAddress != address(0), "Invalid treasury address");
        
        impactNFT = ImpactNFT(_impactNFTAddress);
        token = NoWasteToken(_tokenAddress);
        reputationSystem = ReputationSystem(_reputationAddress);
        treasuryAddress = _treasuryAddress;
    }
    
    // ============ Listing Functions ============
    
    /**
     * @dev List Impact NFT certificate for sale
     * @param nftId NFT token ID
     * @param price Sale price in tokens
     */
    function listCertificate(uint256 nftId, uint256 price) 
        external 
        onlyNFTOwner(nftId)
        nonReentrant 
    {
        require(price > 0, "Price must be > 0");
        require(!listings[nftId].active, "Already listed");
        
        // Get NFT data
        ImpactNFT.ImpactData memory data = impactNFT.getImpactData(nftId);
        
        // Transfer NFT to marketplace (escrow)
        impactNFT.transferFrom(msg.sender, address(this), nftId);
        
        // Create listing
        listings[nftId] = Listing({
            nftId: nftId,
            seller: msg.sender,
            price: price,
            listedAt: block.timestamp,
            active: true,
            co2Amount: data.co2Prevented,
            foodQuantity: data.foodQuantity
        });
        
        sellerListings[msg.sender].push(nftId);
        activeListings.push(nftId);
        
        emit CertificateListed(nftId, msg.sender, price, data.co2Prevented, data.foodQuantity);
    }
    
    /**
     * @dev Update listing price
     * @param nftId NFT token ID
     * @param newPrice New sale price
     */
    function updatePrice(uint256 nftId, uint256 newPrice) external nonReentrant {
        Listing storage listing = listings[nftId];
        require(listing.active, "Not listed");
        require(listing.seller == msg.sender, "Not seller");
        require(newPrice > 0, "Price must be > 0");
        
        uint256 oldPrice = listing.price;
        listing.price = newPrice;
        
        emit PriceUpdated(nftId, oldPrice, newPrice);
    }
    
    /**
     * @dev Cancel listing and return NFT to seller
     * @param nftId NFT token ID
     */
    function cancelListing(uint256 nftId) external nonReentrant {
        Listing storage listing = listings[nftId];
        require(listing.active, "Not listed");
        require(listing.seller == msg.sender, "Not seller");
        
        listing.active = false;
        
        // Return NFT to seller
        impactNFT.transferFrom(address(this), msg.sender, nftId);
        
        _removeFromActiveListings(nftId);
        
        emit ListingCancelled(nftId, msg.sender);
    }
    
    // ============ Purchase Functions ============
    
    /**
     * @dev Purchase certificate from marketplace
     * @param nftId NFT token ID
     */
    function buyCertificate(uint256 nftId) external nonReentrant {
        Listing storage listing = listings[nftId];
        require(listing.active, "Not listed");
        require(msg.sender != listing.seller, "Cannot buy own listing");
        
        uint256 price = listing.price;
        
        // Calculate fees and rewards
        uint256 platformFee = (price * platformFeePercent) / 100;
        uint256 treasuryFee = (price * treasuryFeePercent) / 100;
        uint256 buyerRewardAmount = (price * buyerRewardPercent) / 100;
        uint256 sellerAmount = price - platformFee;
        
        // Transfer tokens
        token.transferFrom(msg.sender, listing.seller, sellerAmount);
        token.transferFrom(msg.sender, treasuryAddress, treasuryFee);
        
        // Transfer NFT to buyer
        impactNFT.transferFrom(address(this), msg.sender, nftId);
        
        // Update stats
        listing.active = false;
        buyerPurchases[msg.sender].push(nftId);
        buyerStats[msg.sender].totalPurchased++;
        buyerStats[msg.sender].totalSpent += price;
        buyerStats[msg.sender].lastPurchaseTime = block.timestamp;
        
        totalVolume += price;
        totalSales++;
        
        _removeFromActiveListings(nftId);
        
        // Award buyer rewards
        uint256 totalReward = REWARD_PER_PURCHASE + buyerRewardAmount;
        _awardBuyerRewards(msg.sender, totalReward);
        
        // Check milestones
        _checkBuyerMilestones(msg.sender);
        
        emit CertificateSold(nftId, listing.seller, msg.sender, price, platformFee, totalReward);
    }
    
    /**
     * @dev Retire certificate permanently (burn for offset)
     * @param nftId NFT token ID
     */
    function retireCertificate(uint256 nftId) 
        external 
        onlyNFTOwner(nftId)
        nonReentrant 
    {
        ImpactNFT.ImpactData memory data = impactNFT.getImpactData(nftId);
        
        // Update stats
        buyerStats[msg.sender].totalRetired++;
        totalRetired++;
        
        // Transfer NFT to treasury (permanent retirement - cannot be resold)
        // Treasury holds retired certificates for verification
        impactNFT.transferFrom(msg.sender, treasuryAddress, nftId);
        
        // Award retirement reward
        token.transfer(msg.sender, REWARD_RETIRE);
        
        emit CertificateRetired(nftId, msg.sender, data.co2Prevented, REWARD_RETIRE);
    }
    
    // ============ Auto-Redemption Functions ============
    
    /**
     * @dev Auto-redeem certificate after listing period
     * @param nftId NFT token ID
     */
    function autoRedeemCertificate(uint256 nftId) external nonReentrant {
        Listing storage listing = listings[nftId];
        require(listing.active, "Not listed");
        require(
            block.timestamp >= listing.listedAt + autoRedeemPeriod,
            "Redemption period not reached"
        );
        
        uint256 redemptionPrice = (listing.price * autoRedeemDiscount) / 100;
        
        // Treasury buys at discounted price
        token.transferFrom(treasuryAddress, listing.seller, redemptionPrice);
        
        // Transfer NFT to treasury
        impactNFT.transferFrom(address(this), treasuryAddress, nftId);
        
        listing.active = false;
        totalSales++;
        totalVolume += redemptionPrice;
        
        _removeFromActiveListings(nftId);
        
        emit AutoRedeemed(nftId, redemptionPrice);
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Award rewards to buyer
     */
    function _awardBuyerRewards(address buyer, uint256 amount) internal {
        token.transfer(buyer, amount);
    }
    
    /**
     * @dev Check and award milestone bonuses
     */
    function _checkBuyerMilestones(address buyer) internal {
        uint256 purchases = buyerStats[buyer].totalPurchased;
        
        if (purchases == 5) {
            token.transfer(buyer, REWARD_5_PURCHASES);
            emit BuyerMilestoneReached(buyer, 5, REWARD_5_PURCHASES);
        } else if (purchases == 10) {
            token.transfer(buyer, REWARD_10_PURCHASES);
            emit BuyerMilestoneReached(buyer, 10, REWARD_10_PURCHASES);
        } else if (purchases % 10 == 0 && purchases > 10) {
            // Every 10 purchases after first milestone
            uint256 bonus = REWARD_10_PURCHASES;
            token.transfer(buyer, bonus);
            emit BuyerMilestoneReached(buyer, purchases, bonus);
        }
    }
    
    /**
     * @dev Remove from active listings array
     */
    function _removeFromActiveListings(uint256 nftId) internal {
        for (uint256 i = 0; i < activeListings.length; i++) {
            if (activeListings[i] == nftId) {
                activeListings[i] = activeListings[activeListings.length - 1];
                activeListings.pop();
                break;
            }
        }
    }
    
    // ============ Pricing Functions ============
    
    /**
     * @dev Calculate market price based on certificate attributes
     * @param nftId NFT token ID
     * @return Calculated market price
     */
    function calculateMarketPrice(uint256 nftId) public view returns (uint256) {
        ImpactNFT.ImpactData memory data = impactNFT.getImpactData(nftId);
        
        // Base calculation
        uint256 co2Value = data.co2Prevented * co2PriceMultiplier;
        uint256 foodValue = data.foodQuantity * foodPriceMultiplier;
        uint256 price = basePrice + co2Value + foodValue;
        
        // Apply reputation multiplier
        (uint256 restaurantRep,,,,,,) = reputationSystem.getUserReputation(data.restaurant);
        (uint256 ngoRep,,,,,,) = reputationSystem.getUserReputation(data.ngo);
        
        // Reputation multiplier (1.0x to 2.0x)
        uint256 repMultiplier = 100 + (restaurantRep / 10) + (ngoRep / 20);
        if (repMultiplier > 200) repMultiplier = 200; // Cap at 2.0x
        
        price = (price * repMultiplier) / 100;
        
        // Quantity multiplier for large donations (1.0x to 1.3x)
        if (data.foodQuantity >= 100) {
            price = (price * 130) / 100;
        } else if (data.foodQuantity >= 50) {
            price = (price * 115) / 100;
        }
        
        return price;
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get all active listings
     */
    function getActiveListings() external view returns (uint256[] memory) {
        return activeListings;
    }
    
    /**
     * @dev Get seller's listings
     */
    function getSellerListings(address seller) external view returns (uint256[] memory) {
        return sellerListings[seller];
    }
    
    /**
     * @dev Get buyer's purchases
     */
    function getBuyerPurchases(address buyer) external view returns (uint256[] memory) {
        return buyerPurchases[buyer];
    }
    
    /**
     * @dev Get buyer statistics
     */
    function getBuyerStats(address buyer) external view returns (BuyerStats memory) {
        return buyerStats[buyer];
    }
    
    /**
     * @dev Get listing details
     */
    function getListing(uint256 nftId) external view returns (Listing memory) {
        return listings[nftId];
    }
    
    /**
     * @dev Get marketplace statistics
     */
    function getMarketStats() external view returns (
        uint256 _totalVolume,
        uint256 _totalSales,
        uint256 _totalRetired,
        uint256 _activeListingsCount
    ) {
        return (totalVolume, totalSales, totalRetired, activeListings.length);
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Update platform fee percentage
     */
    function setPlatformFee(uint256 _feePercent) external onlyOwner {
        require(_feePercent <= 10, "Fee too high");
        platformFeePercent = _feePercent;
    }
    
    /**
     * @dev Update treasury address
     */
    function setTreasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasuryAddress = _treasury;
    }
    
    /**
     * @dev Update pricing parameters
     */
    function setPricingParams(
        uint256 _basePrice,
        uint256 _co2Multiplier,
        uint256 _foodMultiplier
    ) external onlyOwner {
        basePrice = _basePrice;
        co2PriceMultiplier = _co2Multiplier;
        foodPriceMultiplier = _foodMultiplier;
    }
    
    /**
     * @dev Update auto-redemption parameters
     */
    function setAutoRedeemParams(uint256 _period, uint256 _discount) external onlyOwner {
        require(_discount <= 100, "Invalid discount");
        autoRedeemPeriod = _period;
        autoRedeemDiscount = _discount;
    }
    
    /**
     * @dev Emergency withdraw tokens
     */
    function emergencyWithdraw(address _token, uint256 amount) external onlyOwner {
        NoWasteToken(_token).transfer(owner(), amount);
    }
}
