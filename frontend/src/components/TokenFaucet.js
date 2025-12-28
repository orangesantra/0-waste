import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import { ethers } from 'ethers';
import { formatTokenAmount } from '../utils/helpers';
import './TokenFaucet.css';

const TokenFaucet = () => {
  const { contracts, account, connected } = useWeb3();
  const [loading, setLoading] = useState(false);
  const [canClaim, setCanClaim] = useState(false);
  const [timeUntilClaim, setTimeUntilClaim] = useState(0);
  const [faucetStats, setFaucetStats] = useState({
    balance: '0',
    distributed: '0',
    remaining: '0',
    active: false
  });
  const [userStats, setUserStats] = useState({
    lastClaim: '0',
    totalClaimed: '0'
  });
  const [claimAmount, setClaimAmount] = useState('3000');
  const [cooldownPeriod, setCooldownPeriod] = useState('7 days');

  useEffect(() => {
    if (connected && contracts.tokenFaucet && account) {
      loadFaucetData();
      const interval = setInterval(loadFaucetData, 10000); // Update every 10 seconds
      return () => clearInterval(interval);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [connected, contracts.tokenFaucet, account]);

  const loadFaucetData = async () => {
    try {
      // Check if user can claim
      const canClaimResult = await contracts.tokenFaucet.canClaim(account);
      setCanClaim(canClaimResult);

      // Get time until next claim
      if (!canClaimResult) {
        const timeRemaining = await contracts.tokenFaucet.timeUntilNextClaim(account);
        setTimeUntilClaim(Number(timeRemaining));
      } else {
        setTimeUntilClaim(0);
      }

      // Get faucet stats
      const stats = await contracts.tokenFaucet.getFaucetStats();
      setFaucetStats({
        balance: ethers.formatEther(stats[0]),
        distributed: ethers.formatEther(stats[1]),
        remaining: ethers.formatEther(stats[2]),
        active: stats[3]
      });

      // Get user stats
      const lastClaim = await contracts.tokenFaucet.lastClaimTime(account);
      const totalClaimed = await contracts.tokenFaucet.totalClaimed(account);
      setUserStats({
        lastClaim: Number(lastClaim),
        totalClaimed: ethers.formatEther(totalClaimed)
      });

      // Get claim amount and cooldown
      const amount = await contracts.tokenFaucet.CLAIM_AMOUNT();
      const cooldown = await contracts.tokenFaucet.CLAIM_COOLDOWN();
      setClaimAmount(ethers.formatEther(amount));
      setCooldownPeriod(formatCooldown(Number(cooldown)));

    } catch (error) {
      console.error('Error loading faucet data:', error);
    }
  };

  const handleClaim = async () => {
    if (!canClaim) {
      toast.error('Cannot claim yet. Please wait for cooldown period.');
      return;
    }

    setLoading(true);
    try {
      const tx = await contracts.tokenFaucet.claimTokens();
      toast.info('Claiming tokens... Please wait for confirmation.');
      
      await tx.wait();
      
      toast.success(`Successfully claimed ${claimAmount} NOWASTE tokens!`);
      loadFaucetData(); // Refresh data
    } catch (error) {
      console.error('Error claiming tokens:', error);
      const message = error.reason || error.message || 'Failed to claim tokens';
      toast.error(message);
    } finally {
      setLoading(false);
    }
  };

  const formatCooldown = (seconds) => {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    if (days > 0) return `${days} day${days > 1 ? 's' : ''}`;
    if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''}`;
    return '< 1 hour';
  };

  const formatTimeRemaining = (seconds) => {
    if (seconds <= 0) return 'Available now';
    
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (days > 0) return `${days}d ${hours}h ${minutes}m`;
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };

  const formatDate = (timestamp) => {
    if (timestamp === 0) return 'Never';
    return new Date(timestamp * 1000).toLocaleString();
  };

  if (!connected) {
    return (
      <div className="faucet-container">
        <div className="faucet-card">
          <h2>🚰 Token Faucet</h2>
          <p className="connect-message">Please connect your wallet to use the faucet</p>
        </div>
      </div>
    );
  }

  return (
    <div className="faucet-container">
      <div className="faucet-card">
        <h2>🚰 NOWASTE Token Faucet</h2>
        <p className="faucet-description">
          Get {claimAmount} NOWASTE tokens to start using the platform. 
          Available once every {cooldownPeriod}.
        </p>

        {/* Faucet Stats */}
        <div className="stats-grid">
          <div className="stat-box">
            <div className="stat-label">Faucet Balance</div>
            <div className="stat-value">{formatTokenAmount(faucetStats.balance)}</div>
          </div>
          <div className="stat-box">
            <div className="stat-label">Total Distributed</div>
            <div className="stat-value">{formatTokenAmount(faucetStats.distributed)}</div>
          </div>
          <div className="stat-box">
            <div className="stat-label">Your Total Claims</div>
            <div className="stat-value">{formatTokenAmount(userStats.totalClaimed)}</div>
          </div>
          <div className="stat-box">
            <div className="stat-label">Status</div>
            <div className="stat-value">
              <span className={`status-badge ${faucetStats.active ? 'active' : 'inactive'}`}>
                {faucetStats.active ? '🟢 Active' : '🔴 Inactive'}
              </span>
            </div>
          </div>
        </div>

        {/* Claim Section */}
        <div className="claim-section">
          {canClaim ? (
            <>
              <div className="claim-available">
                <div className="claim-amount-display">
                  🎁 {claimAmount} NOWASTE
                </div>
                <button
                  className="claim-button"
                  onClick={handleClaim}
                  disabled={loading || !faucetStats.active}
                >
                  {loading ? 'Claiming...' : 'Claim Tokens'}
                </button>
              </div>
            </>
          ) : (
            <div className="claim-cooldown">
              <div className="cooldown-icon">⏰</div>
              <div className="cooldown-text">
                <strong>Next claim available in:</strong>
                <div className="cooldown-timer">{formatTimeRemaining(timeUntilClaim)}</div>
              </div>
            </div>
          )}
        </div>

        {/* User Info */}
        <div className="user-info">
          <div className="info-row">
            <span className="info-label">Last Claim:</span>
            <span className="info-value">{formatDate(userStats.lastClaim)}</span>
          </div>
          <div className="info-row">
            <span className="info-label">Connected Wallet:</span>
            <span className="info-value wallet-address">{account}</span>
          </div>
        </div>

        {/* Instructions */}
        <div className="instructions">
          <h3>How to use:</h3>
          <ol>
            <li>Connect your wallet to VeryChain mainnet</li>
            <li>Click "Claim Tokens" to receive {claimAmount} NOWASTE</li>
            <li>Wait {cooldownPeriod} before your next claim</li>
            <li>Use tokens to stake and create donations</li>
          </ol>
        </div>
      </div>
    </div>
  );
};

export default TokenFaucet;
