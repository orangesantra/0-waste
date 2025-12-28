import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import { formatDate, formatCO2 } from '../utils/helpers';
import { IPFS_GATEWAY } from '../utils/constants';

export default function ImpactNFTGallery() {
  const { account, connected, contracts } = useWeb3();
  const [loading, setLoading] = useState(true);
  const [nfts, setNfts] = useState([]);

  useEffect(() => {
    if (connected && account && contracts.impactNFT) {
      fetchUserNFTs();
    }
  }, [connected, account, contracts]);

  const fetchUserNFTs = async () => {
    try {
      setLoading(true);
      
      // Get NFT balance first
      const balance = await contracts.impactNFT.balanceOf(account);
      console.log('NFT balance:', balance.toString());
      
      if (Number(balance) === 0) {
        setNfts([]);
        setLoading(false);
        return;
      }
      
      // Get user's NFT token IDs
      let nftIds = [];
      try {
        nftIds = await contracts.impactNFT.getRestaurantCertificates(account);
      } catch (err) {
        console.log('getRestaurantCertificates error:', err.message);
        // Function error - show message
        toast.info('Unable to fetch NFT data');
        setNfts([]);
        setLoading(false);
        return;
      }
      
      const nftsData = await Promise.all(
        nftIds.map(async (tokenId) => {
          const impactData = await contracts.impactNFT.getImpactData(tokenId);
          const tokenURI = await contracts.impactNFT.tokenURI(tokenId);
          
          return {
            tokenId: tokenId.toString(),
            donationId: impactData.donationId.toString(),
            co2Prevented: Number(impactData.co2Prevented),
            timestamp: Number(impactData.timestamp),
            metadataUri: impactData.ipfsHash,
            tokenURI
          };
        })
      );

      setNfts(nftsData);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching NFTs:', error);
      console.error('Error details:', error.message);
      toast.error('Failed to load Impact NFTs');
      setLoading(false);
    }
  };

  const getTotalCO2 = () => {
    return nfts.reduce((sum, nft) => sum + nft.co2Prevented, 0);
  };

  if (!connected) {
    return (
      <div className="container mt-5">
        <div className="alert alert-warning text-center">
          <h4>Please connect your wallet to view your Impact NFTs</h4>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="container mt-5 text-center">
        <div className="spinner-border text-success" role="status"></div>
        <p className="mt-3">Loading your Impact NFTs...</p>
      </div>
    );
  }

  return (
    <div className="container mt-4">
      <div className="text-center mb-4">
        <h2 className="text-success">My Impact NFT Collection</h2>
        <p className="lead">Proof of your environmental impact on the blockchain</p>
      </div>

      {nfts.length > 0 && (
        <div className="row mb-4">
          <div className="col-md-6 offset-md-3">
            <div className="card text-center bg-gradient-success text-white">
              <div className="card-body">
                <h5 className="card-title">Total Environmental Impact</h5>
                <h2 className="display-4">{formatCO2(getTotalCO2())}</h2>
                <p className="mb-0">CO₂ Emissions Prevented</p>
                <small className="opacity-75">Across {nfts.length} donations</small>
              </div>
            </div>
          </div>
        </div>
      )}

      {nfts.length === 0 ? (
        <div className="alert alert-info text-center">
          <h5>You don't have any Impact NFTs yet</h5>
          <p>Complete your first donation to earn an Impact NFT certificate!</p>
          <a href="/available" className="btn btn-primary mt-2">
            Browse Available Donations
          </a>
        </div>
      ) : (
        <div className="row">
          {nfts.map((nft) => (
            <div key={nft.tokenId} className="col-md-6 col-lg-4 mb-4">
              <div className="card h-100 nft-card">
                <div className="nft-image-container">
                  <div className="nft-placeholder">
                    <div className="nft-icon">🏆</div>
                    <div className="nft-title">Impact Certificate</div>
                  </div>
                </div>
                <div className="card-body">
                  <h5 className="card-title text-success">
                    Impact NFT #{nft.tokenId}
                  </h5>
                  
                  <div className="mb-2">
                    <strong>Donation ID:</strong> #{nft.donationId}
                  </div>
                  
                  <div className="mb-2">
                    <strong>CO₂ Prevented:</strong>
                    <span className="text-success ms-2">
                      {formatCO2(nft.co2Prevented)}
                    </span>
                  </div>
                  
                  <div className="mb-2">
                    <strong>Date Minted:</strong>
                    <div className="text-muted">{formatDate(nft.timestamp)}</div>
                  </div>

                  <div className="mt-3">
                    <div className="d-grid gap-2">
                      <button className="btn btn-sm btn-outline-primary" disabled>
                        View on IPFS
                      </button>
                      <button className="btn btn-sm btn-outline-secondary" disabled>
                        Download Certificate
                      </button>
                    </div>
                  </div>
                </div>
                <div className="card-footer bg-light text-center">
                  <small className="text-muted">
                    This NFT represents your verified environmental impact
                  </small>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {nfts.length > 0 && (
        <div className="alert alert-success mt-4">
          <h6 className="alert-heading">💡 Did you know?</h6>
          <p className="mb-0">
            Your Impact NFTs can be used for:
          </p>
          <ul className="mb-0 mt-2">
            <li>Tax deduction documentation</li>
            <li>ESG reporting for corporations</li>
            <li>Proof of environmental contribution</li>
            <li>Trading on secondary markets (coming soon)</li>
          </ul>
        </div>
      )}
    </div>
  );
}
