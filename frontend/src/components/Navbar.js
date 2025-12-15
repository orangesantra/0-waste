import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useWeb3 } from '../context/Web3Context';
import { shortenAddress } from '../utils/helpers';

export default function Navbar() {
  const { account, connected, connectWallet, disconnectWallet, loading, chainId } = useWeb3();
  const navigate = useNavigate();

  const handleConnectWallet = async () => {
    if (connected) {
      disconnectWallet();
    } else {
      await connectWallet();
    }
  };

  const getNetworkName = () => {
    if (!chainId) return '';
    switch (chainId) {
      case 4613:
        return 'VeryChain';
      case 80001:
        return 'Mumbai Testnet';
      case 137:
        return 'Polygon';
      default:
        return `Chain ${chainId}`;
    }
  };

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-gradient-green">
      <div className="container-fluid">
        <Link className="navbar-brand d-flex align-items-center" to="/">
          <span className="brand-logo">🌱</span>
          <span className="brand-text">NoWaste Protocol</span>
        </Link>
        
        <button 
          className="navbar-toggler" 
          type="button" 
          data-bs-toggle="collapse" 
          data-bs-target="#navbarContent" 
          aria-controls="navbarContent" 
          aria-expanded="false" 
          aria-label="Toggle navigation"
        >
          <span className="navbar-toggler-icon"></span>
        </button>

        <div className="collapse navbar-collapse" id="navbarContent">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0">
            <li className="nav-item">
              <Link className="nav-link" to="/">
                Home
              </Link>
            </li>
            
            {connected && (
              <>
                <li className="nav-item">
                  <Link className="nav-link" to="/dashboard">
                    Dashboard
                  </Link>
                </li>
                
                <li className="nav-item dropdown">
                  <a 
                    className="nav-link dropdown-toggle" 
                    href="#" 
                    id="dealsDropdown" 
                    role="button" 
                    data-bs-toggle="dropdown" 
                    aria-expanded="false"
                  >
                    Deals
                  </a>
                  <ul className="dropdown-menu" aria-labelledby="dealsDropdown">
                    <li>
                      <Link className="dropdown-item" to="/makedeal">
                        Create Donation
                      </Link>
                    </li>
                    <li>
                      <Link className="dropdown-item" to="/available">
                        Available Deals
                      </Link>
                    </li>
                    <li>
                      <Link className="dropdown-item" to="/mydeals">
                        My Deals
                      </Link>
                    </li>
                  </ul>
                </li>

                <li className="nav-item">
                  <Link className="nav-link" to="/nfts">
                    Impact NFTs
                  </Link>
                </li>
              </>
            )}

            <li className="nav-item">
              <a className="nav-link" href="#about">
                About
              </a>
            </li>
          </ul>

          <div className="d-flex align-items-center">
            {connected && chainId && (
              <span className="badge bg-success me-3">
                {getNetworkName()}
              </span>
            )}
            
            <button
              className={`btn ${connected ? 'btn-outline-light' : 'btn-warning'} wallet-btn`}
              onClick={handleConnectWallet}
              disabled={loading}
            >
              {loading ? (
                <>
                  <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                  Connecting...
                </>
              ) : connected ? (
                <>
                  {shortenAddress(account)}
                </>
              ) : (
                <>
                  Connect Wallet
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}
