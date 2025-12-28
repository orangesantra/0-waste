import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import {
  parseTokenAmount,
  formatTokenAmount,
  getStatusText,
  getStatusColor,
  getFoodTypeText,
  formatDate,
  getTimeRemaining,
  handleTxError
} from '../utils/helpers';
import { STAKE_AMOUNTS } from '../utils/constants';

export default function AvailableDeals() {
  const { account, connected, contracts } = useWeb3();
  const [loading, setLoading] = useState(true);
  const [deals, setDeals] = useState([]);
  const [claimingId, setClaimingId] = useState(null);
  const [acceptingId, setAcceptingId] = useState(null);

  useEffect(() => {
    if (connected && contracts.donationManager) {
      fetchAvailableDeals();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [connected, contracts]);

  const fetchAvailableDeals = async () => {
    try {
      setLoading(true);
      
      // Since getAvailableDonations doesn't exist, fetch donation counter and check each
      const counter = await contracts.donationManager.donationCounter();
      const counterNum = Number(counter);
      
      console.log('Total donations:', counterNum);
      
      if (counterNum === 0) {
        setDeals([]);
        setLoading(false);
        return;
      }
      
      const availableDeals = [];
      
      // Check each donation to see if it's available (status = LISTED = 0)
      for (let i = 1; i <= counterNum; i++) {
        try {
          const donation = await contracts.donationManager.getDonation(i);
          
          // Status 0 = LISTED (available for NGO to claim)
          // Status 1 = CLAIMED (available for courier to accept)
          const status = Number(donation.status);
          if (status === 0 || status === 1) {
            availableDeals.push({
              id: i.toString(),
              restaurant: donation.restaurant,
              foodType: donation.foodType,
              quantity: Number(donation.quantity) || 0,
              marketValue: formatTokenAmount(donation.marketValue),
              weightKg: Number(donation.marketValue) / 1e18 || 0, // Use marketValue as weight
              pickupTimeStart: Number(donation.pickupTimeStart),
              pickupTimeEnd: Number(donation.pickupTimeEnd),
              expiryTime: Number(donation.pickupTimeEnd), // Use pickupTimeEnd as expiryTime
              location: donation.location || 'Not specified',
              ngo: donation.ngo,
              status: status,
              createdAt: Number(donation.createdAt)
            });
          }
        } catch (err) {
          console.log(`Donation ${i} not found or error:`, err.message);
        }
      }
      
      console.log('Available deals:', availableDeals);
      setDeals(availableDeals);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching deals:', error);
      toast.error('Failed to load available deals');
      setLoading(false);
    }
  };

  const handleClaimDeal = async (dealId) => {
    try {
      setClaimingId(dealId);
      
      // Check token balance
      const balance = await contracts.noWasteToken.balanceOf(account);
      const requiredStake = parseTokenAmount(STAKE_AMOUNTS.NGO);
      
      if (balance < requiredStake) {
        toast.error(`Insufficient balance. You need ${STAKE_AMOUNTS.NGO} NOWASTE tokens to claim.`);
        setClaimingId(null);
        return;
      }

      // Check allowance
      const allowance = await contracts.noWasteToken.allowance(
        account,
        contracts.donationManager.target
      );

      if (allowance < requiredStake) {
        toast.info('Approving tokens...');
        const approveTx = await contracts.noWasteToken.approve(
          contracts.donationManager.target,
          requiredStake
        );
        await approveTx.wait();
        toast.success('Tokens approved!');
      }

      toast.info('Claiming donation...');
      const tx = await contracts.donationManager.claimDonation(dealId);
      await tx.wait();

      toast.success('Donation claimed successfully! 🎉');
      fetchAvailableDeals(); // Refresh list
    } catch (error) {
      console.error('Error claiming deal:', error);
      toast.error(handleTxError(error));
    } finally {
      setClaimingId(null);
    }
  };

  const handleAcceptDelivery = async (dealId) => {
    try {
      setAcceptingId(dealId);
      
      // Check staked balance (couriers need 750 NOWASTE staked)
      const stakedBalance = await contracts.noWasteToken.stakedBalance(account);
      const requiredStake = parseTokenAmount(STAKE_AMOUNTS.COURIER);
      
      if (stakedBalance < requiredStake) {
        toast.error(`Insufficient stake. You need ${STAKE_AMOUNTS.COURIER} NOWASTE staked to accept deliveries.`);
        setAcceptingId(null);
        return;
      }

      toast.info('Accepting delivery...');
      const tx = await contracts.donationManager.acceptDelivery(dealId);
      await tx.wait();

      toast.success('Delivery accepted successfully! 🚚');
      fetchAvailableDeals(); // Refresh list
    } catch (error) {
      console.error('Error accepting delivery:', error);
      toast.error(handleTxError(error));
    } finally {
      setAcceptingId(null);
    }
  };

  if (!connected) {
    return (
      <div className="container mt-5">
        <div className="alert alert-warning text-center">
          <h4>Please connect your wallet to view available deals</h4>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="container mt-5 text-center">
        <div className="spinner-border text-success" role="status"></div>
        <p className="mt-3">Loading available deals...</p>
      </div>
    );
  }

  return (
    <div className="container mt-4">
      <h2 className="text-center mb-4">
        <span className="text-success">Available Donations</span>
      </h2>

      {deals.length === 0 ? (
        <div className="alert alert-info text-center">
          <h5>No available donations at the moment</h5>
          <p>Check back later or create your own donation listing!</p>
        </div>
      ) : (
        <div className="row">
          {deals.map((deal) => (
            <div key={deal.id} className="col-md-6 col-lg-4 mb-4">
              <div className="card h-100 deal-card">
                <div className="card-header bg-success text-white">
                  <h6 className="mb-0">
                    Donation #{deal.id}
                    <span className={`badge bg-${getStatusColor(deal.status)} float-end`}>
                      {getStatusText(deal.status)}
                    </span>
                  </h6>
                </div>
                <div className="card-body">
                  <div className="mb-3">
                    <strong>Food Type:</strong>
                    <span className="badge bg-info ms-2">
                      {getFoodTypeText(Number(deal.foodType))}
                    </span>
                  </div>
                  
                  <div className="mb-2">
                    <strong>Quantity:</strong> {deal.quantity.toString()} packets
                  </div>
                  
                  <div className="mb-2">
                    <strong>Weight:</strong> {deal.weightKg.toString()} kg
                  </div>
                  
                  <div className="mb-2">
                    <strong>Location:</strong> {deal.location}
                  </div>
                  
                  <div className="mb-2">
                    <strong>Posted:</strong> {formatDate(Number(deal.createdAt))}
                  </div>
                  
                  <div className="mb-3">
                    <strong>Expires in:</strong>{' '}
                    <span className="text-danger">
                      {getTimeRemaining(Number(deal.expiryTime))}
                    </span>
                  </div>

                  <div className="alert alert-light mb-3">
                    <small>
                      <strong>Required Stake:</strong>{' '}
                      {deal.status === 0 ? STAKE_AMOUNTS.NGO : STAKE_AMOUNTS.COURIER} NOWASTE
                    </small>
                  </div>

                  {deal.status === 1 && (
                    <div className="alert alert-info mb-3">
                      <small>
                        <strong>Claimed by NGO:</strong> {deal.ngo ? `${deal.ngo.slice(0, 6)}...${deal.ngo.slice(-4)}` : 'Unknown'}
                      </small>
                    </div>
                  )}
                </div>
                <div className="card-footer bg-white">
                  {deal.status === 0 ? (
                    <button
                      className="btn btn-success w-100"
                      onClick={() => handleClaimDeal(deal.id)}
                      disabled={claimingId === deal.id}
                    >
                      {claimingId === deal.id ? (
                        <>
                          <span className="spinner-border spinner-border-sm me-2"></span>
                          Claiming...
                        </>
                      ) : (
                        'Claim Donation (NGO)'
                      )}
                    </button>
                  ) : (
                    <button
                      className="btn btn-primary w-100"
                      onClick={() => handleAcceptDelivery(deal.id)}
                      disabled={acceptingId === deal.id}
                    >
                      {acceptingId === deal.id ? (
                        <>
                          <span className="spinner-border spinner-border-sm me-2"></span>
                          Accepting...
                        </>
                      ) : (
                        'Accept Delivery (Courier)'
                      )}
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
