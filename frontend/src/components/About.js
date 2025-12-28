import React from 'react';

const About = () => {
  return (
    <div className="about-page">
      {/* How It Works - User Flow Section */}
      <section className="container my-5">
        <div className="text-center mb-5">
          <h1 className="display-3 text-green mb-3">How NoWaste Works</h1>
          <p className="lead text-muted">Simple 5-step process from surplus to impact</p>
        </div>

        {/* Flow Diagram */}
        <div className="row mb-5">
          <div className="col-12">
            <div className="flow-container" style={{
              display: 'flex',
              justifyContent: 'space-around',
              alignItems: 'center',
              flexWrap: 'wrap',
              padding: '30px 0',
              background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
              borderRadius: '15px',
              color: 'white'
            }}>
              <div className="flow-step text-center" style={{ flex: '1', minWidth: '150px', padding: '10px' }}>
                <div style={{ fontSize: '3rem' }}>🍽️</div>
                <h5 style={{ fontWeight: 'bold', marginTop: '10px' }}>Restaurant</h5>
                <p style={{ fontSize: '0.9rem', margin: '5px 0' }}>Lists Surplus</p>
              </div>
              
              <div style={{ fontSize: '2rem', color: 'white' }}>→</div>
              
              <div className="flow-step text-center" style={{ flex: '1', minWidth: '150px', padding: '10px' }}>
                <div style={{ fontSize: '3rem' }}>🤝</div>
                <h5 style={{ fontWeight: 'bold', marginTop: '10px' }}>NGO</h5>
                <p style={{ fontSize: '0.9rem', margin: '5px 0' }}>Claims Food</p>
              </div>
              
              <div style={{ fontSize: '2rem', color: 'white' }}>→</div>
              
              <div className="flow-step text-center" style={{ flex: '1', minWidth: '150px', padding: '10px' }}>
                <div style={{ fontSize: '3rem' }}>🚚</div>
                <h5 style={{ fontWeight: 'bold', marginTop: '10px' }}>Courier</h5>
                <p style={{ fontSize: '0.9rem', margin: '5px 0' }}>Delivers</p>
              </div>
              
              <div style={{ fontSize: '2rem', color: 'white' }}>→</div>
              
              <div className="flow-step text-center" style={{ flex: '1', minWidth: '150px', padding: '10px' }}>
                <div style={{ fontSize: '3rem' }}>🎫</div>
                <h5 style={{ fontWeight: 'bold', marginTop: '10px' }}>NFT Minted</h5>
                <p style={{ fontSize: '0.9rem', margin: '5px 0' }}>Impact Proof</p>
              </div>
              
              <div style={{ fontSize: '2rem', color: 'white' }}>→</div>
              
              <div className="flow-step text-center" style={{ flex: '1', minWidth: '150px', padding: '10px' }}>
                <div style={{ fontSize: '3rem' }}>🛒</div>
                <h5 style={{ fontWeight: 'bold', marginTop: '10px' }}>Marketplace</h5>
                <p style={{ fontSize: '0.9rem', margin: '5px 0' }}>Users Buy</p>
              </div>
            </div>
          </div>
        </div>

        {/* Simple Step Headlines */}
        <div className="row g-4 mb-5">
          <div className="col-md-12">
            <div className="card border-success">
              <div className="card-header bg-success text-white">
                <h4 className="mb-0">📋 User Flow</h4>
              </div>
              <div className="card-body">
                <div className="timeline">
                  {/* Step 1 */}
                  <div className="timeline-item mb-3" style={{ borderLeft: '3px solid #28a745', paddingLeft: '20px' }}>
                    <div className="d-flex align-items-start">
                      <div style={{ fontSize: '2rem', marginRight: '15px' }}>🍽️</div>
                      <div>
                        <h5 className="text-success mb-1">Restaurant Lists Surplus</h5>
                        <p className="text-muted mb-0">Stake tokens → Create listing → Earn 100 tokens on completion</p>
                      </div>
                    </div>
                  </div>

                  {/* Step 2 */}
                  <div className="timeline-item mb-3" style={{ borderLeft: '3px solid #17a2b8', paddingLeft: '20px' }}>
                    <div className="d-flex align-items-start">
                      <div style={{ fontSize: '2rem', marginRight: '15px' }}>🤝</div>
                      <div>
                        <h5 className="text-info mb-1">NGO Claims Donation</h5>
                        <p className="text-muted mb-0">Browse deals → Claim food → Earn 50 tokens</p>
                      </div>
                    </div>
                  </div>

                  {/* Step 3 */}
                  <div className="timeline-item mb-3" style={{ borderLeft: '3px solid #ffc107', paddingLeft: '20px' }}>
                    <div className="d-flex align-items-start">
                      <div style={{ fontSize: '2rem', marginRight: '15px' }}>🚚</div>
                      <div>
                        <h5 className="text-warning mb-1">Courier Delivers</h5>
                        <p className="text-muted mb-0">Pickup from restaurant → Deliver to NGO → Earn 75+ tokens</p>
                      </div>
                    </div>
                  </div>

                  {/* Step 4 */}
                  <div className="timeline-item mb-3" style={{ borderLeft: '3px solid #dc3545', paddingLeft: '20px' }}>
                    <div className="d-flex align-items-start">
                      <div style={{ fontSize: '2rem', marginRight: '15px' }}>🎫</div>
                      <div>
                        <h5 className="text-danger mb-1">NFT Certificate Minted</h5>
                        <p className="text-muted mb-0">Automatic minting → Stores CO₂ impact → Tradeable on marketplace</p>
                      </div>
                    </div>
                  </div>

                  {/* Step 5 */}
                  <div className="timeline-item mb-3" style={{ borderLeft: '3px solid #6f42c1', paddingLeft: '20px' }}>
                    <div className="d-flex align-items-start">
                      <div style={{ fontSize: '2rem', marginRight: '15px' }}>🛒</div>
                      <div>
                        <h5 className="text-purple mb-1">Marketplace Trading</h5>
                        <p className="text-muted mb-0">List NFT → Community buys → Buyers earn rewards → Option to retire for carbon offset</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Role Cards - Simplified */}
        <div className="text-center mb-4">
          <h2 className="display-5 text-green">Participants</h2>
        </div>

        <div className="row g-3 mb-5">
          {/* Restaurant */}
          <div className="col-md-3">
            <div className="card h-100 text-center border-success">
              <div className="card-body">
                <div style={{ fontSize: '2.5rem' }} className="mb-2">🍽️</div>
                <h5 className="card-title text-success">Restaurants</h5>
                <p className="small mb-0">Earn tokens + NFTs</p>
              </div>
            </div>
          </div>

          {/* NGO */}
          <div className="col-md-3">
            <div className="card h-100 text-center border-info">
              <div className="card-body">
                <div style={{ fontSize: '2.5rem' }} className="mb-2">🤝</div>
                <h5 className="card-title text-info">NGOs</h5>
                <p className="small mb-0">Free food + Rewards</p>
              </div>
            </div>
          </div>

          {/* Courier */}
          <div className="col-md-3">
            <div className="card h-100 text-center border-warning">
              <div className="card-body">
                <div style={{ fontSize: '2.5rem' }} className="mb-2">🚚</div>
                <h5 className="card-title text-warning">Couriers</h5>
                <p className="small mb-0">Delivery rewards</p>
              </div>
            </div>
          </div>

          {/* Community */}
          <div className="col-md-3">
            <div className="card h-100 text-center border-primary">
              <div className="card-body">
                <div style={{ fontSize: '2.5rem' }} className="mb-2">🌍</div>
                <h5 className="card-title text-primary">Community</h5>
                <p className="small mb-0">Buy & retire NFTs</p>
              </div>
            </div>
          </div>
        </div>

        {/* Why NoWaste Section - Simplified */}
        <div className="row mb-5">
          <div className="col-12">
            <div className="card border-0 shadow">
              <div className="card-body p-4" style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', color: 'white', borderRadius: '15px' }}>
                <h3 className="text-center mb-3">Why NoWaste?</h3>
                <div className="row text-center">
                  <div className="col-md-3">
                    <h5>🔗</h5>
                    <p className="mb-0">Blockchain Verified</p>
                  </div>
                  <div className="col-md-3">
                    <h5>🎁</h5>
                    <p className="mb-0">Token Rewards</p>
                  </div>
                  <div className="col-md-3">
                    <h5>🎫</h5>
                    <p className="mb-0">NFT Certificates</p>
                  </div>
                  <div className="col-md-3">
                    <h5>🌱</h5>
                    <p className="mb-0">Real Impact</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default About;
