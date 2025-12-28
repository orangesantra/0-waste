import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { formatTokenAmount, getReputationTier, formatCO2 } from '../utils/helpers';
import { toast } from 'react-toastify';
import { ethers } from 'ethers';

export default function Dashboard() {
  const { account, connected, contracts } = useWeb3();
  const [loading, setLoading] = useState(true);
  const [staking, setStaking] = useState(false);
  const [unstaking, setUnstaking] = useState(false);
  const [stakeAmount, setStakeAmount] = useState('');
  const [unstakeAmount, setUnstakeAmount] = useState('');
  const [stats, setStats] = useState({
    tokenBalance: '0',
    stakedBalance: '0',
    reputation: null,
    nftCount: 0,
    totalCO2: '0',
    totalDeals: 0
  });

  useEffect(() => {
    if (connected && account && contracts.noWasteToken) {
      fetchDashboardData();
    }
  }, [connected, account, contracts]);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);

      console.log('Fetching dashboard data for:', account);

      // Fetch token balance
      const balance = await contracts.noWasteToken.balanceOf(account);
      console.log('Token balance:', balance.toString());
      
      const stakedBal = await contracts.noWasteToken.stakedBalance(account);
      console.log('Staked balance:', stakedBal.toString());

      // Fetch reputation
      let reputation;
      try {
        reputation = await contracts.reputationSystem.getUserReputation(account);
        console.log('Reputation:', reputation);
      } catch (err) {
        console.log('Reputation not initialized yet:', err.message);
        // Create default reputation if not initialized
        reputation = {
          score: 0,
          totalDonations: 0,
          successfulDonations: 0,
          cancelledDonations: 0,
          consecutiveSuccesses: 0
        };
      }

      // Fetch NFT count
      let nftCount = 0;
      try {
        nftCount = await contracts.impactNFT.balanceOf(account);
        console.log('NFT count:', nftCount.toString());
      } catch (err) {
        console.log('NFT count error:', err.message);
      }

      // Fetch carbon credits
      let carbonCredits = 0;
      try {
        carbonCredits = await contracts.carbonCreditRegistry.getUserCredits(account);
      } catch (err) {
        console.log('Carbon credits not available:', err.message);
      }

      setStats({
        tokenBalance: formatTokenAmount(balance),
        stakedBalance: formatTokenAmount(stakedBal),
        reputation: {
          score: Number(reputation.score),
          totalDeals: Number(reputation.totalDonations),
          successfulDeals: Number(reputation.successfulDonations),
          failedDeals: Number(reputation.cancelledDonations),
          consecutiveSuccess: Number(reputation.consecutiveSuccesses)
        },
        nftCount: Number(nftCount),
        totalCO2: formatTokenAmount(carbonCredits, 0),
        totalDeals: Number(reputation.totalDonations)
      });

      console.log('Dashboard data loaded successfully');
      setLoading(false);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      console.error('Error details:', error.message);
      toast.error('Failed to load dashboard data');
      setLoading(false);
    }
  };

  const handleStake = async () => {
    if (!stakeAmount || parseFloat(stakeAmount) <= 0) {
      toast.error('Please enter a valid amount');
      return;
    }

    const amount = ethers.parseEther(stakeAmount);
    const balance = ethers.parseEther(stats.tokenBalance);

    if (amount > balance) {
      toast.error('Insufficient balance');
      return;
    }

    setStaking(true);
    try {
      const tx = await contracts.noWasteToken.stake(amount);
      toast.info('Staking tokens... Please wait for confirmation.');
      
      await tx.wait();
      
      toast.success(`Successfully staked ${stakeAmount} NOWASTE tokens!`);
      setStakeAmount('');
      fetchDashboardData(); // Refresh data
    } catch (error) {
      console.error('Error staking tokens:', error);
      const message = error.reason || error.message || 'Failed to stake tokens';
      toast.error(message);
    } finally {
      setStaking(false);
    }
  };

  const handleUnstake = async () => {
    if (!unstakeAmount || parseFloat(unstakeAmount) <= 0) {
      toast.error('Please enter a valid amount');
      return;
    }

    const amount = ethers.parseEther(unstakeAmount);
    const staked = ethers.parseEther(stats.stakedBalance);

    if (amount > staked) {
      toast.error('Insufficient staked balance');
      return;
    }

    setUnstaking(true);
    try {
      const tx = await contracts.noWasteToken.unstake(amount);
      toast.info('Unstaking tokens... Please wait for confirmation.');
      
      await tx.wait();
      
      toast.success(`Successfully unstaked ${unstakeAmount} NOWASTE tokens!`);
      setUnstakeAmount('');
      fetchDashboardData(); // Refresh data
    } catch (error) {
      console.error('Error unstaking tokens:', error);
      const message = error.reason || error.message || 'Failed to unstake tokens';
      toast.error(message);
    } finally {
      setUnstaking(false);
    }
  };

  const setMaxStake = () => {
    setStakeAmount(stats.tokenBalance);
  };

  const setMaxUnstake = () => {
    setUnstakeAmount(stats.stakedBalance);
  };

  if (!connected) {
    return (
      <div className="container mt-5">
        <div className="alert alert-warning text-center" role="alert">
          <h4>Please connect your wallet to view dashboard</h4>
          <p>Click the "Connect Wallet" button in the navigation bar</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="container mt-5 text-center">
        <div className="spinner-border text-success" role="status">
          <span className="visually-hidden">Loading...</span>
        </div>
        <p className="mt-3">Loading dashboard data...</p>
      </div>
    );
  }

  const tier = stats.reputation ? getReputationTier(stats.reputation.score) : null;
  const successRate = stats.totalDeals > 0
    ? ((stats.reputation.successfulDeals / stats.totalDeals) * 100).toFixed(1)
    : 0;

  return (
    <div className="container mt-4">
      <h2 className="text-center mb-4">
        <span className="text-success">My Dashboard</span>
      </h2>

      {/* Token Stats */}
      <div className="row mb-4">
        <div className="col-md-3 mb-3">
          <div className="card stat-card bg-gradient-primary text-white">
            <div className="card-body">
              <h6 className="card-subtitle mb-2 opacity-75">Token Balance</h6>
              <h3 className="card-title mb-0">{parseFloat(stats.tokenBalance).toFixed(2)}</h3>
              <small>NOWASTE</small>
            </div>
          </div>
        </div>

        <div className="col-md-3 mb-3">
          <div className="card stat-card bg-gradient-success text-white">
            <div className="card-body">
              <h6 className="card-subtitle mb-2 opacity-75">Staked Balance</h6>
              <h3 className="card-title mb-0">{parseFloat(stats.stakedBalance).toFixed(2)}</h3>
              <small>NOWASTE</small>
            </div>
          </div>
        </div>

        <div className="col-md-3 mb-3">
          <div className="card stat-card bg-gradient-warning text-white">
            <div className="card-body">
              <h6 className="card-subtitle mb-2 opacity-75">Impact NFTs</h6>
              <h3 className="card-title mb-0">{stats.nftCount}</h3>
              <small>Certificates</small>
            </div>
          </div>
        </div>

        <div className="col-md-3 mb-3">
          <div className="card stat-card bg-gradient-info text-white">
            <div className="card-body">
              <h6 className="card-subtitle mb-2 opacity-75">CO₂ Prevented</h6>
              <h3 className="card-title mb-0">{stats.totalCO2}</h3>
              <small>kg</small>
            </div>
          </div>
        </div>
      </div>

      {/* Staking Section */}
      <div className="row mb-4">
        <div className="col-12">
          <div className="card">
            <div className="card-body">
              <h5 className="card-title mb-4">💰 Manage Staking</h5>
              <div className="alert alert-info mb-3">
                <strong>Staking Requirements:</strong>
                <ul className="mb-0 mt-2">
                  <li>Restaurant: 1000 NOWASTE to create donations</li>
                  <li>NGO: 500 NOWASTE to claim donations</li>
                  <li>Courier: 750 NOWASTE to accept deliveries</li>
                </ul>
              </div>
              
              <div className="row">
                {/* Stake Tokens */}
                <div className="col-md-6">
                  <div className="card bg-light">
                    <div className="card-body">
                      <h6 className="card-subtitle mb-3">Stake Tokens</h6>
                      <div className="input-group mb-2">
                        <input
                          type="number"
                          className="form-control"
                          placeholder="Amount to stake"
                          value={stakeAmount}
                          onChange={(e) => setStakeAmount(e.target.value)}
                          disabled={staking}
                        />
                        <button
                          className="btn btn-outline-secondary"
                          onClick={setMaxStake}
                          disabled={staking}
                        >
                          MAX
                        </button>
                      </div>
                      <small className="text-muted d-block mb-3">
                        Available: {parseFloat(stats.tokenBalance).toFixed(2)} NOWASTE
                      </small>
                      <button
                        className="btn btn-success w-100"
                        onClick={handleStake}
                        disabled={staking || !stakeAmount}
                      >
                        {staking ? 'Staking...' : 'Stake Tokens'}
                      </button>
                    </div>
                  </div>
                </div>

                {/* Unstake Tokens */}
                <div className="col-md-6">
                  <div className="card bg-light">
                    <div className="card-body">
                      <h6 className="card-subtitle mb-3">Unstake Tokens</h6>
                      <div className="input-group mb-2">
                        <input
                          type="number"
                          className="form-control"
                          placeholder="Amount to unstake"
                          value={unstakeAmount}
                          onChange={(e) => setUnstakeAmount(e.target.value)}
                          disabled={unstaking}
                        />
                        <button
                          className="btn btn-outline-secondary"
                          onClick={setMaxUnstake}
                          disabled={unstaking}
                        >
                          MAX
                        </button>
                      </div>
                      <small className="text-muted d-block mb-3">
                        Staked: {parseFloat(stats.stakedBalance).toFixed(2)} NOWASTE
                      </small>
                      <button
                        className="btn btn-warning w-100"
                        onClick={handleUnstake}
                        disabled={unstaking || !unstakeAmount}
                      >
                        {unstaking ? 'Unstaking...' : 'Unstake Tokens'}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Reputation Section */}
      {stats.reputation && (
        <div className="row mb-4">
          <div className="col-md-6 mb-3">
            <div className="card">
              <div className="card-body">
                <h5 className="card-title">
                  Reputation Score
                  <span className={`badge bg-${tier.name.toLowerCase()} float-end`}>
                    {tier.name}
                  </span>
                </h5>
                <div className="progress mb-3" style={{ height: '30px' }}>
                  <div
                    className={`progress-bar bg-${tier.name.toLowerCase()}`}
                    role="progressbar"
                    style={{ width: `${(stats.reputation.score / 1000) * 100}%` }}
                    aria-valuenow={stats.reputation.score}
                    aria-valuemin="0"
                    aria-valuemax="1000"
                  >
                    {stats.reputation.score} / 1000
                  </div>
                </div>
                <p className="mb-1">
                  <strong>Reward Multiplier:</strong> {tier.multiplier}x
                </p>
                <p className="mb-0 text-muted">
                  Complete more deals successfully to increase your reputation and earn higher rewards!
                </p>
              </div>
            </div>
          </div>

          <div className="col-md-6 mb-3">
            <div className="card">
              <div className="card-body">
                <h5 className="card-title">Deal Statistics</h5>
                <div className="row text-center mt-3">
                  <div className="col-4">
                    <h4 className="text-primary">{stats.totalDeals}</h4>
                    <small className="text-muted">Total Deals</small>
                  </div>
                  <div className="col-4">
                    <h4 className="text-success">{stats.reputation.successfulDeals}</h4>
                    <small className="text-muted">Successful</small>
                  </div>
                  <div className="col-4">
                    <h4 className="text-danger">{stats.reputation.failedDeals}</h4>
                    <small className="text-muted">Failed</small>
                  </div>
                </div>
                <div className="mt-3">
                  <div className="d-flex justify-content-between mb-2">
                    <span>Success Rate:</span>
                    <strong className="text-success">{successRate}%</strong>
                  </div>
                  <div className="progress">
                    <div
                      className="progress-bar bg-success"
                      style={{ width: `${successRate}%` }}
                    ></div>
                  </div>
                </div>
                <div className="mt-3">
                  <span className="badge bg-info">
                    {stats.reputation.consecutiveSuccess} consecutive successes 🔥
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Quick Actions */}
      <div className="row">
        <div className="col-12">
          <div className="card">
            <div className="card-body">
              <h5 className="card-title mb-4">Quick Actions</h5>
              <div className="row text-center">
                <div className="col-md-3 mb-3">
                  <a href="/makedeal" className="btn btn-lg btn-outline-success w-100">
                    <div className="mb-2" style={{ fontSize: '2rem' }}>📦</div>
                    Create Donation
                  </a>
                </div>
                <div className="col-md-3 mb-3">
                  <a href="/available" className="btn btn-lg btn-outline-primary w-100">
                    <div className="mb-2" style={{ fontSize: '2rem' }}>🔍</div>
                    Browse Deals
                  </a>
                </div>
                <div className="col-md-3 mb-3">
                  <a href="/mydeals" className="btn btn-lg btn-outline-info w-100">
                    <div className="mb-2" style={{ fontSize: '2rem' }}>📋</div>
                    My Deals
                  </a>
                </div>
                <div className="col-md-3 mb-3">
                  <a href="/nfts" className="btn btn-lg btn-outline-warning w-100">
                    <div className="mb-2" style={{ fontSize: '2rem' }}>🏆</div>
                    View NFTs
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
