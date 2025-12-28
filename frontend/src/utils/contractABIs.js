// Simplified ABIs for frontend interaction
// Full ABIs will be imported from contract artifacts after deployment

export const NoWasteTokenABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)",
  "function approve(address spender, uint256 amount) returns (bool)",
  "function allowance(address owner, address spender) view returns (uint256)",
  "function stake(uint256 amount) external",
  "function unstake(uint256 amount) external",
  "function stakedBalance(address user) view returns (uint256)",
  "function totalSupply() view returns (uint256)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)",
  "function name() view returns (string)"
];

export const DonationManagerABI = [
  "function createDonation(string memory foodType, uint256 quantity, uint256 marketValue, uint256 pickupTimeStart, uint256 pickupTimeEnd, string memory location, string memory photoHash) external returns (uint256)",
  "function claimDonation(uint256 donationId) external",
  "function acceptDelivery(uint256 donationId) external",
  "function confirmPickup(uint256 donationId) external",
  "function confirmDelivery(uint256 donationId, string memory deliveryPhotoHash) external",
  "function confirmReceipt(uint256 donationId) external",
  "function getDonation(uint256 donationId) view returns (tuple(uint256 id, address restaurant, string foodType, uint256 quantity, uint256 marketValue, uint256 pickupTimeStart, uint256 pickupTimeEnd, string location, address ngo, address courier, uint8 status, uint256 createdAt, uint256 claimedAt, uint256 completedAt, string photoHash))",
  "function getRestaurantDonations(address restaurant) view returns (uint256[])",
  "function getNGODonations(address ngo) view returns (uint256[])",
  "function getCourierDeliveries(address courier) view returns (uint256[])",
  "function cancelDonation(uint256 donationId) external",
  "function donationCounter() view returns (uint256)",
  "function RESTAURANT_STAKE() view returns (uint256)",
  "function NGO_STAKE() view returns (uint256)",
  "function COURIER_STAKE() view returns (uint256)",
  "event DonationCreated(uint256 indexed donationId, address indexed restaurant, string foodType, uint256 quantity)",
  "event DonationClaimed(uint256 indexed donationId, address indexed ngo)",
  "event CourierAssigned(uint256 indexed donationId, address indexed courier)",
  "event DonationPickedUp(uint256 indexed donationId)",
  "event DonationDelivered(uint256 indexed donationId)",
  "event DonationCompleted(uint256 indexed donationId)"
];

export const ReputationSystemABI = [
  "function getUserReputation(address user) view returns (tuple(uint256 score, uint256 totalDonations, uint256 successfulDonations, uint256 cancelledDonations, uint256 totalDisputes, uint256 disputesLost, uint256 lastUpdated, uint256 consecutiveSuccesses, uint256 maxStreak, bool initialized))",
  "function getReputationScore(address user) view returns (uint256)",
  "function getReputationMultiplier(address user) view returns (uint256)",
  "function getTier(address user) view returns (uint8)",
  "function canStakeReduction(address user) view returns (uint256)",
  "function MAX_SCORE() view returns (uint256)",
  "event ReputationUpdated(address indexed user, uint256 newScore, uint8 tier)",
  "event MilestoneAchieved(address indexed user, string milestone, uint256 bonus)"
];

export const ImpactNFTABI = [
  "function mintImpactCertificate(address restaurant, address ngo, uint256 foodQuantity, uint256 marketValue, string memory foodType, uint256 donationId, string memory ipfsHash) external returns (uint256)",
  "function tokenURI(uint256 tokenId) view returns (string)",
  "function balanceOf(address owner) view returns (uint256)",
  "function ownerOf(uint256 tokenId) view returns (address)",
  "function approve(address to, uint256 tokenId) external",
  "function setApprovalForAll(address operator, bool approved) external",
  "function getApproved(uint256 tokenId) view returns (address)",
  "function isApprovedForAll(address owner, address operator) view returns (bool)",
  "function transferFrom(address from, address to, uint256 tokenId) external",
  "function safeTransferFrom(address from, address to, uint256 tokenId) external",
  "function getUserNFTs(address user) view returns (uint256[])",
  "function getRestaurantCertificates(address restaurant) view returns (uint256[])",
  "function getImpactData(uint256 tokenId) view returns (tuple(address restaurant, address ngo, uint256 foodQuantity, uint256 marketValue, uint256 co2Prevented, string foodType, uint256 timestamp, string ipfsHash, uint256 donationId, bool verified))",
  "function getTotalCO2Prevented(address user) view returns (uint256)",
  "function BURN_AMOUNT() view returns (uint256)",
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "event ImpactNFTMinted(uint256 indexed tokenId, address indexed restaurant, address indexed ngo, uint256 co2Prevented)",
  "event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)",
  "event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)",
  "event ApprovalForAll(address indexed owner, address indexed operator, bool approved)"
];

export const CarbonCreditRegistryABI = [
  "function generateCarbonCredit(uint256 certificateTokenId) external returns (uint256)",
  "function listCreditForSale(uint256 creditId, uint256 pricePerCredit) external",
  "function buyCarbonCredit(uint256 creditId, uint256 amount) external",
  "function retireCredit(uint256 creditId, uint256 amount, string memory retirementReason) external",
  "function getCredit(uint256 creditId) view returns (tuple(uint256 id, address owner, uint256 certificateTokenId, uint256 co2Amount, uint256 pricePerCredit, bool isListed, bool isRetired, uint256 createdAt))",
  "function getUserCredits(address user) view returns (uint256[])",
  "function getListedCredits() view returns (uint256[])",
  "function getTotalCO2Prevented() view returns (uint256)",
  "event CarbonCreditGenerated(uint256 indexed creditId, address indexed owner, uint256 co2Amount)",
  "event CreditListed(uint256 indexed creditId, uint256 pricePerCredit)",
  "event CreditSold(uint256 indexed creditId, address indexed buyer, uint256 amount)",
  "event CreditRetired(uint256 indexed creditId, uint256 amount, string reason)"
];

export const DAOGovernanceABI = [
  "function createProposal(uint8 proposalType, string memory title, string memory description, address[] memory targets, bytes[] memory calldatas) external returns (uint256)",
  "function vote(uint256 proposalId, bool support) external",
  "function executeProposal(uint256 proposalId) external",
  "function cancelProposal(uint256 proposalId) external",
  "function getProposal(uint256 proposalId) view returns (tuple(uint256 id, address proposer, uint8 proposalType, string title, string description, uint256 forVotes, uint256 againstVotes, uint256 startTime, uint256 endTime, bool executed, bool cancelled, uint8 status))",
  "function getActiveProposals() view returns (uint256[])",
  "function hasVoted(uint256 proposalId, address voter) view returns (bool)",
  "function getVotingPower(address voter) view returns (uint256)",
  "function proposalThreshold() view returns (uint256)",
  "function votingPeriod() view returns (uint256)",
  "function executionDelay() view returns (uint256)",
  "event ProposalCreated(uint256 indexed proposalId, address indexed proposer, uint8 proposalType, string title)",
  "event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight)",
  "event ProposalExecuted(uint256 indexed proposalId)",
  "event ProposalCancelled(uint256 indexed proposalId)"
];

export const TokenFaucetABI = [
  "function claimTokens() external",
  "function canClaim(address user) view returns (bool)",
  "function timeUntilNextClaim(address user) view returns (uint256)",
  "function getFaucetStats() view returns (uint256 balance, uint256 distributed, uint256 remaining, bool active)",
  "function CLAIM_AMOUNT() view returns (uint256)",
  "function CLAIM_COOLDOWN() view returns (uint256)",
  "function lastClaimTime(address user) view returns (uint256)",
  "function totalClaimed(address user) view returns (uint256)",
  "event TokensClaimed(address indexed user, uint256 amount)"
];

export const CertificateMarketplaceABI = [
  "function listCertificate(uint256 nftId, uint256 price) external",
  "function buyCertificate(uint256 nftId) external",
  "function cancelListing(uint256 nftId) external",
  "function retireCertificate(uint256 nftId) external",
  "function calculateMarketPrice(uint256 nftId) view returns (uint256)",
  "function getListing(uint256 nftId) view returns (tuple(uint256 nftId, address seller, uint256 price, uint256 listedAt, bool active, uint256 co2Amount, uint256 foodQuantity))",
  "function getActiveListings() view returns (uint256[])",
  "function getSellerListings(address seller) view returns (uint256[])",
  "function getBuyerPurchases(address buyer) view returns (uint256[])",
  "function getBuyerStats(address buyer) view returns (tuple(uint256 totalPurchased, uint256 totalRetired, uint256 totalSpent, uint256 lastPurchaseTime, bool hasSubscription))",
  "function totalListed() view returns (uint256)",
  "function totalSales() view returns (uint256)",
  "function totalRetired() view returns (uint256)",
  "function platformFeePercent() view returns (uint256)",
  "function basePrice() view returns (uint256)",
  "event CertificateListed(uint256 indexed nftId, address indexed seller, uint256 price)",
  "event CertificateSold(uint256 indexed nftId, address indexed buyer, address indexed seller, uint256 price)",
  "event CertificateRetired(uint256 indexed nftId, address indexed owner, uint256 co2Amount)",
  "event ListingCancelled(uint256 indexed nftId, address indexed seller)"
];

export const CertificateTreasuryABI = [
  "function deposit(uint256 amount) external",
  "function withdraw(uint256 amount) external",
  "function claimRewards() external",
  "function executeAutoRedemption(uint256 nftId, uint256 price) external returns (bool)",
  "function calculatePendingRewards(address depositor) view returns (uint256)",
  "function getDepositorInfo(address depositor) view returns (uint256 amount, uint256 lastRewardTime, uint256 rewardsAccrued)",
  "function getTreasuryStats() view returns (uint256 totalDeposited, uint256 totalRewardsPaid, uint256 availableForRedemption)",
  "function ANNUAL_APY() view returns (uint256)",
  "function RESERVE_RATIO() view returns (uint256)",
  "function MIN_RESERVE() view returns (uint256)",
  "event Deposited(address indexed user, uint256 amount)",
  "event Withdrawn(address indexed user, uint256 amount)",
  "event RewardsClaimed(address indexed user, uint256 amount)",
  "event AutoRedemptionExecuted(uint256 indexed nftId, uint256 price)"
];

export const CarbonSubscriptionABI = [
  "function subscribe(uint256 monthlyBudget) external",
  "function updateSubscription(uint256 newBudget) external",
  "function cancelSubscription() external",
  "function processSubscription(address subscriber) external",
  "function batchProcessSubscriptions(address[] memory subscribers) external",
  "function getSubscription(address subscriber) view returns (tuple(uint256 monthlyBudget, uint256 lastProcessed, bool active, uint256 totalSpent, uint256 certificatesPurchased))",
  "function getSubscriptionTier(uint256 budget) view returns (uint8, uint256)",
  "function getActiveSubscribers() view returns (address[])",
  "function isSubscriptionDue(address subscriber) view returns (bool)",
  "function BASIC_TIER() view returns (uint256)",
  "function STANDARD_TIER() view returns (uint256)",
  "function PREMIUM_TIER() view returns (uint256)",
  "function PROCESSING_FEE() view returns (uint256)",
  "event Subscribed(address indexed subscriber, uint256 monthlyBudget)",
  "event SubscriptionUpdated(address indexed subscriber, uint256 newBudget)",
  "event SubscriptionCancelled(address indexed subscriber)",
  "event SubscriptionProcessed(address indexed subscriber, uint256 spent, uint256 certificatesPurchased)"
];
