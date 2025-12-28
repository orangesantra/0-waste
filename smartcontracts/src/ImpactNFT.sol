// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NoWasteToken.sol";

/**
 * @title ImpactNFT
 * @dev ERC-721 NFT representing food donation impact certificates
 * Each NFT serves as proof of donation for tax purposes and ESG reporting
 */
contract ImpactNFT is ERC721, Ownable {
    
    // ============ Structs ============
    
    struct ImpactData {
        address restaurant;
        address ngo;
        uint256 foodQuantity;          // Number of food packets
        uint256 marketValue;           // Market value in tokens
        uint256 co2Prevented;          // CO2 prevented in grams
        string foodType;               // "Veg" or "Non-Veg"
        uint256 timestamp;             // When donation completed
        string ipfsHash;               // Metadata on IPFS
        uint256 donationId;            // Reference to donation
        bool verified;                 // Third-party verification status
    }
    
    // ============ Constants ============
    
    // CO2 prevented per kg of food waste (2.5kg CO2 per 1kg food)
    uint256 public constant CO2_PER_KG_FOOD = 2500; // in grams
    uint256 public constant AVG_PACKET_WEIGHT = 500; // 0.5kg per packet in grams
    
    // Token burn required to mint NFT
    uint256 public BURN_AMOUNT = 100 * 10**18; // 100 tokens
    
    // ============ State Variables ============
    
    uint256 private _tokenIdCounter;
    
    NoWasteToken public token;
    address public donationManagerAddress;
    
    mapping(uint256 => ImpactData) public impactData;
    mapping(address => uint256[]) public restaurantCertificates;
    mapping(uint256 => bool) public donationHasCertificate;
    
    // Global impact tracking
    uint256 public totalFoodQuantity;
    uint256 public totalCO2Prevented;
    uint256 public totalMarketValue;
    
    // Base URI for metadata
    string private _baseTokenURI;
    
    // ============ Events ============
    
    event ImpactCertificateMinted(
        uint256 indexed tokenId,
        address indexed restaurant,
        address indexed ngo,
        uint256 co2Prevented,
        uint256 donationId
    );
    event MetadataUpdated(uint256 indexed tokenId, string ipfsHash);
    event CertificateVerified(uint256 indexed tokenId, address verifier);
    event BurnAmountUpdated(uint256 newAmount);
    
    // ============ Modifiers ============
    
    modifier onlyDonationManager() {
        require(
            msg.sender == donationManagerAddress || msg.sender == owner(),
            "Only DonationManager can call"
        );
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _tokenAddress) 
        ERC721("NoWaste Impact Certificate", "NWIC")
    {
        require(_tokenAddress != address(0), "Invalid token address");
        token = NoWasteToken(_tokenAddress);
        _baseTokenURI = "ipfs://";
    }
    
    // ============ Minting Functions ============
    
    /**
     * @dev Mint impact certificate for completed donation
     * @param restaurant Restaurant address
     * @param ngo NGO address
     * @param quantity Number of food packets
     * @param marketValue Market value in tokens
     * @param foodType "Veg" or "Non-Veg"
     * @param donationId Reference to donation
     * @return tokenId The minted NFT token ID
     */
    function mintImpactCertificate(
        address restaurant,
        address ngo,
        uint256 quantity,
        uint256 marketValue,
        string memory foodType,
        uint256 donationId
    ) external onlyDonationManager returns (uint256) {
        
        require(!donationHasCertificate[donationId], "Certificate already minted");
        require(restaurant != address(0), "Invalid restaurant");
        require(ngo != address(0), "Invalid NGO");
        require(quantity > 0, "Quantity must be > 0");
        
        // Burn tokens from restaurant (or from this contract if pre-funded)
        // Note: In production, tokens should be transferred to this contract first
        // token.burn(BURN_AMOUNT);
        
        uint256 newTokenId = ++_tokenIdCounter;
        
        // Calculate CO2 prevented
        // Formula: packets × weight_per_packet × co2_per_kg / 1000
        uint256 co2Prevented = (quantity * AVG_PACKET_WEIGHT * CO2_PER_KG_FOOD) / 1000;
        
        // Store impact data
        impactData[newTokenId] = ImpactData({
            restaurant: restaurant,
            ngo: ngo,
            foodQuantity: quantity,
            marketValue: marketValue,
            co2Prevented: co2Prevented,
            foodType: foodType,
            timestamp: block.timestamp,
            ipfsHash: "",
            donationId: donationId,
            verified: false
        });
        
        // Update global statistics
        totalFoodQuantity += quantity;
        totalCO2Prevented += co2Prevented;
        totalMarketValue += marketValue;
        
        // Track certificate
        restaurantCertificates[restaurant].push(newTokenId);
        donationHasCertificate[donationId] = true;
        
        // Mint NFT to restaurant
        _safeMint(restaurant, newTokenId);
        
        emit ImpactCertificateMinted(
            newTokenId,
            restaurant,
            ngo,
            co2Prevented,
            donationId
        );
        
        return newTokenId;
    }
    
    /**
     * @dev Set IPFS metadata hash for certificate
     * @param tokenId NFT token ID
     * @param ipfsHash IPFS hash of metadata
     */
    function setMetadataHash(uint256 tokenId, string memory ipfsHash) 
        external 
        onlyDonationManager 
    {
        require(_ownerOf(tokenId) != address(0), "Token doesn't exist");
        require(bytes(ipfsHash).length > 0, "Invalid IPFS hash");
        
        impactData[tokenId].ipfsHash = ipfsHash;
        
        emit MetadataUpdated(tokenId, ipfsHash);
    }
    
    /**
     * @dev Verify certificate by third party
     * @param tokenId NFT token ID
     */
    function verifyCertificate(uint256 tokenId) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Token doesn't exist");
        require(!impactData[tokenId].verified, "Already verified");
        
        impactData[tokenId].verified = true;
        
        emit CertificateVerified(tokenId, msg.sender);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get impact data for a certificate
     */
    function getImpactData(uint256 tokenId) 
        external 
        view 
        returns (ImpactData memory) 
    {
        require(_ownerOf(tokenId) != address(0), "Token doesn't exist");
        return impactData[tokenId];
    }
    
    /**
     * @dev Get all certificates for a restaurant
     */
    function getRestaurantCertificates(address restaurant) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return restaurantCertificates[restaurant];
    }
    
    /**
     * @dev Get total impact across all certificates
     */
    function getTotalImpact() 
        external 
        view 
        returns (
            uint256 certificates,
            uint256 foodQuantity,
            uint256 co2Prevented,
            uint256 marketValue
        ) 
    {
        return (
            _tokenIdCounter,
            totalFoodQuantity,
            totalCO2Prevented,
            totalMarketValue
        );
    }
    
    /**
     * @dev Get restaurant's total impact
     */
    function getRestaurantImpact(address restaurant) 
        external 
        view 
        returns (
            uint256 certificates,
            uint256 foodQuantity,
            uint256 co2Prevented,
            uint256 marketValue
        ) 
    {
        uint256[] memory certs = restaurantCertificates[restaurant];
        certificates = certs.length;
        
        for (uint256 i = 0; i < certs.length; i++) {
            ImpactData memory data = impactData[certs[i]];
            foodQuantity += data.foodQuantity;
            co2Prevented += data.co2Prevented;
            marketValue += data.marketValue;
        }
        
        return (certificates, foodQuantity, co2Prevented, marketValue);
    }
    
    /**
     * @dev Check if donation has certificate
     */
    function hasCertificate(uint256 donationId) external view returns (bool) {
        return donationHasCertificate[donationId];
    }
    
    /**
     * @dev Get token URI
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "Token doesn't exist");
        
        string memory ipfsHash = impactData[tokenId].ipfsHash;
        
        if (bytes(ipfsHash).length > 0) {
            return string(abi.encodePacked(_baseTokenURI, ipfsHash));
        }
        
        return "";
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Set donation manager address
     */
    function setDonationManager(address _donationManager) external onlyOwner {
        require(_donationManager != address(0), "Invalid address");
        donationManagerAddress = _donationManager;
    }
    
    /**
     * @dev Update burn amount required for minting
     */
    function setBurnAmount(uint256 _burnAmount) external onlyOwner {
        BURN_AMOUNT = _burnAmount;
        emit BurnAmountUpdated(_burnAmount);
    }
    
    /**
     * @dev Set base URI for metadata
     */
    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    /**
     * @dev Get current token ID counter
     */
    function getCurrentTokenId() external view returns (uint256) {
        return _tokenIdCounter;
    }
    
    // ============ Required Overrides ============
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
