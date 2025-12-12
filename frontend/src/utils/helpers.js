import { ethers } from 'ethers';
import {
  CONTRACT_ADDRESSES,
  TOKEN_DECIMALS,
  EXPLORER_URLS,
  REPUTATION_TIERS
} from './constants';

/**
 * Format token amount with proper decimals
 */
export const formatTokenAmount = (amount, decimals = TOKEN_DECIMALS) => {
  try {
    return ethers.formatUnits(amount, decimals);
  } catch (error) {
    console.error('Error formatting token amount:', error);
    return '0';
  }
};

/**
 * Parse token amount to wei
 */
export const parseTokenAmount = (amount, decimals = TOKEN_DECIMALS) => {
  try {
    return ethers.parseUnits(amount.toString(), decimals);
  } catch (error) {
    console.error('Error parsing token amount:', error);
    return ethers.parseUnits('0', decimals);
  }
};

/**
 * Shorten wallet address
 */
export const shortenAddress = (address) => {
  if (!address) return '';
  return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
};

/**
 * Get contract addresses for current chain
 */
export const getContractAddresses = (chainId) => {
  if (chainId === 80001) return CONTRACT_ADDRESSES.MUMBAI;
  if (chainId === 137) return CONTRACT_ADDRESSES.MAINNET;
  return CONTRACT_ADDRESSES.MUMBAI; // Default to testnet
};

/**
 * Get block explorer URL for transaction
 */
export const getExplorerUrl = (chainId, txHash) => {
  const baseUrl = EXPLORER_URLS[chainId] || EXPLORER_URLS[80001];
  return `${baseUrl}/tx/${txHash}`;
};

/**
 * Get block explorer URL for address
 */
export const getAddressExplorerUrl = (chainId, address) => {
  const baseUrl = EXPLORER_URLS[chainId] || EXPLORER_URLS[80001];
  return `${baseUrl}/address/${address}`;
};

/**
 * Format timestamp to readable date
 */
export const formatDate = (timestamp) => {
  const date = new Date(timestamp * 1000);
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};

/**
 * Get reputation tier based on score
 */
export const getReputationTier = (score) => {
  if (score >= REPUTATION_TIERS.PLATINUM.min && score <= REPUTATION_TIERS.PLATINUM.max) {
    return REPUTATION_TIERS.PLATINUM;
  }
  if (score >= REPUTATION_TIERS.GOLD.min && score <= REPUTATION_TIERS.GOLD.max) {
    return REPUTATION_TIERS.GOLD;
  }
  if (score >= REPUTATION_TIERS.SILVER.min && score <= REPUTATION_TIERS.SILVER.max) {
    return REPUTATION_TIERS.SILVER;
  }
  return REPUTATION_TIERS.BRONZE;
};

/**
 * Calculate CO2 prevented
 */
export const calculateCO2 = (weightKg) => {
  return weightKg * 2.5; // 2.5 kg CO2 per kg food
};

/**
 * Format CO2 amount
 */
export const formatCO2 = (co2Amount) => {
  if (co2Amount >= 1000) {
    return `${(co2Amount / 1000).toFixed(2)} tons`;
  }
  return `${co2Amount.toFixed(2)} kg`;
};

/**
 * Get status color
 */
export const getStatusColor = (status) => {
  const colors = {
    0: 'primary',   // Listed
    1: 'info',      // Claimed
    2: 'warning',   // Picked Up
    3: 'success',   // Delivered
    4: 'success',   // Verified
    5: 'danger'     // Cancelled
  };
  return colors[status] || 'secondary';
};

/**
 * Get status text
 */
export const getStatusText = (status) => {
  const statuses = {
    0: 'Available',
    1: 'Claimed',
    2: 'In Transit',
    3: 'Delivered',
    4: 'Verified',
    5: 'Cancelled'
  };
  return statuses[status] || 'Unknown';
};

/**
 * Get food type text
 */
export const getFoodTypeText = (foodType) => {
  const types = {
    0: 'Vegetarian',
    1: 'Non-Vegetarian',
    2: 'Both'
  };
  return types[foodType] || 'Unknown';
};

/**
 * Validate Ethereum address
 */
export const isValidAddress = (address) => {
  try {
    return ethers.isAddress(address);
  } catch {
    return false;
  }
};

/**
 * Handle transaction error
 */
export const handleTxError = (error) => {
  if (error.code === 'ACTION_REJECTED') {
    return 'Transaction rejected by user';
  }
  if (error.code === 'INSUFFICIENT_FUNDS') {
    return 'Insufficient funds for transaction';
  }
  if (error.message?.includes('user rejected')) {
    return 'Transaction rejected by user';
  }
  return error.message || 'Transaction failed';
};

/**
 * Wait for transaction confirmation
 */
export const waitForTransaction = async (tx, confirmations = 2) => {
  try {
    const receipt = await tx.wait(confirmations);
    return receipt;
  } catch (error) {
    throw new Error(handleTxError(error));
  }
};

/**
 * Format large numbers
 */
export const formatNumber = (num) => {
  if (num >= 1000000) {
    return `${(num / 1000000).toFixed(2)}M`;
  }
  if (num >= 1000) {
    return `${(num / 1000).toFixed(2)}K`;
  }
  return num.toFixed(2);
};

/**
 * Calculate time remaining
 */
export const getTimeRemaining = (expiryTimestamp) => {
  const now = Math.floor(Date.now() / 1000);
  const remaining = expiryTimestamp - now;
  
  if (remaining <= 0) return 'Expired';
  
  const hours = Math.floor(remaining / 3600);
  const minutes = Math.floor((remaining % 3600) / 60);
  
  if (hours > 0) {
    return `${hours}h ${minutes}m`;
  }
  return `${minutes}m`;
};

/**
 * Generate metadata URI for IPFS (placeholder)
 */
export const generateMetadataURI = async (data) => {
  // In production, upload to IPFS
  // For now, return mock URI
  return `ipfs://QmExample${Date.now()}`;
};

/**
 * Get user role badge color
 */
export const getRoleBadgeColor = (role) => {
  const colors = {
    restaurant: 'warning',
    ngo: 'success',
    courier: 'info'
  };
  return colors[role] || 'secondary';
};
