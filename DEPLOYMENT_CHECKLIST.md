# NoWaste Protocol - Deployment Checklist

## 📋 Pre-Deployment Checklist

### Backend (Smart Contracts)
- [ ] All contracts compiled successfully (`forge build`)
- [ ] All tests passing (`forge test`)
- [ ] Security audit completed (or planned)
- [ ] Gas optimization reviewed
- [ ] Contract addresses documented

### Frontend (DApp)
- [ ] All dependencies installed (`npm install`)
- [ ] Environment variables configured (`.env`)
- [ ] Contract addresses updated in `constants.js`
- [ ] Contract ABIs match deployed versions
- [ ] Build successful (`npm run build`)
- [ ] No console errors in development mode

---

## 🚀 Deployment Steps

### Step 1: Deploy Smart Contracts to Polygon Mumbai

```bash
cd backend

# Set environment variables
export PRIVATE_KEY="your_private_key_here"
export MUMBAI_RPC_URL="https://rpc-mumbai.maticvigil.com"
export POLYGONSCAN_API_KEY="your_api_key_here"

# Deploy contracts
forge script script/Deploy.s.sol \
  --rpc-url $MUMBAI_RPC_URL \
  --broadcast \
  --verify \
  -vvvv

# Save deployed addresses
```

**Expected Output:**
```
NoWasteToken deployed at: 0x...
DonationManager deployed at: 0x...
ReputationSystem deployed at: 0x...
ImpactNFT deployed at: 0x...
CarbonCreditRegistry deployed at: 0x...
DAOGovernance deployed at: 0x...
```

### Step 2: Update Frontend Configuration

Edit `frontend/src/utils/constants.js`:

```javascript
export const CONTRACT_ADDRESSES = {
  MUMBAI: {
    NoWasteToken: '0xYOUR_TOKEN_ADDRESS',
    DonationManager: '0xYOUR_DONATION_MANAGER_ADDRESS',
    ReputationSystem: '0xYOUR_REPUTATION_ADDRESS',
    ImpactNFT: '0xYOUR_NFT_ADDRESS',
    CarbonCreditRegistry: '0xYOUR_CARBON_ADDRESS',
    DAOGovernance: '0xYOUR_DAO_ADDRESS'
  }
};
```

### Step 3: Test on Mumbai Testnet

```bash
cd frontend
npm start
```

**Test Scenarios:**
1. [ ] Connect MetaMask wallet
2. [ ] Check dashboard loads with correct balances
3. [ ] Create a test donation (restaurant flow)
4. [ ] Claim a donation (NGO flow)
5. [ ] Confirm pickup/delivery
6. [ ] Verify Impact NFT minting
7. [ ] Check reputation score updates
8. [ ] Test all navigation links

### Step 4: Obtain Test Tokens

```bash
# Get test MATIC
Visit: https://faucet.polygon.technology/

# Get test NOWASTE tokens
# Call your deployed faucet contract or use owner account to transfer
```

### Step 5: Frontend Deployment

#### Option A: Vercel (Recommended)
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd frontend
vercel

# Set environment variables in Vercel dashboard
REACT_APP_CHAIN_ID=80001
```

#### Option B: Netlify
```bash
# Install Netlify CLI
npm i -g netlify-cli

# Build
npm run build

# Deploy
netlify deploy --prod --dir=build
```

#### Option C: GitHub Pages
```bash
# Add to package.json
"homepage": "https://yourusername.github.io/0-waste"

# Deploy
npm run build
npm run deploy
```

---

## 🧪 Testing Checklist

### Wallet Connection
- [ ] MetaMask connects successfully
- [ ] Network switch works (Mumbai ↔ Mainnet)
- [ ] Account change detected
- [ ] Balance displays correctly
- [ ] Disconnect works properly

### Restaurant Flow
- [ ] Can view dashboard
- [ ] Create donation form validates input
- [ ] Token approval transaction works
- [ ] Donation creation transaction succeeds
- [ ] Stake deducted from balance
- [ ] Donation appears in "My Deals"
- [ ] Can confirm pickup
- [ ] Receives tokens + reputation on completion

### NGO Flow
- [ ] Can browse available donations
- [ ] Can claim donation
- [ ] Token approval works
- [ ] Stake deducted correctly
- [ ] Can confirm delivery
- [ ] Receives tokens + reputation

### Courier Flow (Future)
- [ ] Can accept delivery jobs
- [ ] GPS verification works
- [ ] Pickup confirmation
- [ ] Delivery confirmation
- [ ] Earns rewards

### Impact NFT
- [ ] NFT mints successfully
- [ ] Appears in gallery
- [ ] CO₂ calculation correct
- [ ] Metadata displays
- [ ] Can view on PolygonScan

### DAO Governance (Future)
- [ ] Can create proposal
- [ ] Can vote on proposals
- [ ] Voting power calculated correctly
- [ ] Proposal execution works

---

## 🔒 Security Checklist

### Smart Contracts
- [ ] Reentrancy guards in place
- [ ] Access control modifiers used
- [ ] Integer overflow protection (Solidity 0.8+)
- [ ] Input validation on all functions
- [ ] Emergency pause mechanism tested
- [ ] Upgrade path considered
- [ ] Events emitted for all state changes

### Frontend
- [ ] No private keys in code
- [ ] Environment variables used correctly
- [ ] Input sanitization
- [ ] XSS protection
- [ ] HTTPS enforced in production
- [ ] No sensitive data in localStorage
- [ ] Transaction confirmations required

---

## 📊 Post-Deployment Monitoring

### Metrics to Track
- [ ] Total donations created
- [ ] Total donations completed
- [ ] Active users (wallets)
- [ ] Total CO₂ prevented
- [ ] Token circulation
- [ ] Gas costs per transaction
- [ ] Contract errors/reverts

### Tools
- **PolygonScan**: Monitor contract transactions
- **The Graph**: Index blockchain data (future)
- **Google Analytics**: Track dApp usage
- **Sentry**: Error monitoring
- **Mixpanel**: User behavior analytics

---

## 🐛 Common Issues & Solutions

### Issue: "Insufficient funds for gas"
**Solution**: Ensure you have enough MATIC for gas fees (~0.01 MATIC per transaction)

### Issue: "Transaction reverted without a reason"
**Solution**: Check token balance and allowance. Verify you have enough tokens staked.

### Issue: "Wrong network"
**Solution**: Switch MetaMask to Polygon Mumbai (Chain ID: 80001)

### Issue: "Contract not deployed"
**Solution**: Verify contract addresses in `constants.js` match deployment

### Issue: "Token approval fails"
**Solution**: Check token contract address. Ensure you have tokens to approve.

---

## 📝 Maintenance Tasks

### Weekly
- [ ] Monitor transaction volumes
- [ ] Check for contract errors
- [ ] Review gas optimization opportunities
- [ ] Update documentation as needed

### Monthly
- [ ] Security audit updates
- [ ] Performance optimization
- [ ] User feedback collection
- [ ] Feature prioritization

### Quarterly
- [ ] Smart contract upgrades (if needed)
- [ ] Frontend redesign (if needed)
- [ ] Tokenomics review
- [ ] Governance proposals

---

## 🎯 Success Metrics

### Phase 1 (Testnet - Month 1-2)
- ✅ 50+ test transactions
- ✅ 10+ active testers
- ✅ All user flows working
- ✅ No critical bugs

### Phase 2 (Mainnet Launch - Month 3)
- ✅ 100+ users
- ✅ 500+ donations
- ✅ $10k+ in token value
- ✅ 1000+ kg CO₂ prevented

### Phase 3 (Growth - Month 6)
- ✅ 1000+ users
- ✅ 5000+ donations
- ✅ $100k+ market cap
- ✅ 10,000+ kg CO₂ prevented

---

## 📞 Support & Resources

### Development
- Solidity Docs: https://docs.soliditylang.org/
- Foundry Book: https://book.getfoundry.sh/
- Ethers.js: https://docs.ethers.org/
- React: https://react.dev/

### Polygon Network
- Polygon Docs: https://docs.polygon.technology/
- Mumbai Faucet: https://faucet.polygon.technology/
- PolygonScan: https://mumbai.polygonscan.com/

### Community
- GitHub Issues: https://github.com/orangesantra/0-waste/issues
- Discord: Coming soon
- Twitter: @NoWasteProtocol

---

**Last Updated**: December 13, 2025  
**Version**: 1.0.0  
**Status**: Ready for Testnet Deployment 🚀
