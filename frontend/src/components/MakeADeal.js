import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useWeb3 } from '../context/Web3Context';
import { toast } from 'react-toastify';
import { 
  parseTokenAmount, 
  formatTokenAmount, 
  handleTxError,
  getExplorerUrl 
} from '../utils/helpers';
import { STAKE_AMOUNTS, FOOD_TYPES } from '../utils/constants';

export default function MakeADeal() {
  const navigate = useNavigate();
  const { account, connected, contracts, chainId } = useWeb3();
  
  const [loading, setLoading] = useState(false);
  const [userBalance, setUserBalance] = useState('0');
  const [formData, setFormData] = useState({
    restaurantName: '',
    contactNumber: '',
    foodType: FOOD_TYPES.VEG,
    quantity: '',
    weightKg: '',
    location: '',
    expiryHours: '24'
  });

  useEffect(() => {
    if (connected && contracts.noWasteToken) {
      fetchBalance();
    }
  }, [connected, contracts]);

  const fetchBalance = async () => {
    try {
      const balance = await contracts.noWasteToken.balanceOf(account);
      setUserBalance(formatTokenAmount(balance));
    } catch (error) {
      console.error('Error fetching balance:', error);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const getCurrentLocation = () => {
    if (navigator.geolocation) {
      toast.info('Getting your location...');
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const location = `${position.coords.latitude.toFixed(6)}, ${position.coords.longitude.toFixed(6)}`;
          setFormData(prev => ({ ...prev, location }));
          toast.success('Location captured!');
        },
        (error) => {
          console.error('Error getting location:', error);
          toast.error('Failed to get location. Please enter manually.');
        }
      );
    } else {
      toast.error('Geolocation is not supported by your browser');
    }
  };

  const validateForm = () => {
    if (!formData.restaurantName.trim()) {
      toast.error('Please enter restaurant name');
      return false;
    }
    if (!formData.contactNumber.trim()) {
      toast.error('Please enter contact number');
      return false;
    }
    if (!formData.quantity || formData.quantity <= 0) {
      toast.error('Please enter valid quantity');
      return false;
    }
    if (!formData.weightKg || formData.weightKg <= 0) {
      toast.error('Please enter valid weight');
      return false;
    }
    if (!formData.location.trim()) {
      toast.error('Please enter location or use GPS');
      return false;
    }
    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!connected) {
      toast.error('Please connect your wallet first');
      return;
    }

    if (!validateForm()) {
      return;
    }

    try {
      setLoading(true);

      // Check balance
      const requiredStake = parseTokenAmount(STAKE_AMOUNTS.RESTAURANT);
      const balance = await contracts.noWasteToken.balanceOf(account);
      
      if (balance < requiredStake) {
        toast.error(`Insufficient balance. You need ${STAKE_AMOUNTS.RESTAURANT} NOWASTE tokens to create a donation.`);
        setLoading(false);
        return;
      }

      // Check allowance
      const allowance = await contracts.noWasteToken.allowance(
        account,
        contracts.donationManager.target
      );

      // Step 1: Approve tokens if needed
      if (allowance < requiredStake) {
        toast.info(`Approving ${STAKE_AMOUNTS.RESTAURANT} NOWASTE tokens...`);
        const approveTx = await contracts.noWasteToken.approve(
          contracts.donationManager.target,
          requiredStake
        );
        
        const approveReceipt = await approveTx.wait();
        toast.success('Tokens approved!');
        
        // Show transaction link
        const explorerUrl = getExplorerUrl(chainId, approveReceipt.hash);
        console.log('Approval tx:', explorerUrl);
      }

      // Step 2: Create donation
      toast.info('Creating donation listing...');
      
      // Calculate expiry timestamp
      const expiryTime = Math.floor(Date.now() / 1000) + (parseInt(formData.expiryHours) * 3600);
      
      const createTx = await contracts.donationManager.createDonation(
        formData.foodType,
        formData.quantity,
        formData.weightKg,
        formData.location,
        expiryTime
      );

      const receipt = await createTx.wait();
      
      // Extract donation ID from event logs
      const donationCreatedEvent = receipt.logs.find(
        log => log.eventName === 'DonationCreated'
      );
      
      let donationId = 'N/A';
      if (donationCreatedEvent) {
        donationId = donationCreatedEvent.args[0].toString();
      }

      toast.success(`Donation #${donationId} created successfully! 🎉`);
      
      // Show transaction link
      const explorerUrl = getExplorerUrl(chainId, receipt.hash);
      console.log('Creation tx:', explorerUrl);

      // Reset form
      setFormData({
        restaurantName: '',
        contactNumber: '',
        foodType: FOOD_TYPES.VEG,
        quantity: '',
        weightKg: '',
        location: '',
        expiryHours: '24'
      });

      // Navigate to dashboard after 2 seconds
      setTimeout(() => {
        navigate('/mydeals');
      }, 2000);

    } catch (error) {
      console.error('Error creating donation:', error);
      toast.error(handleTxError(error));
    } finally {
      setLoading(false);
    }
  };

  if (!connected) {
    return (
      <div className="container mt-5">
        <div className="alert alert-warning text-center">
          <h4>Please connect your wallet to create a donation</h4>
          <p>Use the "Connect Wallet" button in the navigation bar</p>
        </div>
      </div>
    );
  }

  const hasEnoughBalance = parseFloat(userBalance) >= parseFloat(STAKE_AMOUNTS.RESTAURANT);

  return (
    <div className="container mt-4">
      <div className="row justify-content-center">
        <div className="col-md-8">
          <div className="card">
            <div className="card-header bg-success text-white">
              <h4 className="mb-0">Create Food Donation</h4>
            </div>
            <div className="card-body">
              {/* Stake Info Alert */}
              <div className={`alert ${hasEnoughBalance ? 'alert-info' : 'alert-danger'}`}>
                <h6 className="alert-heading">
                  <i className="bi bi-info-circle me-2"></i>
                  Staking Requirement
                </h6>
                <p className="mb-2">
                  <strong>Required Stake:</strong> {STAKE_AMOUNTS.RESTAURANT} NOWASTE tokens (refundable)
                </p>
                <p className="mb-0">
                  <strong>Your Balance:</strong> {parseFloat(userBalance).toFixed(2)} NOWASTE
                  {!hasEnoughBalance && (
                    <span className="text-danger ms-2">
                      ⚠️ Insufficient balance
                    </span>
                  )}
                </p>
              </div>

              <form onSubmit={handleSubmit}>
                {/* Restaurant Details */}
                <h5 className="text-success mb-3">Restaurant Details</h5>
                
                <div className="mb-3">
                  <label htmlFor="restaurantName" className="form-label">
                    Restaurant / Shop Name *
                  </label>
                  <input
                    type="text"
                    className="form-control"
                    id="restaurantName"
                    name="restaurantName"
                    value={formData.restaurantName}
                    onChange={handleInputChange}
                    placeholder="Enter restaurant name"
                    required
                  />
                </div>

                <div className="mb-3">
                  <label htmlFor="contactNumber" className="form-label">
                    Contact Number *
                  </label>
                  <input
                    type="tel"
                    className="form-control"
                    id="contactNumber"
                    name="contactNumber"
                    value={formData.contactNumber}
                    onChange={handleInputChange}
                    placeholder="Enter contact number"
                    required
                  />
                </div>

                <hr />

                {/* Food Details */}
                <h5 className="text-success mb-3">Food Details</h5>

                <div className="mb-3">
                  <label htmlFor="foodType" className="form-label">
                    Food Type *
                  </label>
                  <select
                    className="form-select"
                    id="foodType"
                    name="foodType"
                    value={formData.foodType}
                    onChange={handleInputChange}
                    required
                  >
                    <option value={FOOD_TYPES.VEG}>Vegetarian</option>
                    <option value={FOOD_TYPES.NON_VEG}>Non-Vegetarian</option>
                    <option value={FOOD_TYPES.BOTH}>Both</option>
                  </select>
                </div>

                <div className="row">
                  <div className="col-md-6 mb-3">
                    <label htmlFor="quantity" className="form-label">
                      Quantity (packets) *
                    </label>
                    <input
                      type="number"
                      className="form-control"
                      id="quantity"
                      name="quantity"
                      value={formData.quantity}
                      onChange={handleInputChange}
                      placeholder="Number of food packets"
                      min="1"
                      required
                    />
                  </div>

                  <div className="col-md-6 mb-3">
                    <label htmlFor="weightKg" className="form-label">
                      Weight (kg) *
                    </label>
                    <input
                      type="number"
                      className="form-control"
                      id="weightKg"
                      name="weightKg"
                      value={formData.weightKg}
                      onChange={handleInputChange}
                      placeholder="Total weight in kg"
                      min="0.1"
                      step="0.1"
                      required
                    />
                    <small className="text-muted">
                      CO₂ prevented: {(formData.weightKg * 2.5 || 0).toFixed(2)} kg
                    </small>
                  </div>
                </div>

                <hr />

                {/* Location & Expiry */}
                <h5 className="text-success mb-3">Location & Timing</h5>

                <div className="mb-3">
                  <label htmlFor="location" className="form-label">
                    Pickup Location *
                  </label>
                  <div className="input-group">
                    <input
                      type="text"
                      className="form-control"
                      id="location"
                      name="location"
                      value={formData.location}
                      onChange={handleInputChange}
                      placeholder="Enter address or use GPS"
                      required
                    />
                    <button
                      type="button"
                      className="btn btn-outline-primary"
                      onClick={getCurrentLocation}
                    >
                      <i className="bi bi-geo-alt-fill"></i> Use GPS
                    </button>
                  </div>
                  <small className="text-muted">
                    GPS coordinates or full address
                  </small>
                </div>

                <div className="mb-3">
                  <label htmlFor="expiryHours" className="form-label">
                    Available For (hours) *
                  </label>
                  <select
                    className="form-select"
                    id="expiryHours"
                    name="expiryHours"
                    value={formData.expiryHours}
                    onChange={handleInputChange}
                    required
                  >
                    <option value="6">6 hours</option>
                    <option value="12">12 hours</option>
                    <option value="24">24 hours (recommended)</option>
                    <option value="48">48 hours</option>
                  </select>
                </div>

                {/* Summary Box */}
                <div className="alert alert-light border">
                  <h6 className="mb-2">Summary</h6>
                  <ul className="mb-0">
                    <li>You will stake <strong>{STAKE_AMOUNTS.RESTAURANT} NOWASTE</strong> (refundable)</li>
                    <li>Base reward: <strong>100 NOWASTE</strong> + reputation bonus</li>
                    <li>Environmental impact: <strong>{(formData.weightKg * 2.5 || 0).toFixed(2)} kg CO₂</strong> prevented</li>
                    <li>You will receive an <strong>Impact NFT</strong> certificate</li>
                  </ul>
                </div>

                {/* Submit Button */}
                <div className="d-grid gap-2">
                  <button
                    type="submit"
                    className="btn btn-success btn-lg"
                    disabled={loading || !hasEnoughBalance}
                  >
                    {loading ? (
                      <>
                        <span className="spinner-border spinner-border-sm me-2"></span>
                        Creating Donation...
                      </>
                    ) : (
                      <>
                        <i className="bi bi-check-circle me-2"></i>
                        Create Donation
                      </>
                    )}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
