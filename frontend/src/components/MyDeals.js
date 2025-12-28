import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import {
  formatDate,
  formatTokenAmount,
  getStatusText,
  getStatusColor,
  getFoodTypeText,
  getExplorerUrl,
  handleTxError,
  formatCO2
} from '../utils/helpers';

export default function MyDeals() {
  const { account, connected, contracts, chainId } = useWeb3();
  const [loading, setLoading] = useState(true);
  const [deals, setDeals] = useState([]);
  const [filter, setFilter] = useState('all'); // all, active, completed
  const [confirmingId, setConfirmingId] = useState(null);
  const [actionType, setActionType] = useState(null); // pickup, delivery

  useEffect(() => {
    if (connected && contracts.donationManager) {
      fetchUserDeals();
    }
  }, [connected, contracts]);

  const fetchUserDeals = async () => {
    try {
      setLoading(true);
      
      console.log('Fetching deals for account:', account);
      
      // Fetch donations for all roles the user might have
      const restaurantDeals = await contracts.donationManager.getRestaurantDonations(account);
      console.log('Restaurant deals:', restaurantDeals);
      
      const ngoDeals = await contracts.donationManager.getNGODonations(account);
      console.log('NGO deals:', ngoDeals);
      
      const courierDeals = await contracts.donationManager.getCourierDeliveries(account);
      console.log('Courier deals:', courierDeals);
      
      // Combine all deal IDs (use Set to avoid duplicates)
      const allDealIds = [...new Set([
        ...restaurantDeals.map(id => id.toString()),
        ...ngoDeals.map(id => id.toString()),
        ...courierDeals.map(id => id.toString())
      ])];
      
      console.log('All deal IDs combined:', allDealIds);
      
      if (allDealIds.length === 0) {
        console.log('No deals found');
        setDeals([]);
        setLoading(false);
        return;
      }
      
      const dealsData = await Promise.all(
        allDealIds.map(async (id) => {
          const donation = await contracts.donationManager.getDonation(id);
          
          // Determine user role in this deal
          let role = 'unknown';
          if (donation.restaurant.toLowerCase() === account.toLowerCase()) {
            role = 'restaurant';
          } else if (donation.ngo.toLowerCase() === account.toLowerCase()) {
            role = 'ngo';
          } else if (donation.courier.toLowerCase() === account.toLowerCase()) {
            role = 'courier';
          }

          console.log(`Deal #${id}: status=${donation.status}, role=${role}, restaurant=${donation.restaurant}, ngo=${donation.ngo}, courier=${donation.courier}`);

          return {
            id: id.toString(),
            restaurant: donation.restaurant,
            ngo: donation.ngo,
            courier: donation.courier,
            foodType: donation.foodType,
            quantity: Number(donation.quantity),
            marketValue: formatTokenAmount(donation.marketValue),
            location: donation.location,
            pickupTimeStart: Number(donation.pickupTimeStart),
            pickupTimeEnd: Number(donation.pickupTimeEnd),
            status: Number(donation.status),
            createdAt: Number(donation.createdAt),
            role
          };
        })
      );

      console.log('All deals loaded:', dealsData);
      setDeals(dealsData);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching deals:', error);
      console.error('Error details:', error.message);
      toast.error('Failed to load your deals');
      setLoading(false);
    }
  };

  const handleConfirmPickup = async (dealId) => {
    try {
      setConfirmingId(dealId);
      setActionType('pickup');

      toast.info('Confirming pickup...');
      const tx = await contracts.donationManager.confirmPickup(dealId);
      await tx.wait();

      toast.success('Pickup confirmed! 🚚');
      
      const explorerUrl = getExplorerUrl(chainId, tx.hash);
      console.log('Pickup tx:', explorerUrl);

      fetchUserDeals(); // Refresh list
    } catch (error) {
      console.error('Error confirming pickup:', error);
      toast.error(handleTxError(error));
    } finally {
      setConfirmingId(null);
      setActionType(null);
    }
  };

  const handleConfirmDelivery = async (dealId) => {
    try {
      setConfirmingId(dealId);
      setActionType('delivery');

      // In production, upload proof photo to IPFS first
      const proofUri = `ipfs://QmExample${Date.now()}`; // Placeholder

      toast.info('Confirming delivery...');
      const tx = await contracts.donationManager.confirmDelivery(dealId, proofUri);
      await tx.wait();

      toast.success('Delivery confirmed! 🎉');
      
      const explorerUrl = getExplorerUrl(chainId, tx.hash);
      console.log('Delivery tx:', explorerUrl);

      fetchUserDeals(); // Refresh list
    } catch (error) {
      console.error('Error confirming delivery:', error);
      toast.error(handleTxError(error));
    } finally {
      setConfirmingId(null);
      setActionType(null);
    }
  };

  const handleConfirmReceipt = async (dealId) => {
    try {
      setConfirmingId(dealId);
      setActionType('receipt');

      toast.info('Confirming receipt...');
      const tx = await contracts.donationManager.confirmReceipt(dealId);
      await tx.wait();

      toast.success('Receipt confirmed! 🎉 Donation completed! All parties earned rewards and NFTs!');
      
      const explorerUrl = getExplorerUrl(chainId, tx.hash);
      console.log('Receipt tx:', explorerUrl);

      fetchUserDeals(); // Refresh list
    } catch (error) {
      console.error('Error confirming receipt:', error);
      toast.error(handleTxError(error));
    } finally {
      setConfirmingId(null);
      setActionType(null);
    }
  };

  const canConfirmPickup = (deal) => {
    return deal.role === 'restaurant' && deal.status === 2; // COURIER_ASSIGNED
  };

  const canConfirmDelivery = (deal) => {
    return deal.role === 'courier' && deal.status === 3; // PICKUP_CONFIRMED
  };

  const canConfirmReceipt = (deal) => {
    return deal.role === 'ngo' && deal.status === 4; // DELIVERED
  };

  const getFilteredDeals = () => {
    if (filter === 'all') return deals;
    if (filter === 'active') return deals.filter(d => d.status < 4);
    if (filter === 'completed') return deals.filter(d => d.status >= 4);
    return deals;
  };

  const getRoleBadge = (role) => {
    const badges = {
      restaurant: <span className="badge bg-warning">Restaurant</span>,
      ngo: <span className="badge bg-success">NGO</span>,
      courier: <span className="badge bg-info">Courier</span>
    };
    return badges[role] || <span className="badge bg-secondary">Unknown</span>;
  };

  if (!connected) {
    return (
      <div className="container mt-5">
        <div className="alert alert-warning text-center">
          <h4>Please connect your wallet to view your deals</h4>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="container mt-5 text-center">
        <div className="spinner-border text-success" role="status"></div>
        <p className="mt-3">Loading your deals...</p>
      </div>
    );
  }

  const filteredDeals = getFilteredDeals();

  return (
    <div className="container mt-4">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2 className="text-success">My Deals</h2>
        <div className="btn-group" role="group">
          <button
            type="button"
            className={`btn ${filter === 'all' ? 'btn-success' : 'btn-outline-success'}`}
            onClick={() => setFilter('all')}
          >
            All ({deals.length})
          </button>
          <button
            type="button"
            className={`btn ${filter === 'active' ? 'btn-success' : 'btn-outline-success'}`}
            onClick={() => setFilter('active')}
          >
            Active ({deals.filter(d => d.status < 4).length})
          </button>
          <button
            type="button"
            className={`btn ${filter === 'completed' ? 'btn-success' : 'btn-outline-success'}`}
            onClick={() => setFilter('completed')}
          >
            Completed ({deals.filter(d => d.status >= 4).length})
          </button>
        </div>
      </div>

      {filteredDeals.length === 0 ? (
        <div className="alert alert-info text-center">
          <h5>No deals found</h5>
          <p>
            {filter === 'all' 
              ? "You haven't participated in any deals yet. Create your first donation!"
              : `No ${filter} deals found.`
            }
          </p>
          <a href="/makedeal" className="btn btn-primary mt-2">
            Create Donation
          </a>
        </div>
      ) : (
        <div className="row">
          {filteredDeals.map((deal) => (
            <div key={deal.id} className="col-12 mb-3">
              <div className="card deal-card">
                <div className="card-header d-flex justify-content-between align-items-center">
                  <div>
                    <strong>Deal #{deal.id}</strong>
                    {getRoleBadge(deal.role)}
                    {deal.role === 'unknown' && (
                      <span className="badge bg-secondary ms-2">Not Your Deal</span>
                    )}
                  </div>
                  <span className={`badge bg-${getStatusColor(deal.status)}`}>
                    {getStatusText(deal.status)}
                  </span>
                </div>
                <div className="card-body">
                  <div className="row">
                    <div className="col-md-6">
                      <h6 className="text-success">Deal Information</h6>
                      <table className="table table-sm table-borderless">
                        <tbody>
                          <tr>
                            <td><strong>Food Type:</strong></td>
                            <td>{getFoodTypeText(deal.foodType)}</td>
                          </tr>
                          <tr>
                            <td><strong>Quantity:</strong></td>
                            <td>{deal.quantity} packets</td>
                          </tr>
                          <tr>
                            <td><strong>Weight:</strong></td>
                            <td>{deal.weightKg} kg</td>
                          </tr>
                          <tr>
                            <td><strong>CO₂ Impact:</strong></td>
                            <td className="text-success">{formatCO2(deal.weightKg * 2.5)}</td>
                          </tr>
                          <tr>
                            <td><strong>Location:</strong></td>
                            <td>{deal.location}</td>
                          </tr>
                        </tbody>
                      </table>
                    </div>

                    <div className="col-md-6">
                      <h6 className="text-success">Timeline</h6>
                      <ul className="list-unstyled timeline-list">
                        <li className="mb-2">
                          <i className="bi bi-check-circle-fill text-success"></i>
                          <strong> Created:</strong> {formatDate(deal.createdAt)}
                        </li>
                        
                        {deal.status >= 1 && (
                          <li className="mb-2">
                            <i className="bi bi-check-circle-fill text-success"></i>
                            <strong> Claimed by NGO</strong>
                          </li>
                        )}
                        
                        {deal.status >= 2 && (
                          <li className="mb-2">
                            <i className="bi bi-check-circle-fill text-success"></i>
                            <strong> Picked up by Courier</strong>
                          </li>
                        )}
                        
                        {deal.status >= 3 && (
                          <li className="mb-2">
                            <i className="bi bi-check-circle-fill text-success"></i>
                            <strong> Delivered to NGO</strong>
                          </li>
                        )}
                        
                        {deal.status >= 4 && (
                          <li className="mb-2">
                            <i className="bi bi-trophy-fill text-warning"></i>
                            <strong> Verified & Complete</strong>
                          </li>
                        )}
                      </ul>

                      {/* Action Buttons */}
                      {canConfirmPickup(deal) && (
                        <button
                          className="btn btn-success w-100"
                          onClick={() => handleConfirmPickup(deal.id)}
                          disabled={confirmingId === deal.id}
                        >
                          {confirmingId === deal.id && actionType === 'pickup' ? (
                            <>
                              <span className="spinner-border spinner-border-sm me-2"></span>
                              Confirming...
                            </>
                          ) : (
                            <>
                              <i className="bi bi-truck me-2"></i>
                              Confirm Pickup
                            </>
                          )}
                        </button>
                      )}

                      {canConfirmDelivery(deal) && (
                        <button
                          className="btn btn-success w-100 mb-2"
                          onClick={() => handleConfirmDelivery(deal.id)}
                          disabled={confirmingId === deal.id}
                        >
                          {confirmingId === deal.id && actionType === 'delivery' ? (
                            <>
                              <span className="spinner-border spinner-border-sm me-2"></span>
                              Confirming...
                            </>
                          ) : (
                            <>
                              <i className="bi bi-check2-circle me-2"></i>
                              Confirm Delivery
                            </>
                          )}
                        </button>
                      )}

                      {canConfirmReceipt(deal) && (
                        <button
                          className="btn btn-primary w-100"
                          onClick={() => handleConfirmReceipt(deal.id)}
                          disabled={confirmingId === deal.id}
                        >
                          {confirmingId === deal.id && actionType === 'receipt' ? (
                            <>
                              <span className="spinner-border spinner-border-sm me-2"></span>
                              Confirming...
                            </>
                          ) : (
                            <>
                              <i className="bi bi-check-circle me-2"></i>
                              Confirm Receipt (Final Step!)
                            </>
                          )}
                        </button>
                      )}

                      {/* Show message if no actions available */}
                      {!canConfirmPickup(deal) && !canConfirmDelivery(deal) && !canConfirmReceipt(deal) && deal.status < 5 && (
                        <div className="alert alert-info mb-0">
                          <small>
                            {deal.role === 'restaurant' && deal.status === 2 && 'Waiting for you to confirm pickup...'}
                            {deal.role === 'courier' && deal.status === 3 && 'Waiting for you to confirm delivery...'}
                            {deal.role === 'ngo' && deal.status === 4 && 'Waiting for you to confirm receipt...'}
                            {deal.role === 'unknown' && 'You are not a participant in this donation'}
                            {(deal.role !== 'unknown' && deal.status < 2) && 'Waiting for other parties...'}
                          </small>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Info Box */}
      {deals.length > 0 && (
        <div className="alert alert-light mt-4">
          <h6><i className="bi bi-info-circle me-2"></i>Deal Status Guide</h6>
          <ul className="mb-0">
            <li><strong>Available:</strong> Waiting for NGO to claim</li>
            <li><strong>Claimed:</strong> NGO claimed, waiting for restaurant to confirm pickup</li>
            <li><strong>In Transit:</strong> Courier picked up, waiting for NGO to confirm delivery</li>
            <li><strong>Delivered:</strong> NGO confirmed receipt</li>
            <li><strong>Verified:</strong> Complete! All parties received rewards & NFTs</li>
          </ul>
        </div>
      )}
    </div>
  );
}
