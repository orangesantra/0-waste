import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import './CertificateMarketplace.css';

const CertificateMarketplace = () => {
  const { contracts, account, connected } = useWeb3();
  const [activeTab, setActiveTab] = useState('marketplace');
  const [listings, setListings] = useState([]);
  const [myNFTs, setMyNFTs] = useState([]);
  const [retiredCerts, setRetiredCerts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [listingPrice, setListingPrice] = useState('');
  const [selectedNFT, setSelectedNFT] = useState(null);
  const [marketStats, setMarketStats] = useState({
    totalListed: 0,
    totalSold: 0,
    totalRetired: 0
  });
  const [myStats, setMyStats] = useState({
    purchases: 0,
    rewards: 0
  });

  // Safe formatter to handle null/undefined values
  const safeFormatUnits = (value, decimals = 0) => {
    try {
      if (value === null || value === undefined) return '0';
      return ethers.formatUnits(value, decimals);
    } catch (error) {
      console.error('Error formatting units:', error);
      return '0';
    }
  };

  const safeFormatEther = (value) => {
    try {
      if (value === null || value === undefined) return '0';
      return ethers.formatEther(value);
    } catch (error) {
      console.error('Error formatting ether:', error);
      return '0';
    }
  };

  useEffect(() => {
    if (connected && contracts.certificateMarketplace) {
      loadMarketplaceData();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [connected, contracts, account, activeTab]);

  const loadMarketplaceData = async () => {
    setLoading(true);
    try {
      if (activeTab === 'marketplace') {
        await loadActiveListings();
      } else if (activeTab === 'myNFTs') {
        await loadMyNFTs();
      } else if (activeTab === 'retired') {
        await loadRetiredCertificates();
      }
      await loadMarketStats();
      await loadMyStats();
    } catch (error) {
      console.error('Error loading marketplace data:', error);
      toast.error('Failed to load marketplace data');
    }
    setLoading(false);
  };

  const loadActiveListings = async () => {
    try {
      console.log('Loading active listings...');
      const activeListingIds = await contracts.certificateMarketplace.getActiveListings();
      console.log('Active listing IDs:', activeListingIds.map(id => id.toString()));
      
      const listingsData = await Promise.all(
        activeListingIds.map(async (nftId) => {
          console.log('Fetching data for NFT:', nftId.toString());
          const listing = await contracts.certificateMarketplace.getListing(nftId);
          console.log('Listing data:', {
            seller: listing.seller,
            price: listing.price.toString(),
            active: listing.active
          });
          
          const impactData = await contracts.impactNFT.getImpactData(nftId);
          console.log('Impact data:', impactData);
          
          return {
            nftId: nftId.toString(),
            seller: listing.seller,
            price: safeFormatEther(listing.price),
            listedAt: new Date(Number(listing.listedAt) * 1000).toLocaleDateString(),
            active: listing.active,
            restaurant: impactData.restaurant || impactData[0],
            ngo: impactData.ngo || impactData[1],
            foodQuantity: impactData.foodQuantity || impactData[2] || 0,
            marketValue: impactData.marketValue || impactData[3] || 0,
            co2Prevented: impactData.co2Prevented || impactData[4] || 0,
            foodType: impactData.foodType || impactData[5] || 'Unknown',
            timestamp: impactData.timestamp || impactData[6] || 0
          };
        })
      );
      
      console.log('All listings data:', listingsData);
      const activeListings = listingsData.filter(l => l.active);
      console.log('Filtered active listings:', activeListings);
      setListings(activeListings);
    } catch (error) {
      console.error('Error loading listings:', error);
      setListings([]);
    }
  };

  const loadMyNFTs = async () => {
    try {
      const nftIds = await contracts.impactNFT.getRestaurantCertificates(account);
      const nftsData = await Promise.all(
        nftIds.map(async (nftId) => {
          const impactData = await contracts.impactNFT.getImpactData(nftId);
          const owner = await contracts.impactNFT.ownerOf(nftId);
          
          // Check if listed
          let isListed = false;
          let listingPrice = '0';
          try {
            const listing = await contracts.certificateMarketplace.getListing(nftId);
            isListed = listing.active;
            listingPrice = safeFormatEther(listing.price);
          } catch (e) {
            // Not listed
          }

          return {
            nftId: nftId.toString(),
            owner,
            isListed,
            listingPrice,
            restaurant: impactData.restaurant || impactData[0],
            ngo: impactData.ngo || impactData[1],
            foodQuantity: impactData.foodQuantity || impactData[2] || 0,
            marketValue: impactData.marketValue || impactData[3] || 0,
            co2Prevented: impactData.co2Prevented || impactData[4] || 0,
            foodType: impactData.foodType || impactData[5] || 'Unknown',
            timestamp: impactData.timestamp || impactData[6] || 0,
            ipfsHash: impactData.ipfsHash || impactData[7] || '',
            donationId: impactData.donationId || impactData[8] || 0,
            verified: impactData.verified || impactData[9] || false
          };
        })
      );
      setMyNFTs(nftsData.filter(nft => nft.owner.toLowerCase() === account.toLowerCase()));
    } catch (error) {
      console.error('Error loading my NFTs:', error);
      setMyNFTs([]);
    }
  };

  const loadRetiredCertificates = async () => {
    try {
      // Note: Contract doesn't track retirements separately, using purchases for now
      const purchasedIds = await contracts.certificateMarketplace.getBuyerPurchases(account);
      const retiredData = [];
      
      // Check which ones are retired (owned by treasury)
      for (const nftId of purchasedIds) {
        try {
          const owner = await contracts.impactNFT.ownerOf(nftId);
          const treasuryAddress = await contracts.certificateMarketplace.treasuryAddress();
          
          if (owner.toLowerCase() === treasuryAddress.toLowerCase()) {
            const impactData = await contracts.impactNFT.getImpactData(nftId);
            retiredData.push({
              nftId: nftId.toString(),
              restaurant: impactData.restaurant || impactData[0],
              ngo: impactData.ngo || impactData[1],
              foodQuantity: impactData.foodQuantity || impactData[2] || 0,
              marketValue: impactData.marketValue || impactData[3] || 0,
              co2Prevented: impactData.co2Prevented || impactData[4] || 0,
              foodType: impactData.foodType || impactData[5] || 'Unknown',
              timestamp: impactData.timestamp || impactData[6] || 0
            });
          }
        } catch (e) {
          // Skip if error fetching data
        }
      }
      
      setRetiredCerts(retiredData);
    } catch (error) {
      console.error('Error loading retired certificates:', error);
      setRetiredCerts([]);
    }
  };

  const loadMarketStats = async () => {
    try {
      const totalListed = await contracts.certificateMarketplace.totalListed();
      const totalSold = await contracts.certificateMarketplace.totalSold();
      const totalRetired = await contracts.certificateMarketplace.totalRetired();
      setMarketStats({
        totalListed: totalListed.toString(),
        totalSold: totalSold.toString(),
        totalRetired: totalRetired.toString()
      });
    } catch (error) {
      console.error('Error loading market stats:', error);
    }
  };

  const loadMyStats = async () => {
    try {
      const buyerStats = await contracts.certificateMarketplace.getBuyerStats(account);
      setMyStats({
        purchases: buyerStats.totalPurchased.toString(),
        rewards: '0' // Rewards are distributed automatically, not tracked separately
      });
    } catch (error) {
      console.error('Error loading my stats:', error);
    }
  };

  const handleListCertificate = async (nftId) => {
    if (!listingPrice || parseFloat(listingPrice) <= 0) {
      toast.error('Please enter a valid price');
      return;
    }

    setLoading(true);
    try {
      console.log('Listing NFT:', nftId);
      console.log('Price:', listingPrice);
      console.log('Marketplace address:', contracts.certificateMarketplace.target);
      
      // First approve marketplace to transfer NFT
      const approveTx = await contracts.impactNFT.approve(
        contracts.certificateMarketplace.target,
        nftId
      );
      toast.info('Approving NFT transfer...');
      console.log('Approve TX:', approveTx.hash);
      await approveTx.wait();
      console.log('Approve confirmed');

      // List the certificate
      const priceWei = ethers.parseEther(listingPrice);
      console.log('Price in wei:', priceWei.toString());
      const listTx = await contracts.certificateMarketplace.listCertificate(nftId, priceWei);
      toast.info('Listing certificate...');
      console.log('List TX:', listTx.hash);
      await listTx.wait();
      console.log('List confirmed');

      toast.success('Certificate listed successfully!');
      setListingPrice('');
      setSelectedNFT(null);
      await loadMyNFTs();
      await loadActiveListings();
      await loadMarketStats();
    } catch (error) {
      console.error('Error listing certificate:', error);
      console.error('Error details:', {
        message: error.message,
        reason: error.reason,
        code: error.code,
        data: error.data
      });
      
      // More detailed error messages
      let errorMsg = 'Failed to list certificate';
      if (error.reason) {
        errorMsg = error.reason;
      } else if (error.message) {
        if (error.message.includes('user rejected')) {
          errorMsg = 'Transaction rejected by user';
        } else if (error.message.includes('insufficient funds')) {
          errorMsg = 'Insufficient funds for gas';
        } else {
          errorMsg = error.message.substring(0, 100);
        }
      }
      toast.error(errorMsg);
    }
    setLoading(false);
  };

  const handleBuyCertificate = async (nftId, price) => {
    setLoading(true);
    try {
      // First approve tokens
      const priceWei = ethers.parseEther(price);
      const approveTx = await contracts.noWasteToken.approve(
        contracts.certificateMarketplace.target,
        priceWei
      );
      toast.info('Approving token transfer...');
      await approveTx.wait();

      // Buy the certificate
      const buyTx = await contracts.certificateMarketplace.buyCertificate(nftId);
      toast.info('Purchasing certificate...');
      await buyTx.wait();

      toast.success('Certificate purchased successfully! Rewards credited.');
      await loadActiveListings();
      await loadMyStats();
    } catch (error) {
      console.error('Error buying certificate:', error);
      toast.error(error.reason || 'Failed to buy certificate');
    }
    setLoading(false);
  };

  const handleRetireCertificate = async (nftId) => {
    if (!window.confirm('Are you sure you want to retire this certificate? This action is permanent.')) {
      return;
    }

    setLoading(true);
    try {
      const retireTx = await contracts.certificateMarketplace.retireCertificate(nftId);
      toast.info('Retiring certificate...');
      await retireTx.wait();

      toast.success('Certificate retired! You earned 100 NOWASTE tokens.');
      await loadMyNFTs();
      await loadMarketStats();
    } catch (error) {
      console.error('Error retiring certificate:', error);
      toast.error(error.reason || 'Failed to retire certificate');
    }
    setLoading(false);
  };

  const handleCancelListing = async (nftId) => {
    setLoading(true);
    try {
      const cancelTx = await contracts.certificateMarketplace.cancelListing(nftId);
      toast.info('Cancelling listing...');
      await cancelTx.wait();

      toast.success('Listing cancelled successfully');
      await loadMyNFTs();
    } catch (error) {
      console.error('Error cancelling listing:', error);
      toast.error(error.reason || 'Failed to cancel listing');
    }
    setLoading(false);
  };

  if (!connected) {
    return (
      <div className="marketplace-container">
        <div className="connect-prompt">
          <h2>🔒 Connect Your Wallet</h2>
          <p>Please connect your wallet to access the marketplace</p>
        </div>
      </div>
    );
  }

  return (
    <div className="marketplace-container">
      <div className="marketplace-header">
        <h1>🌍 Certificate Marketplace</h1>
        <p>Buy and trade carbon offset certificates from verified donations</p>
      </div>

      <div className="market-stats">
        <div className="stat-card">
          <span className="stat-label">Total Listed</span>
          <span className="stat-value">{marketStats.totalListed}</span>
        </div>
        <div className="stat-card">
          <span className="stat-label">Total Sold</span>
          <span className="stat-value">{marketStats.totalSold}</span>
        </div>
        <div className="stat-card">
          <span className="stat-label">Total Retired</span>
          <span className="stat-value">{marketStats.totalRetired}</span>
        </div>
        <div className="stat-card highlight">
          <span className="stat-label">My Purchases</span>
          <span className="stat-value">{myStats.purchases}</span>
        </div>
        <div className="stat-card highlight">
          <span className="stat-label">Rewards Earned</span>
          <span className="stat-value">{parseFloat(myStats.rewards).toFixed(2)} NOWASTE</span>
        </div>
      </div>

      <div className="marketplace-tabs">
        <button
          className={`tab-button ${activeTab === 'marketplace' ? 'active' : ''}`}
          onClick={() => setActiveTab('marketplace')}
        >
          🛒 Active Listings
        </button>
        <button
          className={`tab-button ${activeTab === 'myNFTs' ? 'active' : ''}`}
          onClick={() => setActiveTab('myNFTs')}
        >
          🎫 My Certificates
        </button>
        <button
          className={`tab-button ${activeTab === 'retired' ? 'active' : ''}`}
          onClick={() => setActiveTab('retired')}
        >
          ♻️ Retired Certificates
        </button>
      </div>

      <div className="marketplace-content">
        {loading ? (
          <div className="loading-spinner">Loading...</div>
        ) : (
          <>
            {activeTab === 'marketplace' && (
              <div className="listings-grid">
                {listings.length === 0 ? (
                  <div className="empty-state">
                    <p>No active listings at the moment</p>
                    <p>Check back later or list your own certificate!</p>
                  </div>
                ) : (
                  listings.map((listing) => (
                    <div key={listing.nftId} className="certificate-card">
                      <div className="card-header">
                        <span className="nft-id">Certificate #{listing.nftId}</span>
                        <span className="food-type">{listing.foodType}</span>
                      </div>
                      <div className="card-body">
                        <div className="impact-info">
                          <div className="info-row">
                            <span className="label">🍽️ Food Saved:</span>
                            <span className="value">{safeFormatUnits(listing.foodQuantity, 0)} packets</span>
                          </div>
                          <div className="info-row">
                            <span className="label">🌱 CO2 Prevented:</span>
                            <span className="value">{safeFormatUnits(listing.co2Prevented, 0)} kg</span>
                          </div>
                          <div className="info-row">
                            <span className="label">💰 Market Value:</span>
                            <span className="value">${safeFormatEther(listing.marketValue)}</span>
                          </div>
                          <div className="info-row">
                            <span className="label">📅 Listed:</span>
                            <span className="value">{listing.listedAt}</span>
                          </div>
                        </div>
                        <div className="price-section">
                          <span className="price-label">Price:</span>
                          <span className="price-value">{listing.price} NOWASTE</span>
                        </div>
                        <div className="seller-info">
                          <span className="label">Seller:</span>
                          <span className="address">{listing.seller.slice(0, 6)}...{listing.seller.slice(-4)}</span>
                        </div>
                      </div>
                      <div className="card-footer">
                        {listing.seller.toLowerCase() === account.toLowerCase() ? (
                          <button className="btn-secondary" disabled>Your Listing</button>
                        ) : (
                          <button
                            className="btn-primary"
                            onClick={() => handleBuyCertificate(listing.nftId, listing.price)}
                            disabled={loading}
                          >
                            Buy Certificate
                          </button>
                        )}
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}

            {activeTab === 'myNFTs' && (
              <div className="my-nfts-grid">
                {myNFTs.length === 0 ? (
                  <div className="empty-state">
                    <p>You don't have any certificates yet</p>
                    <p>Complete a donation to earn your first Impact NFT!</p>
                  </div>
                ) : (
                  myNFTs.map((nft) => (
                    <div key={nft.nftId} className="certificate-card">
                      <div className="card-header">
                        <span className="nft-id">Certificate #{nft.nftId}</span>
                        <span className="food-type">{nft.foodType}</span>
                        {nft.isListed && <span className="listed-badge">📋 Listed</span>}
                      </div>
                      <div className="card-body">
                        <div className="impact-info">
                          <div className="info-row">
                            <span className="label">🍽️ Food Saved:</span>
                            <span className="value">{safeFormatUnits(nft.foodQuantity, 0)} packets</span>
                          </div>
                          <div className="info-row">
                            <span className="label">🌱 CO2 Prevented:</span>
                            <span className="value">{safeFormatUnits(nft.co2Prevented, 0)} kg</span>
                          </div>
                          <div className="info-row">
                            <span className="label">💰 Market Value:</span>
                            <span className="value">${safeFormatEther(nft.marketValue)}</span>
                          </div>
                          <div className="info-row">
                            <span className="label">📅 Created:</span>
                            <span className="value">{new Date(Number(nft.timestamp) * 1000).toLocaleDateString()}</span>
                          </div>
                        </div>
                        {nft.isListed ? (
                          <div className="listed-info">
                            <p>Listed for: {nft.listingPrice} NOWASTE</p>
                            <button
                              className="btn-secondary"
                              onClick={() => handleCancelListing(nft.nftId)}
                              disabled={loading}
                            >
                              Cancel Listing
                            </button>
                          </div>
                        ) : (
                          <div className="listing-form">
                            <input
                              type="number"
                              placeholder="Price in NOWASTE"
                              value={selectedNFT === nft.nftId ? listingPrice : ''}
                              onChange={(e) => {
                                setSelectedNFT(nft.nftId);
                                setListingPrice(e.target.value);
                              }}
                              className="price-input"
                            />
                            <button
                              className="btn-primary"
                              onClick={() => handleListCertificate(nft.nftId)}
                              disabled={loading || selectedNFT !== nft.nftId || !listingPrice}
                            >
                              List for Sale
                            </button>
                          </div>
                        )}
                      </div>
                      <div className="card-footer">
                        <button
                          className="btn-retire"
                          onClick={() => handleRetireCertificate(nft.nftId)}
                          disabled={loading || nft.isListed}
                        >
                          ♻️ Retire (Earn 100 NOWASTE)
                        </button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}

            {activeTab === 'retired' && (
              <div className="retired-grid">
                {retiredCerts.length === 0 ? (
                  <div className="empty-state">
                    <p>You haven't retired any certificates yet</p>
                    <p>Retire certificates to permanently offset carbon and earn rewards!</p>
                  </div>
                ) : (
                  retiredCerts.map((cert) => (
                    <div key={cert.nftId} className="certificate-card retired">
                      <div className="card-header">
                        <span className="nft-id">Certificate #{cert.nftId}</span>
                        <span className="retired-badge">♻️ RETIRED</span>
                      </div>
                      <div className="card-body">
                        <div className="impact-info">
                          <div className="info-row">
                            <span className="label">🍽️ Food Saved:</span>
                            <span className="value">{safeFormatUnits(cert.foodQuantity, 0)} packets</span>
                          </div>
                          <div className="info-row">
                            <span className="label">🌱 CO2 Prevented:</span>
                            <span className="value">{safeFormatUnits(cert.co2Prevented, 0)} kg</span>
                          </div>
                          <div className="info-row">
                            <span className="label">💰 Market Value:</span>
                            <span className="value">${safeFormatEther(cert.marketValue)}</span>
                          </div>
                        </div>
                        <div className="retirement-info">
                          <p>✅ Permanently offset carbon</p>
                          <p>🏆 Earned 100 NOWASTE reward</p>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

export default CertificateMarketplace;
