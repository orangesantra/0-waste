// Network Configuration
export const NETWORKS = {
  VERYCHAIN: {
    chainId: '0x1205', // 4613 in hex
    chainName: 'VeryChain Mainnet',
    nativeCurrency: {
      name: 'VERY',
      symbol: 'VERY',
      decimals: 18
    },
    rpcUrls: ['https://rpc.verylabs.io'],
    blockExplorerUrls: ['https://veryscan.io/']
  },
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

// Contract Addresses (Updated December 28, 2025)
export const CONTRACT_ADDRESSES = {
  // VeryChain Mainnet (Primary Network)
  4613: {
    NoWasteToken: '0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9',
    DonationManager: '0x8cae686969Ca2329656CED848dc4b42E6C594bBb',
    ReputationSystem: '0x3B3052A9A2D34F3179A92c0CC33bA154Aa0eF495',
    ImpactNFT: '0xCD05E4b28fd2608830ac14f6f509a11d590A78FA',
    CarbonCreditRegistry: '0x0410bd7cA7C47Adb4F1522eE2843f699D39cA03A',
    DAOGovernance: '0xA2Ec8265B755eBC9B60B2AF7C54f665f5E0f78Fa',
    TokenFaucet: '0xd459E589cc0F0b8537b1Cccb99e96ef438eb7A32',
    CertificateMarketplace: '0xB368485b6c747Dc98db9Cfaa3806cA3692192596',
    CertificateTreasury: '0xC3F86FFA5126D1f67f568D5804dAbBE043C35De1',
    CarbonSubscription: '0x6d0e4eb5f5337577b341456eDe612EF4FdC9cb0E'
  },
  // Polygon Mumbai Testnet (Testing Only)
  80001: {
    NoWasteToken: '0x0000000000000000000000000000000000000000',
    DonationManager: '0x0000000000000000000000000000000000000000',
    ReputationSystem: '0x0000000000000000000000000000000000000000',
    ImpactNFT: '0x0000000000000000000000000000000000000000',
    CarbonCreditRegistry: '0x0000000000000000000000000000000000000000',
    DAOGovernance: '0x0000000000000000000000000000000000000000'
  },
  // Polygon Mainnet (Backup Network)
  137: {
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
export const SUPPORTED_CHAIN_IDS = [4613, 80001, 137]; // VeryChain, Mumbai, Polygon

// Default Chain ID (VeryChain Mainnet)
export const DEFAULT_CHAIN_ID = 4613;

// API Endpoints (if using backend)
export const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

// IPFS Gateway
export const IPFS_GATEWAY = 'https://gateway.pinata.cloud/ipfs/';

// Block Explorer URLs
export const EXPLORER_URLS = {
  4613: 'https://veryscan.io',
  80001: 'https://mumbai.polygonscan.com',
  137: 'https://polygonscan.com'
};

// Network Names
export const NETWORK_NAMES = {
  4613: 'VeryChain',
  80001: 'Mumbai Testnet',
  137: 'Polygon'
};
