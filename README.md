# NoWaste Protocol - Frontend DApp

A decentralized application for the NoWaste Protocol, enabling transparent food waste management in decentralized way.

## Features Implemented

### Core Infrastructure
- **Web3 Integration**: Full MetaMask wallet connection with multi-chain support
- **Smart Contract Interaction**: Integrated with all 6 core contracts
- **React Context API**: Centralized Web3 state management
- **Toast Notifications**: User-friendly transaction feedback

### User Interface Components

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

## User Flow Diagram

```mermaid
flowchart TD
    Start([User Arrives]) --> Connect[Connect Wallet]
    Connect --> Role{Select Role}
    
    Role -->|Restaurant| RestaurantFlow
    Role -->|NGO| NGOFlow
    Role -->|Courier| CourierFlow
    
    RestaurantFlow[Create Donation] --> Stake1[Stake 1000 NOWASTE]
    Stake1 --> Submit[Submit Listing]
    Submit --> Wait1[Wait for Claim]
    Wait1 --> PickupConfirm[Confirm Pickup]
    PickupConfirm --> Reward1[Receive 100 tokens + NFT]
    
    NGOFlow[Browse Donations] --> Claim[Claim Donation]
    Claim --> Stake2[Stake 500 NOWASTE]
    Stake2 --> Wait2[Wait for Delivery]
    Wait2 --> DeliveryConfirm[Confirm Delivery]
    DeliveryConfirm --> Reward2[Receive 50 tokens]
    
    CourierFlow[Accept Job] --> Stake3[Stake 750 NOWASTE]
    Stake3 --> Pickup[Pickup from Restaurant]
    Pickup --> Deliver[Deliver to NGO]
    Deliver --> Reward3[Receive 75+ tokens]
    
    Reward1 --> Dashboard[View Dashboard]
    Reward2 --> Dashboard
    Reward3 --> Dashboard
```

## Smart Contract Interaction Flow

```mermaid
sequenceDiagram
    participant R as Restaurant
    participant F as Frontend
    participant W as Wallet
    participant DM as DonationManager
    participant TK as NoWasteToken
    participant RS as ReputationSystem
    participant NFT as ImpactNFT
    
    R->>F: Create Donation
    F->>W: Request Connection
    W-->>F: Connected
    
    F->>TK: Check Balance
    TK-->>F: Balance: 5000 NOWASTE
    
    F->>W: Request Approval (1000 tokens)
    W->>R: Sign Transaction?
    R->>W: Approve
    W->>TK: approve(DonationManager, 1000)
    TK-->>F: Approval Successful
    
    F->>W: Request Create Donation
    W->>R: Sign Transaction?
    R->>W: Approve
    W->>DM: createDonation(details)
    
    DM->>TK: transferFrom(restaurant, DM, 1000)
    DM->>RS: updateReputation(restaurant, +10)
    DM-->>F: Donation Created (ID: 1)
    
    Note over F: NGO claims donation...
    Note over F: Courier delivers...
    
    DM->>DM: completeDonation(1)
    DM->>NFT: mintImpactCertificate(restaurant)
    NFT-->>DM: NFT Minted (Token ID: 1)
    DM->>TK: transfer(restaurant, 100)
    DM->>RS: updateReputation(restaurant, +50)
    
    DM-->>F: Transaction Complete
    F->>R: Display Success + NFT
```
