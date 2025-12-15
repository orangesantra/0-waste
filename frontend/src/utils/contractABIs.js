// Simplified ABIs for frontend interaction
// Full ABIs will be imported from contract artifacts after deployment

export const NoWasteTokenABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)",
  "function approve(address spender, uint256 amount) returns (bool)",
  "function allowance(address owner, address spender) view returns (uint256)",
  "function stake(uint256 amount) external",
  "function unstake(uint256 amount) external",
  "function getStakedBalance(address user) view returns (uint256)",
  "function totalSupply() view returns (uint256)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)",
  "function name() view returns (string)"
];

export const DonationManagerABI = [
  "function createDonation(string memory foodType, uint256 quantity, uint256 marketValue, uint256 pickupTimeStart, uint256 pickupTimeEnd, string memory location, string memory photoHash) external returns (uint256)",
  "function claimDonation(uint256 donationId) external",
  "function assignCourier(uint256 donationId) external",
  "function confirmPickup(uint256 donationId) external",
  "function confirmDelivery(uint256 donationId) external",
  "function confirmReceipt(uint256 donationId) external",
  "function getDonation(uint256 donationId) view returns (tuple(uint256 id, address restaurant, string foodType, uint256 quantity, uint256 marketValue, uint256 pickupTimeStart, uint256 pickupTimeEnd, string location, address ngo, address courier, uint8 status, uint256 createdAt, uint256 claimedAt, uint256 completedAt, string photoHash))",
  "function getRestaurantDonations(address restaurant) view returns (uint256[])",
  "function getNGODonations(address ngo) view returns (uint256[])",
  "function getCourierDonations(address courier) view returns (uint256[])",
  "function getAvailableDonations() view returns (uint256[])",
  "function cancelDonation(uint256 donationId) external",
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
  "function getUserNFTs(address user) view returns (uint256[])",
  "function getImpactData(uint256 tokenId) view returns (tuple(address restaurant, address ngo, uint256 foodQuantity, uint256 marketValue, uint256 co2Prevented, string foodType, uint256 timestamp, string ipfsHash, uint256 donationId, bool verified))",
  "function getTotalCO2Prevented(address user) view returns (uint256)",
  "function BURN_AMOUNT() view returns (uint256)",
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "event ImpactNFTMinted(uint256 indexed tokenId, address indexed restaurant, address indexed ngo, uint256 co2Prevented)"
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
