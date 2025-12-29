import React from 'react';
import { Link } from 'react-router-dom';
import { useWeb3 } from '../context/Web3Context';

export default function Home() {
  const { connected } = useWeb3();

  return (
    <>
      {/* Hero Section */}
      <section className="hero-section">
        <div className="container">
          <h1 className="hero-title">NoWaste</h1>
          <p className="hero-subtitle">
            Decentralized Food Waste Management on VeryChain
          </p>
          <p className="lead mb-4">
            Turn food waste into environmental impact. Earn tokens, mint NFTs, and generate carbon credits.
          </p>
          {!connected ? (
            <div className="mt-4">
              <button className="btn btn-warning btn-lg me-3" onClick={() => alert('Please connect wallet using the button in navigation')}>
                Connect Wallet to Get Started
              </button>
              <a href="#about" className="btn btn-outline-light btn-lg">
                Learn More
              </a>
            </div>
          ) : (
            <div className="mt-4">
              <Link to="/dashboard" className="btn btn-warning btn-lg me-3">
                Go to Dashboard
              </Link>
              <Link to="/makedeal" className="btn btn-outline-light btn-lg">
                Create Donation
              </Link>
            </div>
          )}
        </div>
      </section>

      {/* Stats Section */}
      <section className="stats-section">
        <div className="container">
          <div className="row">
            <div className="col-md-3 stat-item">
              <div className="stat-number">$1.2T</div>
              <div className="stat-label">Global Food Waste Annually</div>
            </div>
            <div className="col-md-3 stat-item">
              <div className="stat-number">1B</div>
              <div className="stat-label">Total Token Supply</div>
            </div>
            <div className="col-md-3 stat-item">
              <div className="stat-number">2.5kg</div>
              <div className="stat-label">CO₂ Saved per kg Food</div>
            </div>
            <div className="col-md-3 stat-item">
              <div className="stat-number">0%</div>
              <div className="stat-label">Platform Fees (2% on transactions)</div>
            </div>
          </div>
        </div>
      </section>

      {/* Tokenomics Section */}
      <section className="bg-light py-5">
        <div className="container">
          <div className="text-center mb-5">
            <h2 className="display-4 text-green">$NOWASTE Token</h2>
            <p className="lead text-muted">Utility token powering the ecosystem</p>
          </div>

          <div className="row">
            <div className="col-md-6 mb-4">
              <div className="card">
                <div className="card-body">
                  <h5 className="card-title">Token Utility</h5>
                  <ul>
                    <li><strong>Staking:</strong> Required to participate in the platform</li>
                    <li><strong>Rewards:</strong> Earn tokens for every successful deal</li>
                    <li><strong>Governance:</strong> Vote on protocol changes (DAO)</li>
                    <li><strong>Discounts:</strong> Pay fees in tokens for 50% discount</li>
                    <li><strong>Revenue Sharing:</strong> Holders receive platform revenue</li>
                  </ul>
                </div>
              </div>
            </div>

            <div className="col-md-6 mb-4">
              <div className="card">
                <div className="card-body">
                  <h5 className="card-title">Deflationary Mechanics</h5>
                  <ul>
                    <li><strong>1% Burn:</strong> Every transaction burns tokens</li>
                    <li><strong>NFT Minting:</strong> 100 tokens burned per NFT</li>
                    <li><strong>Treasury Buyback:</strong> 30% of revenue buys & burns tokens</li>
                    <li><strong>Limited Supply:</strong> Max 1 billion tokens</li>
                    <li><strong>Long-term Value:</strong> Decreasing supply over time</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Impact Section */}
      <section className="container my-5">
        <div className="text-center mb-5">
          <h2 className="display-4 text-green">Environmental Impact</h2>
          <p className="lead text-muted">Real-world impact backed by blockchain</p>
        </div>

        <div className="row g-4">
          <div className="col-md-4">
            <div className="card text-center">
              <div className="card-body">
                <div style={{ fontSize: '3rem' }} className="mb-3">🌍</div>
                <h4>Carbon Credits</h4>
                <p>Every kg of food saved prevents 2.5kg of CO₂ emissions. These are converted into tradeable carbon credits.</p>
              </div>
            </div>
          </div>

          <div className="col-md-4">
            <div className="card text-center">
              <div className="card-body">
                <div style={{ fontSize: '3rem' }} className="mb-3">🏆</div>
                <h4>Impact NFTs</h4>
                <p>Mint NFT certificates for each donation. Use them for tax deductions, ESG reporting, or trade on marketplaces.</p>
              </div>
            </div>
          </div>

          <div className="col-md-4">
            <div className="card text-center">
              <div className="card-body">
                <div style={{ fontSize: '3rem' }} className="mb-3">📊</div>
                <h4>Transparent Tracking</h4>
                <p>All donations tracked on-chain with GPS verification, multi-signature confirmations, and IPFS proof storage.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-gradient-success text-white py-5 text-center">
        <div className="container">
          <h2 className="display-4 mb-4">Ready to Make an Impact?</h2>
          <p className="lead mb-4">
            Join the decentralized movement to eliminate food waste and feed those in need.
          </p>
          {!connected ? (
            <button className="btn btn-warning btn-lg" onClick={() => alert('Please connect wallet using the button in navigation')}>
              Connect Your Wallet
            </button>
          ) : (
            <Link to="/dashboard" className="btn btn-warning btn-lg">
              Go to Dashboard
            </Link>
          )}
        </div>
      </section>
    </>
  );
}
