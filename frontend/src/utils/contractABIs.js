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
  "function createDonation(uint8 foodType, uint256 quantity, uint256 weightKg, string memory location, uint256 expiryTime) external returns (uint256)",
  "function claimDonation(uint256 donationId) external",
  "function confirmPickup(uint256 donationId) external",
  "function confirmDelivery(uint256 donationId, string memory proofUri) external",
  "function getDonation(uint256 donationId) view returns (tuple(address restaurant, address ngo, address courier, uint8 foodType, uint256 quantity, uint256 weightKg, string location, uint256 expiryTime, uint8 status, uint256 createdAt))",
  "function getUserDonations(address user) view returns (uint256[])",
  "function getAvailableDonations() view returns (uint256[])",
  "function cancelDonation(uint256 donationId) external",
  "event DonationCreated(uint256 indexed donationId, address indexed restaurant, uint8 foodType, uint256 quantity)",
  "event DonationClaimed(uint256 indexed donationId, address indexed ngo)",
  "event DonationPickedUp(uint256 indexed donationId, address indexed courier)",
  "event DonationDelivered(uint256 indexed donationId)"
];

export const ReputationSystemABI = [
  "function getReputation(address user) view returns (tuple(uint256 score, uint256 totalDeals, uint256 successfulDeals, uint256 failedDeals, uint256 consecutiveSuccess))",
  "function getReputationMultiplier(address user) view returns (uint256)",
  "function getTier(address user) view returns (string)",
  "event ReputationUpdated(address indexed user, uint256 newScore, uint256 totalDeals)"
];

export const ImpactNFTABI = [
  "function mint(address to, uint256 donationId, uint256 co2Prevented, string memory metadataUri) external returns (uint256)",
  "function tokenURI(uint256 tokenId) view returns (string)",
  "function balanceOf(address owner) view returns (uint256)",
  "function ownerOf(uint256 tokenId) view returns (address)",
  "function getUserNFTs(address user) view returns (uint256[])",
  "function getImpactData(uint256 tokenId) view returns (tuple(uint256 donationId, uint256 co2Prevented, uint256 timestamp, string metadataUri))",
  "event ImpactNFTMinted(uint256 indexed tokenId, address indexed recipient, uint256 co2Prevented)"
];

export const CarbonCreditRegistryABI = [
  "function getCarbonCredits(address user) view returns (uint256)",
  "function getTotalCO2Prevented() view returns (uint256)",
  "function getCreditPrice() view returns (uint256)",
  "event CarbonCreditGenerated(address indexed user, uint256 amount, uint256 co2Prevented)"
];

export const DAOGovernanceABI = [
  "function createProposal(uint8 proposalType, string memory description, bytes memory callData) external returns (uint256)",
  "function vote(uint256 proposalId, bool support) external",
  "function executeProposal(uint256 proposalId) external",
  "function getProposal(uint256 proposalId) view returns (tuple(address proposer, string description, uint256 forVotes, uint256 againstVotes, uint256 startTime, uint256 endTime, bool executed, uint8 status))",
  "function getActiveProposals() view returns (uint256[])",
  "function hasVoted(uint256 proposalId, address voter) view returns (bool)",
  "event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description)",
  "event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight)"
];
