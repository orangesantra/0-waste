// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./ImpactNFT.sol";
import "./NoWasteToken.sol";

/**
 * @title CarbonCreditRegistry
 * @dev Manages carbon credit generation, tracking, and sales
 * Converts food waste prevention into verifiable carbon credits
 */
contract CarbonCreditRegistry is Ownable, ReentrancyGuard {
    
    // ============ Structs ============
    
    struct CarbonCredit {
        uint256 id;
        uint256 co2Amount;             // CO2 in grams
        uint256 certificateTokenId;    // Reference to Impact NFT
        address restaurant;
        uint256 createdAt;
        CreditStatus status;
        uint256 soldPrice;             // Price sold at (if sold)
        address buyer;                 // Who bought the credit
        string verificationHash;       // Third-party verification proof
    }
    
    enum CreditStatus {
        PENDING,        // Generated but not verified
        VERIFIED,       // Verified by third party
        LISTED,         // Listed for sale
        SOLD,           // Sold to buyer
        RETIRED         // Retired/used for offset
    }
    
    // ============ State Variables ============
    
    ImpactNFT public impactNFT;
    NoWasteToken public token;
    
    mapping(uint256 => CarbonCredit) public carbonCredits;
    mapping(uint256 => uint256) public certificateToCreditId; // NFT token ID to credit ID
    mapping(address => uint256[]) public restaurantCredits;
    
    uint256 public creditCounter;
    uint256 public totalCreditsGenerated;
    uint256 public totalCreditsSold;
    uint256 public totalRevenue;
    
    // Pricing (in tokens per gram of CO2)
    uint256 public pricePerGramCO2 = 30; // $0.03 per gram = $30 per ton
    
    // Revenue distribution
    address public treasuryAddress;
    uint256 public restaurantSharePercent = 30; // 30% to restaurant
    uint256 public treasurySharePercent = 70;   // 70% to treasury
    
    // Minimum CO2 for credit generation (1 ton = 1,000,000 grams)
    uint256 public MIN_CO2_FOR_CREDIT = 1000; // 1kg minimum
    
    // ============ Events ============
    
    event CarbonCreditGenerated(
        uint256 indexed creditId,
        uint256 co2Amount,
        uint256 indexed certificateTokenId,
        address indexed restaurant
    );
    event CreditVerified(uint256 indexed creditId, string verificationHash);
    event CreditListed(uint256 indexed creditId, uint256 price);
    event CreditSold(
        uint256 indexed creditId,
        address indexed buyer,
        uint256 price,
        uint256 restaurantShare,
        uint256 treasuryShare
    );
    event CreditRetired(uint256 indexed creditId, address indexed owner);
    event PriceUpdated(uint256 newPrice);
    event RevenueShareUpdated(uint256 restaurantShare, uint256 treasuryShare);
    
    // ============ Modifiers ============
    
    modifier creditExists(uint256 creditId) {
        require(creditId > 0 && creditId <= creditCounter, "Credit doesn't exist");
        _;
    }
    
    // ============ Constructor ============
    
    constructor(
        address _impactNFTAddress,
        address _tokenAddress,
        address _treasuryAddress
    ) Ownable(msg.sender) {
        require(_impactNFTAddress != address(0), "Invalid NFT address");
        require(_tokenAddress != address(0), "Invalid token address");
        require(_treasuryAddress != address(0), "Invalid treasury address");
        
        impactNFT = ImpactNFT(_impactNFTAddress);
        token = NoWasteToken(_tokenAddress);
        treasuryAddress = _treasuryAddress;
    }
    
    // ============ Credit Generation ============
    
    /**
     * @dev Generate carbon credit from Impact NFT
     * @param certificateTokenId Impact NFT token ID
     * @return creditId The generated credit ID
     */
    function generateCarbonCredit(uint256 certificateTokenId) 
        external 
        nonReentrant 
        returns (uint256) 
    {
        // Get impact data from NFT
        ImpactNFT.ImpactData memory impactData = impactNFT.getImpactData(certificateTokenId);
        
        require(impactData.co2Prevented >= MIN_CO2_FOR_CREDIT, "CO2 amount too small");
        require(
            certificateToCreditId[certificateTokenId] == 0,
            "Credit already generated"
        );
        require(
            impactNFT.ownerOf(certificateTokenId) == msg.sender,
            "Not certificate owner"
        );
        
        creditCounter++;
        uint256 creditId = creditCounter;
        
        carbonCredits[creditId] = CarbonCredit({
            id: creditId,
            co2Amount: impactData.co2Prevented,
            certificateTokenId: certificateTokenId,
            restaurant: impactData.restaurant,
            createdAt: block.timestamp,
            status: CreditStatus.PENDING,
            soldPrice: 0,
            buyer: address(0),
            verificationHash: ""
        });
        
        certificateToCreditId[certificateTokenId] = creditId;
        restaurantCredits[impactData.restaurant].push(creditId);
        totalCreditsGenerated++;
        
        emit CarbonCreditGenerated(
            creditId,
            impactData.co2Prevented,
            certificateTokenId,
            impactData.restaurant
        );
        
        return creditId;
    }
    
    /**
     * @dev Verify carbon credit (third-party verification)
     * @param creditId Credit ID
     * @param verificationHash IPFS hash of verification document
     */
    function verifyCredit(uint256 creditId, string memory verificationHash) 
        external 
        onlyOwner 
        creditExists(creditId) 
    {
        CarbonCredit storage credit = carbonCredits[creditId];
        
        require(credit.status == CreditStatus.PENDING, "Credit already verified");
        require(bytes(verificationHash).length > 0, "Invalid verification hash");
        
        credit.status = CreditStatus.VERIFIED;
        credit.verificationHash = verificationHash;
        
        emit CreditVerified(creditId, verificationHash);
    }
    
    /**
     * @dev List credit for sale
     * @param creditId Credit ID
     */
    function listCreditForSale(uint256 creditId) 
        external 
        creditExists(creditId) 
    {
        CarbonCredit storage credit = carbonCredits[creditId];
        
        require(credit.status == CreditStatus.VERIFIED, "Credit not verified");
        require(
            msg.sender == credit.restaurant || msg.sender == owner(),
            "Not authorized"
        );
        
        credit.status = CreditStatus.LISTED;
        
        uint256 price = calculateCreditPrice(credit.co2Amount);
        
        emit CreditListed(creditId, price);
    }
    
    /**
     * @dev Buy carbon credit
     * @param creditId Credit ID
     */
    function buyCarbonCredit(uint256 creditId) 
        external 
        nonReentrant 
        creditExists(creditId) 
    {
        CarbonCredit storage credit = carbonCredits[creditId];
        
        require(credit.status == CreditStatus.LISTED, "Credit not for sale");
        
        uint256 totalPrice = calculateCreditPrice(credit.co2Amount);
        
        // Calculate shares
        uint256 restaurantShare = (totalPrice * restaurantSharePercent) / 100;
        uint256 treasuryShare = (totalPrice * treasurySharePercent) / 100;
        
        // Transfer tokens from buyer
        require(
            token.transferFrom(msg.sender, credit.restaurant, restaurantShare),
            "Restaurant payment failed"
        );
        require(
            token.transferFrom(msg.sender, treasuryAddress, treasuryShare),
            "Treasury payment failed"
        );
        
        // Update credit
        credit.status = CreditStatus.SOLD;
        credit.soldPrice = totalPrice;
        credit.buyer = msg.sender;
        
        // Update statistics
        totalCreditsSold++;
        totalRevenue += totalPrice;
        
        emit CreditSold(
            creditId,
            msg.sender,
            totalPrice,
            restaurantShare,
            treasuryShare
        );
    }
    
    /**
     * @dev Retire carbon credit (use for offset)
     * @param creditId Credit ID
     */
    function retireCredit(uint256 creditId) 
        external 
        creditExists(creditId) 
    {
        CarbonCredit storage credit = carbonCredits[creditId];
        
        require(
            credit.buyer == msg.sender || msg.sender == owner(),
            "Not credit owner"
        );
        require(
            credit.status == CreditStatus.SOLD,
            "Credit not sold"
        );
        
        credit.status = CreditStatus.RETIRED;
        
        emit CreditRetired(creditId, msg.sender);
    }
    
    // ============ Calculation Functions ============
    
    /**
     * @dev Calculate price for carbon credit
     * @param co2Amount CO2 in grams
     * @return price Price in tokens
     */
    function calculateCreditPrice(uint256 co2Amount) 
        public 
        view 
        returns (uint256) 
    {
        // Price = co2Amount (grams) × price per gram
        return (co2Amount * pricePerGramCO2 * 10**18) / 1000;
    }
    
    /**
     * @dev Calculate potential revenue from certificate
     * @param certificateTokenId Impact NFT token ID
     * @return totalPrice Total price
     * @return restaurantShare Restaurant's share
     * @return treasuryShare Treasury's share
     */
    function calculatePotentialRevenue(uint256 certificateTokenId) 
        external 
        view 
        returns (
            uint256 totalPrice,
            uint256 restaurantShare,
            uint256 treasuryShare
        ) 
    {
        ImpactNFT.ImpactData memory impactData = impactNFT.getImpactData(certificateTokenId);
        
        totalPrice = calculateCreditPrice(impactData.co2Prevented);
        restaurantShare = (totalPrice * restaurantSharePercent) / 100;
        treasuryShare = (totalPrice * treasurySharePercent) / 100;
        
        return (totalPrice, restaurantShare, treasuryShare);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get carbon credit details
     */
    function getCarbonCredit(uint256 creditId) 
        external 
        view 
        creditExists(creditId) 
        returns (CarbonCredit memory) 
    {
        return carbonCredits[creditId];
    }
    
    /**
     * @dev Get all credits for a restaurant
     */
    function getRestaurantCredits(address restaurant) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return restaurantCredits[restaurant];
    }
    
    /**
     * @dev Get restaurant's total carbon impact
     */
    function getRestaurantCarbonImpact(address restaurant) 
        external 
        view 
        returns (
            uint256 totalCredits,
            uint256 totalCO2,
            uint256 totalEarned,
            uint256 pendingRevenue
        ) 
    {
        uint256[] memory credits = restaurantCredits[restaurant];
        totalCredits = credits.length;
        
        for (uint256 i = 0; i < credits.length; i++) {
            CarbonCredit memory credit = carbonCredits[credits[i]];
            totalCO2 += credit.co2Amount;
            
            if (credit.status == CreditStatus.SOLD) {
                uint256 share = (credit.soldPrice * restaurantSharePercent) / 100;
                totalEarned += share;
            } else if (credit.status == CreditStatus.LISTED || credit.status == CreditStatus.VERIFIED) {
                uint256 potentialPrice = calculateCreditPrice(credit.co2Amount);
                uint256 share = (potentialPrice * restaurantSharePercent) / 100;
                pendingRevenue += share;
            }
        }
        
        return (totalCredits, totalCO2, totalEarned, pendingRevenue);
    }
    
    /**
     * @dev Get global carbon credit statistics
     */
    function getGlobalStats() 
        external 
        view 
        returns (
            uint256 creditsGenerated,
            uint256 creditsSold,
            uint256 revenue,
            uint256 totalCO2Offset
        ) 
    {
        uint256 co2Offset = 0;
        
        for (uint256 i = 1; i <= creditCounter; i++) {
            if (carbonCredits[i].status == CreditStatus.RETIRED) {
                co2Offset += carbonCredits[i].co2Amount;
            }
        }
        
        return (
            totalCreditsGenerated,
            totalCreditsSold,
            totalRevenue,
            co2Offset
        );
    }
    
    /**
     * @dev Get credits by status
     */
    function getCreditsByStatus(CreditStatus status) 
        external 
        view 
        returns (uint256[] memory) 
    {
        // First, count credits with this status
        uint256 count = 0;
        for (uint256 i = 1; i <= creditCounter; i++) {
            if (carbonCredits[i].status == status) {
                count++;
            }
        }
        
        // Create array and populate
        uint256[] memory result = new uint256[](count);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= creditCounter; i++) {
            if (carbonCredits[i].status == status) {
                result[index] = i;
                index++;
            }
        }
        
        return result;
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Update price per gram of CO2
     */
    function updatePrice(uint256 newPrice) external onlyOwner {
        require(newPrice > 0, "Price must be > 0");
        pricePerGramCO2 = newPrice;
        emit PriceUpdated(newPrice);
    }
    
    /**
     * @dev Update revenue sharing percentages
     */
    function updateRevenueShare(
        uint256 _restaurantShare,
        uint256 _treasuryShare
    ) external onlyOwner {
        require(
            _restaurantShare + _treasuryShare == 100,
            "Shares must total 100"
        );
        
        restaurantSharePercent = _restaurantShare;
        treasurySharePercent = _treasuryShare;
        
        emit RevenueShareUpdated(_restaurantShare, _treasuryShare);
    }
    
    /**
     * @dev Update treasury address
     */
    function setTreasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasuryAddress = _treasury;
    }
    
    /**
     * @dev Update minimum CO2 for credit generation
     */
    function setMinimumCO2(uint256 _minCO2) external onlyOwner {
        require(_minCO2 > 0, "Minimum must be > 0");
        MIN_CO2_FOR_CREDIT = _minCO2;
    }
    
    /**
     * @dev Batch verify credits
     */
    function batchVerifyCredits(
        uint256[] memory creditIds,
        string[] memory verificationHashes
    ) external onlyOwner {
        require(
            creditIds.length == verificationHashes.length,
            "Array length mismatch"
        );
        
        for (uint256 i = 0; i < creditIds.length; i++) {
            if (carbonCredits[creditIds[i]].status == CreditStatus.PENDING) {
                carbonCredits[creditIds[i]].status = CreditStatus.VERIFIED;
                carbonCredits[creditIds[i]].verificationHash = verificationHashes[i];
                emit CreditVerified(creditIds[i], verificationHashes[i]);
            }
        }
    }
    
    /**
     * @dev Batch list credits for sale
     */
    function batchListCredits(uint256[] memory creditIds) external onlyOwner {
        for (uint256 i = 0; i < creditIds.length; i++) {
            if (carbonCredits[creditIds[i]].status == CreditStatus.VERIFIED) {
                carbonCredits[creditIds[i]].status = CreditStatus.LISTED;
                uint256 price = calculateCreditPrice(carbonCredits[creditIds[i]].co2Amount);
                emit CreditListed(creditIds[i], price);
            }
        }
    }
}
