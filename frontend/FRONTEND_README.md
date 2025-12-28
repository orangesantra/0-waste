# NoWaste Protocol - Frontend DApp

A decentralized application for the NoWaste Protocol, enabling transparent food waste management through blockchain technology.

## 🚀 Features Implemented

### ✅ Core Infrastructure
- **Web3 Integration**: Full MetaMask wallet connection with multi-chain support
- **Smart Contract Interaction**: Integrated with all 6 core contracts
- **React Context API**: Centralized Web3 state management
- **Toast Notifications**: User-friendly transaction feedback

### ✅ User Interface Components

#### 1. **Navbar**
- MetaMask wallet connection/disconnection
- Network indicator (Polygon Mumbai/Mainnet)
- Responsive navigation menu
- Protected routes (requires wallet connection)

#### 2. **Home Page**
- Hero section with protocol overview
- Platform statistics display
- How It Works section (Restaurant/NGO/Courier flows)
- Tokenomics explanation
- Environmental impact showcase
- Call-to-action sections

#### 3. **Dashboard**
- Token balance (available & staked)
- Reputation score with tier system (Bronze/Silver/Gold/Platinum)
- Impact NFT count
- Total CO₂ prevented
- Deal statistics (success rate, consecutive wins)
- Quick action buttons

#### 4. **Available Deals**
- Browse all active donation listings
- Filter by food type, location, expiry
- Claim donations (NGO feature)
- Auto token approval flow
- Real-time status updates

#### 5. **My Deals**
- View user's donation history
- Track deal status (Listed → Claimed → Delivered → Verified)
- Confirm pickup/delivery actions
- Transaction history

#### 6. **Create Donation (Make a Deal)**
- Form for restaurant owners
- Token staking requirement display
- Food type selection (Veg/Non-veg)
- Quantity and weight inputs
- GPS location capture
- Smart contract submission

#### 7. **Impact NFT Gallery**
- Display all user's Impact NFTs
- Show CO₂ prevented per NFT
- Total environmental impact calculation
- NFT metadata viewer
- Download certificate feature (coming soon)

## 📦 Dependencies

```json
{
  "ethers": "^6.9.0",
  "web3modal": "^1.9.12",
  "@web3modal/ethers": "^4.0.0",
  "react": "^18.2.0",
  "react-router-dom": "^6.16.0",
  "react-toastify": "^9.1.3",
  "recharts": "^2.10.0",
  "axios": "^1.6.0"
}
```

## 🛠️ Setup Instructions

### 1. Install Dependencies
```bash
cd frontend
npm install
```

### 2. Configure Contract Addresses
After deploying smart contracts, update `src/utils/constants.js`:

```javascript
export const CONTRACT_ADDRESSES = {
  MUMBAI: {
    NoWasteToken: '0xYourTokenAddress',
    DonationManager: '0xYourDonationManagerAddress',
    // ... other contracts
  }
};
```

### 3. Environment Variables (Optional)
Create `.env` file:
```
REACT_APP_API_URL=http://localhost:3001
REACT_APP_CHAIN_ID=80001
```

### 4. Start Development Server
```bash
npm start
```

The app will open at `http://localhost:3000`

## 🔗 Smart Contract Integration

### Contracts Used

1. **NoWasteToken** (`NoWasteToken.sol`)
   - Token balance queries
   - Staking/unstaking
   - Approval for spending

2. **DonationManager** (`DonationManager.sol`)
   - Create donations
   - Claim donations
   - Confirm pickup/delivery
   - Fetch available/user deals

3. **ReputationSystem** (`ReputationSystem.sol`)
   - Get user reputation score
   - Calculate reward multipliers
   - Fetch tier information

4. **ImpactNFT** (`ImpactNFT.sol`)
   - Mint Impact NFTs
   - Fetch user's NFT collection
   - Get NFT metadata

5. **CarbonCreditRegistry** (`CarbonCreditRegistry.sol`)
   - Track carbon credits
   - Calculate CO₂ prevented

6. **DAOGovernance** (`DAOGovernance.sol`)
   - Create proposals
   - Vote on governance decisions

## 🎨 Styling & Theme

- **Color Scheme**: Green gradient (environmental theme)
- **Primary**: #28a745 (Success Green)
- **Secondary**: #20c997 (Teal)
- **Accent**: #ffc107 (Warning Yellow)

### CSS Architecture
- **App.css**: Global styles, theme colors, utilities
- **Component-specific**: Inline styles and Bootstrap classes
- **Responsive**: Mobile-first approach

## 📱 User Flows

### Restaurant Owner Flow
1. Connect wallet
2. Go to "Create Donation"
3. Fill form (food type, quantity, location)
4. Stake 1000 NOWASTE tokens
5. Submit donation listing
6. Confirm pickup when courier arrives
7. Receive tokens + reputation + Impact NFT

### NGO Flow
1. Connect wallet
2. Browse "Available Deals"
3. Claim desired donation
4. Stake 500 NOWASTE tokens
5. Wait for courier pickup
6. Confirm delivery receipt
7. Receive tokens + reputation

### Courier Flow
1. Connect wallet
2. Accept delivery job
3. Stake 750 NOWASTE tokens
4. Pick up from restaurant
5. Deliver to NGO
6. Get both confirmations
7. Receive tokens + reputation

## 🔐 Security Features

- **Wallet-only access**: No username/password
- **Token approval flow**: User controls contract spending
- **Transaction confirmation**: Etherscan links for transparency
- **Stake requirements**: Prevents spam and fraud
- **Multi-signature verification**: Restaurant + NGO + Courier confirmations

## 🌐 Network Support

### Polygon Mumbai Testnet (Default)
- **Chain ID**: 80001
- **RPC**: https://rpc-mumbai.maticvigil.com
- **Explorer**: https://mumbai.polygonscan.com

### Polygon Mainnet
- **Chain ID**: 137
- **RPC**: https://polygon-rpc.com
- **Explorer**: https://polygonscan.com

## 📊 State Management

### Web3Context
Provides:
- `account`: Connected wallet address
- `chainId`: Current network
- `contracts`: All contract instances
- `connected`: Connection status
- `connectWallet()`: Connect MetaMask
- `disconnectWallet()`: Disconnect
- `switchNetwork()`: Change blockchain

## 🧪 Testing Checklist

### Before Deployment
- [ ] Update all contract addresses in `constants.js`
- [ ] Test wallet connection on Mumbai testnet
- [ ] Verify all smart contract interactions
- [ ] Test token approval flows
- [ ] Check reputation calculation display
- [ ] Validate NFT minting and display
- [ ] Test responsive design (mobile/tablet)
- [ ] Verify toast notifications work
- [ ] Check error handling for failed transactions

### MetaMask Setup for Testing
1. Add Polygon Mumbai network
2. Get testnet MATIC from faucet: https://faucet.polygon.technology/
3. Obtain test NOWASTE tokens (from your deployed faucet contract)
4. Test all user flows

## 🚧 TODO / Future Enhancements

### Remaining Work
- [ ] Refactor MyDeals component with blockchain data
- [ ] Refactor MakeADeal with GPS integration
- [ ] Add IPFS upload for delivery proof photos
- [ ] Implement proposal voting UI (DAO Governance)
- [ ] Add charts for analytics (using recharts)
- [ ] Create admin dashboard
- [ ] Add search/filter functionality
- [ ] Implement pagination for deals list

### Nice-to-Have Features
- [ ] Multi-language support (i18n)
- [ ] Dark mode toggle
- [ ] Push notifications (web push)
- [ ] QR code scanning for delivery
- [ ] Integration with Google Maps API
- [ ] Export transaction history (CSV)
- [ ] NFT marketplace integration
- [ ] Social sharing features

## 📄 File Structure

```
frontend/
├── public/
│   ├── index.html
│   └── manifest.json
├── src/
│   ├── components/
│   │   ├── Navbar.js              ✅ Refactored
│   │   ├── Home.js                ✅ Refactored
│   │   ├── Dashboard.js           ✅ New
│   │   ├── MakeADeal.js           ⚠️ Needs refactoring
│   │   ├── MyDeals.js             ⚠️ Needs refactoring
│   │   ├── AvailableDeals.js      ✅ New
│   │   └── ImpactNFTGallery.js    ✅ New
│   ├── context/
│   │   └── Web3Context.js         ✅ New
│   ├── utils/
│   │   ├── constants.js           ✅ New
│   │   ├── contractABIs.js        ✅ New
│   │   └── helpers.js             ✅ New
│   ├── App.js                     ✅ Updated
│   ├── App.css                    ✅ Updated
│   └── index.js
├── package.json                   ✅ Updated
└── README.md                      ✅ This file
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📞 Support

For issues or questions:
- GitHub Issues: https://github.com/orangesantra/0-waste/issues
- Email: hello@nowaste.protocol (placeholder)
- Discord: https://discord.gg/nowaste (coming soon)

## 📝 License

This project is part of NoWaste Protocol. See LICENSE file for details.

---

**Built with ❤️ for a sustainable future** 🌱
