import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { formatTokenAmount, getReputationTier, formatCO2 } from '../utils/helpers';
import { toast } from 'react-toastify';

export default function Dashboard() {
  const { account, connected, contracts } = useWeb3();
  const [loading, setLoading] = useState(true);
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

      // Fetch token balance
      const balance = await contracts.noWasteToken.balanceOf(account);
      const stakedBal = await contracts.noWasteToken.getStakedBalance(account);

      // Fetch reputation
      const reputation = await contracts.reputationSystem.getReputation(account);

      // Fetch NFT count
      const nftCount = await contracts.impactNFT.balanceOf(account);

      // Fetch carbon credits
      const carbonCredits = await contracts.carbonCreditRegistry.getCarbonCredits(account);

      setStats({
        tokenBalance: formatTokenAmount(balance),
        stakedBalance: formatTokenAmount(stakedBal),
        reputation: {
          score: Number(reputation.score),
          totalDeals: Number(reputation.totalDeals),
          successfulDeals: Number(reputation.successfulDeals),
          failedDeals: Number(reputation.failedDeals),
          consecutiveSuccess: Number(reputation.consecutiveSuccess)
        },
        nftCount: Number(nftCount),
        totalCO2: formatTokenAmount(carbonCredits, 0),
        totalDeals: Number(reputation.totalDeals)
      });

      setLoading(false);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      toast.error('Failed to load dashboard data');
      setLoading(false);
    }
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
