import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import {
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

  useEffect(() => {
    if (connected && contracts.donationManager) {
      fetchAvailableDeals();
    }
  }, [connected, contracts]);

  const fetchAvailableDeals = async () => {
    try {
      setLoading(true);
      const availableDealIds = await contracts.donationManager.getAvailableDonations();
      
      const dealsData = await Promise.all(
        availableDealIds.map(async (id) => {
          const donation = await contracts.donationManager.getDonation(id);
          return {
            id: id.toString(),
            ...donation
          };
        })
      );

      setDeals(dealsData);
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
                      <strong>Required Stake:</strong> {STAKE_AMOUNTS.NGO} NOWASTE
                    </small>
                  </div>
                </div>
                <div className="card-footer bg-white">
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
                      'Claim Donation'
                    )}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
