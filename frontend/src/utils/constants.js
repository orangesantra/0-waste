// Network Configuration
export const NETWORKS = {
  POLYGON_MAINNET: {
    chainId: '0x89',
    chainName: 'Polygon Mainnet',
    nativeCurrency: {
      name: 'MATIC',
      symbol: 'MATIC',
      decimals: 18
    },
    rpcUrls: ['https://polygon-rpc.com'],
    blockExplorerUrls: ['https://polygonscan.com/']
  },
  POLYGON_MUMBAI: {
    chainId: '0x13881',
    chainName: 'Polygon Mumbai Testnet',
    nativeCurrency: {
      name: 'MATIC',
      symbol: 'MATIC',
      decimals: 18
    },
    rpcUrls: ['https://rpc-mumbai.maticvigil.com'],
    blockExplorerUrls: ['https://mumbai.polygonscan.com/']
  }
};

// Contract Addresses (Update after deployment)
export const CONTRACT_ADDRESSES = {
  // Polygon Mumbai Testnet
  MUMBAI: {
    NoWasteToken: '0x0000000000000000000000000000000000000000',
    DonationManager: '0x0000000000000000000000000000000000000000',
    ReputationSystem: '0x0000000000000000000000000000000000000000',
    ImpactNFT: '0x0000000000000000000000000000000000000000',
    CarbonCreditRegistry: '0x0000000000000000000000000000000000000000',
    DAOGovernance: '0x0000000000000000000000000000000000000000'
  },
  // Polygon Mainnet
  MAINNET: {
    NoWasteToken: '0x0000000000000000000000000000000000000000',
    DonationManager: '0x0000000000000000000000000000000000000000',
    ReputationSystem: '0x0000000000000000000000000000000000000000',
    ImpactNFT: '0x0000000000000000000000000000000000000000',
    CarbonCreditRegistry: '0x0000000000000000000000000000000000000000',
    DAOGovernance: '0x0000000000000000000000000000000000000000'
  }
};

// Staking Requirements (in tokens)
export const STAKE_AMOUNTS = {
  RESTAURANT: '1000',
  NGO: '500',
  COURIER: '750',
  VALIDATOR: '200',
  DAO_VOTER: '5000'
};

// Token Decimals
export const TOKEN_DECIMALS = 18;

// Food Types
export const FOOD_TYPES = {
  VEG: 0,
  NON_VEG: 1,
  BOTH: 2
};

// Donation Status
export const DONATION_STATUS = {
  LISTED: 0,
  CLAIMED: 1,
  PICKED_UP: 2,
  DELIVERED: 3,
  VERIFIED: 4,
  CANCELLED: 5
};

// User Roles
export const USER_ROLES = {
  RESTAURANT: 'restaurant',
  NGO: 'ngo',
  COURIER: 'courier'
};

// Reputation Tiers
export const REPUTATION_TIERS = {
  BRONZE: { min: 0, max: 249, multiplier: 1.0, name: 'Bronze' },
  SILVER: { min: 250, max: 499, multiplier: 1.25, name: 'Silver' },
  GOLD: { min: 500, max: 749, multiplier: 1.5, name: 'Gold' },
  PLATINUM: { min: 750, max: 1000, multiplier: 2.0, name: 'Platinum' }
};

// Base Rewards (in tokens)
export const BASE_REWARDS = {
  RESTAURANT: 100,
  NGO: 50,
  COURIER: 75,
  VALIDATOR: 10
};

// CO2 Calculation
export const CO2_PER_KG_FOOD = 2.5; // 2.5 kg CO2 prevented per kg of food saved

// Transaction Types
export const TX_TYPES = {
  STAKE: 'Stake Tokens',
  UNSTAKE: 'Unstake Tokens',
  CREATE_DONATION: 'Create Donation',
  CLAIM_DONATION: 'Claim Donation',
  CONFIRM_PICKUP: 'Confirm Pickup',
  CONFIRM_DELIVERY: 'Confirm Delivery',
  MINT_NFT: 'Mint Impact NFT',
  VOTE: 'Vote on Proposal'
};

// Supported Networks
export const SUPPORTED_CHAIN_IDS = [80001, 137]; // Mumbai, Polygon Mainnet

// Default Chain ID (Mumbai for testing)
export const DEFAULT_CHAIN_ID = 80001;

// API Endpoints (if using backend)
export const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

// IPFS Gateway
export const IPFS_GATEWAY = 'https://gateway.pinata.cloud/ipfs/';

// Block Explorer URLs
export const EXPLORER_URLS = {
  80001: 'https://mumbai.polygonscan.com',
  137: 'https://polygonscan.com'
};
