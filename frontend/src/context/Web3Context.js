import React, { createContext, useContext, useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { toast } from 'react-toastify';
import {
  CONTRACT_ADDRESSES,
  SUPPORTED_CHAIN_IDS,
  DEFAULT_CHAIN_ID,
  NETWORKS
} from '../utils/constants';
import {
  NoWasteTokenABI,
  DonationManagerABI,
  ReputationSystemABI,
  ImpactNFTABI,
  CarbonCreditRegistryABI,
  DAOGovernanceABI,
  TokenFaucetABI,
  CertificateMarketplaceABI,
  CertificateTreasuryABI,
  CarbonSubscriptionABI
} from '../utils/contractABIs';
import { getContractAddresses, handleTxError } from '../utils/helpers';

const Web3Context = createContext();

export const useWeb3 = () => {
  const context = useContext(Web3Context);
  if (!context) {
    throw new Error('useWeb3 must be used within Web3Provider');
  }
  return context;
};

export const Web3Provider = ({ children }) => {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [account, setAccount] = useState(null);
  const [chainId, setChainId] = useState(null);
  const [contracts, setContracts] = useState({});
  const [loading, setLoading] = useState(false);
  const [connected, setConnected] = useState(false);

  // Initialize contracts
  const initializeContracts = async (signer, chainId) => {
    try {
      const addresses = getContractAddresses(chainId);
      
      const noWasteToken = new ethers.Contract(
        addresses.NoWasteToken,
        NoWasteTokenABI,
        signer
      );
      
      const donationManager = new ethers.Contract(
        addresses.DonationManager,
        DonationManagerABI,
        signer
      );
      
      const reputationSystem = new ethers.Contract(
        addresses.ReputationSystem,
        ReputationSystemABI,
        signer
      );
      
      const impactNFT = new ethers.Contract(
        addresses.ImpactNFT,
        ImpactNFTABI,
        signer
      );
      
      const carbonCreditRegistry = new ethers.Contract(
        addresses.CarbonCreditRegistry,
        CarbonCreditRegistryABI,
        signer
      );
      
      const daoGovernance = new ethers.Contract(
        addresses.DAOGovernance,
        DAOGovernanceABI,
        signer
      );

      const tokenFaucet = new ethers.Contract(
        addresses.TokenFaucet,
        TokenFaucetABI,
        signer
      );

      const certificateMarketplace = new ethers.Contract(
        addresses.CertificateMarketplace,
        CertificateMarketplaceABI,
        signer
      );

      const certificateTreasury = new ethers.Contract(
        addresses.CertificateTreasury,
        CertificateTreasuryABI,
        signer
      );

      const carbonSubscription = new ethers.Contract(
        addresses.CarbonSubscription,
        CarbonSubscriptionABI,
        signer
      );

      setContracts({
        noWasteToken,
        donationManager,
        reputationSystem,
        impactNFT,
        carbonCreditRegistry,
        daoGovernance,
        tokenFaucet,
        certificateMarketplace,
        certificateTreasury,
        carbonSubscription
      });
    } catch (error) {
      console.error('Error initializing contracts:', error);
      toast.error('Failed to initialize contracts');
    }
  };

  // Connect wallet
  const connectWallet = async () => {
    setLoading(true);
    try {
      if (!window.ethereum) {
        toast.error('Please install MetaMask to use this dApp');
        setLoading(false);
        return;
      }

      // Request account access
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });

      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const network = await provider.getNetwork();
      const chainId = Number(network.chainId);

      // Check if on supported network
      if (!SUPPORTED_CHAIN_IDS.includes(chainId)) {
        await switchNetwork(DEFAULT_CHAIN_ID);
        return;
      }

      setProvider(provider);
      setSigner(signer);
      setAccount(accounts[0]);
      setChainId(chainId);
      setConnected(true);

      // Initialize contracts
      await initializeContracts(signer, chainId);

      toast.success('Wallet connected successfully!');
    } catch (error) {
      console.error('Error connecting wallet:', error);
      toast.error('Failed to connect wallet');
    } finally {
      setLoading(false);
    }
  };

  // Disconnect wallet
  const disconnectWallet = () => {
    setProvider(null);
    setSigner(null);
    setAccount(null);
    setChainId(null);
    setContracts({});
    setConnected(false);
    toast.info('Wallet disconnected');
  };

  // Switch network
  const switchNetwork = async (targetChainId) => {
    try {
      const chainIdHex = `0x${targetChainId.toString(16)}`;
      
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: chainIdHex }]
      });
    } catch (error) {
      // This error code indicates that the chain has not been added to MetaMask
      if (error.code === 4902) {
        try {
          const network = targetChainId === 80001 ? NETWORKS.POLYGON_MUMBAI : NETWORKS.POLYGON_MAINNET;
          
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [network]
          });
        } catch (addError) {
          toast.error('Failed to add network to MetaMask');
        }
      } else {
        toast.error('Failed to switch network');
      }
    }
  };

  // Listen to account changes
  useEffect(() => {
    if (!window.ethereum) return;

    const handleAccountsChanged = (accounts) => {
      console.log('Account changed:', accounts);
      if (accounts.length === 0) {
        console.log('No accounts, disconnecting...');
        disconnectWallet();
      } else if (accounts[0] !== account) {
        console.log('New account detected:', accounts[0]);
        console.log('Old account:', account);
        // Reload page to reinitialize with new account
        window.location.reload();
      }
    };

    const handleChainChanged = (chainId) => {
      const newChainId = parseInt(chainId, 16);
      setChainId(newChainId);
      
      if (!SUPPORTED_CHAIN_IDS.includes(newChainId)) {
        toast.warning('Please switch to Polygon network');
      } else {
        window.location.reload();
      }
    };

    window.ethereum.on('accountsChanged', handleAccountsChanged);
    window.ethereum.on('chainChanged', handleChainChanged);

    return () => {
      if (window.ethereum.removeListener) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
        window.ethereum.removeListener('chainChanged', handleChainChanged);
      }
    };
  }, [account]);

  // Check if already connected on mount
  useEffect(() => {
    const checkConnection = async () => {
      if (window.ethereum) {
        try {
          const accounts = await window.ethereum.request({
            method: 'eth_accounts'
          });
          
          if (accounts.length > 0) {
            await connectWallet();
          }
        } catch (error) {
          console.error('Error checking connection:', error);
        }
      }
    };

    checkConnection();
  }, []);

  const value = {
    provider,
    signer,
    account,
    chainId,
    contracts,
    loading,
    connected,
    connectWallet,
    disconnectWallet,
    switchNetwork
  };

  return <Web3Context.Provider value={value}>{children}</Web3Context.Provider>;
};
