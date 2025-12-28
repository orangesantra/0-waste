// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NoWasteToken.sol";
import "./CertificateMarketplace.sol";

/**
 * @title CarbonSubscription
 * @dev Subscription service for automatic carbon offsetting via certificate purchases
 * Users set monthly budget and system auto-purchases certificates on their behalf
 */
contract CarbonSubscription is Ownable, ReentrancyGuard {
    
    // ============ Structs ============
    
    struct Subscription {
        uint256 monthlyBudget;
        uint256 startTime;
        uint256 lastProcessedTime;
        uint256 totalSpent;
        uint256 totalCertificates;
        bool active;
        uint8 tier; // 0=Basic, 1=Standard, 2=Premium
    }
    
    // ============ State Variables ============
    
    NoWasteToken public token;
    CertificateMarketplace public marketplace;
    
    mapping(address => Subscription) public subscriptions;
    address[] public subscribers;
    
    // Subscription tiers
    uint256 public constant BASIC_TIER = 50 * 10**18; // 50 tokens/month
    uint256 public constant STANDARD_TIER = 200 * 10**18; // 200 tokens/month
    uint256 public constant PREMIUM_TIER = 500 * 10**18; // 500 tokens/month
    
    // Discount rates
    uint256 public basicDiscount = 0; // 0%
    uint256 public standardDiscount = 10; // 10%
    uint256 public premiumDiscount = 20; // 20%
    
    // Processing parameters
    uint256 public constant MONTH = 30 days;
    uint256 public processingFee = 2; // 2% processing fee
    
    // Statistics
    uint256 public totalSubscribers;
    uint256 public totalActiveSubscribers;
    uint256 public totalVolumeProcessed;
    uint256 public totalCertificatesPurchased;
    
    // ============ Events ============
    
    event SubscriptionCreated(
        address indexed subscriber,
        uint256 monthlyBudget,
        uint8 tier
    );
    
    event SubscriptionUpdated(
        address indexed subscriber,
        uint256 oldBudget,
        uint256 newBudget,
        uint8 newTier
    );
    
    event SubscriptionCancelled(address indexed subscriber);
    
    event SubscriptionProcessed(
        address indexed subscriber,
        uint256 amount,
        uint256 certificatesPurchased,
        uint256 period
    );
    
    event AutoPurchaseExecuted(
        address indexed subscriber,
        uint256 nftId,
        uint256 price
    );
    
    // ============ Constructor ============
    
    constructor(address _tokenAddress, address _marketplaceAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_marketplaceAddress != address(0), "Invalid marketplace address");
        
        token = NoWasteToken(_tokenAddress);
        marketplace = CertificateMarketplace(_marketplaceAddress);
    }
    
    // ============ Subscription Management ============
    
    /**
     * @dev Create new subscription
     * @param monthlyBudget Monthly budget in tokens
     */
    function subscribe(uint256 monthlyBudget) external nonReentrant {
        require(monthlyBudget >= BASIC_TIER, "Budget too low");
        require(!subscriptions[msg.sender].active, "Already subscribed");
        
        uint8 tier = _determineTier(monthlyBudget);
        
        subscriptions[msg.sender] = Subscription({
            monthlyBudget: monthlyBudget,
            startTime: block.timestamp,
            lastProcessedTime: block.timestamp,
            totalSpent: 0,
            totalCertificates: 0,
            active: true,
            tier: tier
        });
        
        subscribers.push(msg.sender);
        totalSubscribers++;
        totalActiveSubscribers++;
        
        // Update marketplace buyer stats
        CertificateMarketplace.BuyerStats memory stats = marketplace.getBuyerStats(msg.sender);
        // Note: Need to add setSubscription function to marketplace
        
        emit SubscriptionCreated(msg.sender, monthlyBudget, tier);
    }
    
    /**
     * @dev Update subscription budget
     * @param newBudget New monthly budget
     */
    function updateSubscription(uint256 newBudget) external nonReentrant {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.active, "Not subscribed");
        require(newBudget >= BASIC_TIER, "Budget too low");
        
        uint256 oldBudget = sub.monthlyBudget;
        uint8 newTier = _determineTier(newBudget);
        
        sub.monthlyBudget = newBudget;
        sub.tier = newTier;
        
        emit SubscriptionUpdated(msg.sender, oldBudget, newBudget, newTier);
    }
    
    /**
     * @dev Cancel subscription
     */
    function cancelSubscription() external nonReentrant {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.active, "Not subscribed");
        
        sub.active = false;
        totalActiveSubscribers--;
        
        emit SubscriptionCancelled(msg.sender);
    }
    
    // ============ Processing Functions ============
    
    /**
     * @dev Process subscription for current period
     * Can be called by anyone (automation-friendly)
     */
    function processSubscription(address subscriber) external nonReentrant {
        Subscription storage sub = subscriptions[subscriber];
        require(sub.active, "Not active");
        require(
            block.timestamp >= sub.lastProcessedTime + MONTH,
            "Already processed this month"
        );
        
        // Calculate budget with discount
        uint256 budget = _calculateDiscountedBudget(sub.monthlyBudget, sub.tier);
        uint256 fee = (budget * processingFee) / 100;
        uint256 purchaseBudget = budget - fee;
        
        // Get active listings sorted by best value
        uint256[] memory listings = marketplace.getActiveListings();
        require(listings.length > 0, "No listings available");
        
        // Auto-purchase certificates within budget
        uint256 spent = 0;
        uint256 purchased = 0;
        
        for (uint256 i = 0; i < listings.length && spent < purchaseBudget; i++) {
            CertificateMarketplace.Listing memory listing = marketplace.getListing(listings[i]);
            
            if (listing.active && spent + listing.price <= purchaseBudget) {
                // Approve and purchase
                token.approve(address(marketplace), listing.price);
                
                try marketplace.buyCertificate(listings[i]) {
                    spent += listing.price;
                    purchased++;
                    
                    emit AutoPurchaseExecuted(subscriber, listings[i], listing.price);
                } catch {
                    // Skip if purchase fails
                    continue;
                }
            }
        }
        
        require(purchased > 0, "No certificates purchased");
        
        // Update subscription
        sub.lastProcessedTime = block.timestamp;
        sub.totalSpent += spent;
        sub.totalCertificates += purchased;
        
        // Update global stats
        totalVolumeProcessed += spent;
        totalCertificatesPurchased += purchased;
        
        emit SubscriptionProcessed(subscriber, spent, purchased, block.timestamp);
    }
    
    /**
     * Batch process multiple subscriptions
     * @param subscriberAddresses List of subscriber addresses to process
     */
    function batchProcessSubscriptions(address[] memory subscriberAddresses) 
        external 
        nonReentrant 
    {
        for (uint256 i = 0; i < subscriberAddresses.length; i++) {
            Subscription storage sub = subscriptions[subscriberAddresses[i]];
            
            if (sub.active && block.timestamp >= sub.lastProcessedTime + MONTH) {
                try this.processSubscription(subscriberAddresses[i]) {
                    // Success
                } catch {
                    // Skip failures
                    continue;
                }
            }
        }
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Determine tier based on budget
     */
    function _determineTier(uint256 budget) internal pure returns (uint8) {
        if (budget >= PREMIUM_TIER) {
            return 2; // Premium
        } else if (budget >= STANDARD_TIER) {
            return 1; // Standard
        } else {
            return 0; // Basic
        }
    }
    
    /**
     * @dev Calculate budget with tier discount
     */
    function _calculateDiscountedBudget(uint256 budget, uint8 tier) 
        internal 
        view 
        returns (uint256) 
    {
        uint256 discount;
        
        if (tier == 2) {
            discount = premiumDiscount;
        } else if (tier == 1) {
            discount = standardDiscount;
        } else {
            discount = basicDiscount;
        }
        
        uint256 discountAmount = (budget * discount) / 100;
        return budget + discountAmount; // Get more purchasing power
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get subscription details
     */
    function getSubscription(address subscriber) 
        external 
        view 
        returns (Subscription memory) 
    {
        return subscriptions[subscriber];
    }
    
    /**
     * @dev Check if due for processing
     */
    function isDueForProcessing(address subscriber) external view returns (bool) {
        Subscription memory sub = subscriptions[subscriber];
        return sub.active && block.timestamp >= sub.lastProcessedTime + MONTH;
    }
    
    /**
     * @dev Get all subscribers due for processing
     */
    function getDueSubscribers() external view returns (address[] memory) {
        uint256 count = 0;
        
        // Count due subscribers
        for (uint256 i = 0; i < subscribers.length; i++) {
            Subscription memory sub = subscriptions[subscribers[i]];
            if (sub.active && block.timestamp >= sub.lastProcessedTime + MONTH) {
                count++;
            }
        }
        
        // Build array
        address[] memory dueList = new address[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < subscribers.length; i++) {
            Subscription memory sub = subscriptions[subscribers[i]];
            if (sub.active && block.timestamp >= sub.lastProcessedTime + MONTH) {
                dueList[index] = subscribers[i];
                index++;
            }
        }
        
        return dueList;
    }
    
    /**
     * @dev Get subscription statistics
     */
    function getStats() 
        external 
        view 
        returns (
            uint256 _totalSubscribers,
            uint256 _activeSubscribers,
            uint256 _totalVolume,
            uint256 _totalCertificates
        ) 
    {
        return (
            totalSubscribers,
            totalActiveSubscribers,
            totalVolumeProcessed,
            totalCertificatesPurchased
        );
    }
    
    /**
     * @dev Get tier info
     */
    function getTierInfo(uint8 tier) 
        external 
        pure 
        returns (
            string memory name,
            uint256 minBudget,
            uint256 discount
        ) 
    {
        if (tier == 2) {
            return ("Premium", PREMIUM_TIER, 20);
        } else if (tier == 1) {
            return ("Standard", STANDARD_TIER, 10);
        } else {
            return ("Basic", BASIC_TIER, 0);
        }
    }
    
    /**
     * @dev Calculate effective budget with discount
     */
    function calculateEffectiveBudget(uint256 budget) 
        external 
        view 
        returns (uint256) 
    {
        uint8 tier = _determineTier(budget);
        return _calculateDiscountedBudget(budget, tier);
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Update tier discounts
     */
    function setDiscounts(
        uint256 _basicDiscount,
        uint256 _standardDiscount,
        uint256 _premiumDiscount
    ) external onlyOwner {
        require(_basicDiscount <= 25, "Discount too high");
        require(_standardDiscount <= 25, "Discount too high");
        require(_premiumDiscount <= 25, "Discount too high");
        
        basicDiscount = _basicDiscount;
        standardDiscount = _standardDiscount;
        premiumDiscount = _premiumDiscount;
    }
    
    /**
     * @dev Update processing fee
     */
    function setProcessingFee(uint256 _fee) external onlyOwner {
        require(_fee <= 5, "Fee too high");
        processingFee = _fee;
    }
    
    /**
     * @dev Update marketplace address
     */
    function setMarketplace(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "Invalid address");
        marketplace = CertificateMarketplace(_marketplaceAddress);
    }
    
    /**
     * @dev Get all subscribers
     */
    function getAllSubscribers() external view returns (address[] memory) {
        return subscribers;
    }
}
