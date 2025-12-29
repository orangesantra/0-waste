# Deployed Contracts - VeryChain Mainnet

## Network Information
- **Network**: VeryChain Mainnet
- **Chain ID**: 4613 (0x1205 in hex)
- **RPC URL**: https://rpc.verylabs.io
- **Block Explorer**: https://veryscan.io/
- **Deployment Date**: December 28, 2025

## Deployer Wallet
- **Address**: `0x70234aE0AaB5E47dB123B6176d70CaDBa925b432`

## Active Contracts (Latest)

### 1. NoWasteToken (ERC-20)
- **Address**: `0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9`
- **Status**:  Active
- **Total Supply**: 1,000,000,000 NOWASTE
- **Features**: Staking, burning, role-based transfers

### 2. DonationManager (Core Logic)
- **Address**: `0x8cae686969Ca2329656CED848dc4b42E6C594bBb`  **NEW - Dec 28, 2025**
- **Status**:  Active
- **Balance**: 100,000,000 NOWASTE tokens
- **Features**: Donation lifecycle, rewards, **NFT minting integrated**
- **Deployment Transaction**: `0x89f2c2702038dca4894ce2532002f4403acd00275684b7e1c1939c7201f4644a`
- **Gas Used**: 3,180,166

### 3. ReputationSystem (Scoring)
- **Address**: `0x3B3052A9A2D34F3179A92c0CC33bA154Aa0eF495`
- **Status**:  Active
- **Features**: User reputation tracking, multipliers, penalties

### 4. ImpactNFT (ERC-721)
- **Address**: `0xCD05E4b28fd2608830ac14f6f509a11d590A78FA`
- **Status**:  Active
- **Features**: Impact certificates, CO2 tracking, metadata storage

### 5. CarbonCreditRegistry (Marketplace)
- **Address**: `0x0410bd7cA7C47Adb4F1522eE2843f699D39cA03A`
- **Status**:  Active
- **Features**: Carbon credit generation, trading, retirement

### 6. DAOGovernance (Governance)
- **Address**: `0xA2Ec8265B755eBC9B60B2AF7C54f665f5E0f78Fa`
- **Status**:  Active
- **Features**: Proposals, voting, treasury management

### 7. TokenFaucet (Testing Utility)
- **Address**: `0xd459E589cc0F0b8537b1Cccb99e96ef438eb7A32`
- **Status**:  Active
- **Balance**: 100,000 NOWASTE tokens
- **Claim Amount**: 3,000 NOWASTE per user (one-time)

### 8. CertificateMarketplace (User Compensation System)  NEW
- **Address**: `0xB368485b6c747Dc98db9Cfaa3806cA3692192596`
- **Status**:  Active
- **Balance**: 10,000,000 NOWASTE tokens (for buyer rewards)
- **Features**: NFT certificate marketplace, buyer rewards, dynamic pricing, auto-redemption
- **Deployment Date**: December 28, 2025
- **Gas Used**: 2,434,054

### 9. CertificateTreasury (Liquidity Pool)  NEW
- **Address**: `0xC3F86FFA5126D1f67f568D5804dAbBE043C35De1`
- **Status**:  Active
- **Balance**: 50,000,000 NOWASTE tokens
- **Features**: 10% APY for depositors, auto-redemption guarantee, reserve pool
- **Deployment Date**: December 28, 2025
- **Gas Used**: 1,512,189

### 10. CarbonSubscription (Recurring Purchases)  NEW
- **Address**: `0x6d0e4eb5f5337577b341456eDe612EF4FdC9cb0E`
- **Status**:  Active
- **Features**: Monthly auto-purchase subscriptions, 3 tiers with discounts
- **Deployment Date**: December 28, 2025
- **Gas Used**: 1,698,967

## Deprecated Contracts

### DonationManager (Old - Replaced)
- **Address**: `0x2a96BCb4C20667917B8Ac12D6b9B6883CF34113D`
- **Status**:  **DEPRECATED - Do Not Use**
- **Reason**: Missing ImpactNFT integration - NFTs were not minting
- **Replacement**: `0x8cae686969Ca2329656CED848dc4b42E6C594bBb`


## Configuration Status

### NoWasteToken
- `donationManagerAddress` = `0x8cae686969Ca2329656CED848dc4b42E6C594bBb`

### ReputationSystem
- `donationManagerAddress` = `0x8cae686969Ca2329656CED848dc4b42E6C594bBb`

### ImpactNFT
- `donationManagerAddress` = `0x8cae686969Ca2329656CED848dc4b42E6C594bBb`
- `tokenAddress` = `0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9`

### DonationManager (New)
-  `tokenAddress` = `0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9`
-  `reputationSystemAddress` = `0x3B3052A9A2D34F3179A92c0CC33bA154Aa0eF495`
-  `impactNFTAddress` = `0xCD05E4b28fd2608830ac14f6f509a11d590A78FA`
-  Balance = 100,000,000 NOWASTE tokens

### TokenFaucet
-  `tokenAddress` = `0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9`
-  Balance = 100,000 NOWASTE tokens

## Frontend Configuration

Location: `frontend/src/utils/constants.js`

```javascript
4613: {
  NoWasteToken: '0x6F7D3eF5aeE74ee251DB683a9092DB497F13A7a9',
  DonationManager: '0x8cae686969Ca2329656CED848dc4b42E6C594bBb',
  ReputationSystem: '0x3B3052A9A2D34F3179A92c0CC33bA154Aa0eF495',
  ImpactNFT: '0xCD05E4b28fd2608830ac14f6f509a11d590A78FA',
  CarbonCreditRegistry: '0x0410bd7cA7C47Adb4F1522eE2843f699D39cA03A',
  DAOGovernance: '0xA2Ec8265B755eBC9B60B2AF7C54f665f5E0f78Fa',
  TokenFaucet: '0xd459E589cc0F0b8537b1Cccb99e96ef438eb7A32'
}
```

## Testing Wallet

### NGO Wallet
- **Address**: `0x0CEE9C60FdE9B381fdd0d35D5Ea347e274fEa565`
- **Role**: NGO participant for testing donations
- **Reputation**: Initialized
- **Stake**: Can stake/unstake via UI

