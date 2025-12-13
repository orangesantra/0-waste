# VeryChain Deployment Guide

## Prerequisites

1. **Install Foundry** (if not already installed):
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. **Get VERY tokens** for gas fees:
   - Obtain VERY tokens from VeryChain faucet or exchange
   - You'll need ~1-2 VERY for deployment gas

3. **Set up environment variables**:
```bash
# Create .env file in backend directory
cd backend
touch .env
```

Add to `.env`:
```env
PRIVATE_KEY=your_private_key_here
VERYCHAIN_RPC_URL=https://rpc.verylabs.io
VERYSCAN_API_KEY=your_veryscan_api_key_here
```

## Deployment Steps

### Step 1: Configure Network in foundry.toml

The network configuration has been added. Verify it:
```bash
cd backend
cat foundry.toml
```

### Step 2: Compile Contracts

```bash
forge build
```

Expected output:
```
[⠊] Compiling...
[⠒] Compiling 50 files with 0.8.24
[⠢] Solc 0.8.24 finished in XX.XXs
Compiler run successful!
```

### Step 3: Test Deployment Locally (Optional)

Test on local fork:
```bash
forge script script/DeployNoWaste.s.sol --fork-url https://rpc.verylabs.io
```

### Step 4: Deploy to VeryChain Mainnet

**⚠️ WARNING: This will deploy to mainnet and cost VERY tokens!**

```bash
forge script script/DeployNoWaste.s.sol \
    --rpc-url $VERYCHAIN_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $VERYSCAN_API_KEY \
    -vvvv
```

Or using the simpler command:
```bash
forge script script/DeployNoWaste.s.sol \
    --rpc-url https://rpc.verylabs.io \
    --broadcast \
    --verify \
    -vvvv
```

### Step 5: Verify Deployment

After deployment completes, you'll see:
```
==============================================
DEPLOYMENT COMPLETE!
==============================================
NoWasteToken: 0x...
ReputationSystem: 0x...
DonationManager: 0x...
ImpactNFT: 0x...
CarbonCreditRegistry: 0x...
DAOGovernance: 0x...
==============================================
```

Contract addresses will be saved to: `deployment-addresses.md`

### Step 6: Verify Contracts on VeryChain Explorer

```bash
forge verify-contract \
    --chain-id 4613 \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address)" "YOUR_DEPLOYER_ADDRESS") \
    --etherscan-api-key $VERYSCAN_API_KEY \
    --compiler-version v0.8.24 \
    CONTRACT_ADDRESS \
    src/NoWasteToken.sol:NoWasteToken
```

Repeat for all contracts.

### Step 7: Update Frontend Configuration

Copy contract addresses from `deployment-addresses.md` and update:

**File:** `frontend/src/utils/constants.js`

Replace the placeholder addresses:
```javascript
export const CONTRACT_ADDRESSES = {
  4613: { // VeryChain Mainnet
    NoWasteToken: '0xYOUR_TOKEN_ADDRESS',
    ReputationSystem: '0xYOUR_REPUTATION_ADDRESS',
    DonationManager: '0xYOUR_DONATION_ADDRESS',
    ImpactNFT: '0xYOUR_NFT_ADDRESS',
    CarbonCreditRegistry: '0xYOUR_CARBON_ADDRESS',
    DAOGovernance: '0xYOUR_DAO_ADDRESS'
  }
};
```

### Step 8: Test Contract Interactions

```bash
# Test token balance
cast call TOKEN_ADDRESS "balanceOf(address)" YOUR_ADDRESS --rpc-url https://rpc.verylabs.io

# Test reputation score
cast call REPUTATION_ADDRESS "getReputation(address)" YOUR_ADDRESS --rpc-url https://rpc.verylabs.io

# Approve tokens for staking
cast send TOKEN_ADDRESS "approve(address,uint256)" DONATION_MANAGER_ADDRESS 1000000000000000000000 --private-key $PRIVATE_KEY --rpc-url https://rpc.verylabs.io
```

## Gas Cost Estimates

Based on VeryChain's 1 Gwei minimum gas price:

| Contract | Estimated Gas | Cost (VERY) |
|----------|--------------|-------------|
| NoWasteToken | ~2,500,000 | ~0.0025 |
| ReputationSystem | ~1,800,000 | ~0.0018 |
| DonationManager | ~3,200,000 | ~0.0032 |
| ImpactNFT | ~2,100,000 | ~0.0021 |
| CarbonCreditRegistry | ~1,900,000 | ~0.0019 |
| DAOGovernance | ~2,400,000 | ~0.0024 |
| **Total** | **~13,900,000** | **~0.0139 VERY** |

## Troubleshooting

### Error: "Insufficient funds for gas"
- Ensure you have enough VERY tokens in your wallet
- Check balance: `cast balance YOUR_ADDRESS --rpc-url https://rpc.verylabs.io`

### Error: "Nonce too high"
- Reset nonce in MetaMask or use `--legacy` flag

### Error: "Contract verification failed"
- Make sure compiler version matches (0.8.24)
- Check optimizer settings (enabled, 200 runs)
- Verify constructor arguments are correct

### Error: "RPC connection failed"
- Check RPC URL: https://rpc.verylabs.io
- Verify internet connection
- Try alternative RPC if available

## Post-Deployment Checklist

- [ ] All 6 contracts deployed successfully
- [ ] Contract addresses saved to `deployment-addresses.md`
- [ ] Contracts verified on VeryChain explorer (https://veryscan.io)
- [ ] Frontend `constants.js` updated with new addresses
- [ ] Test token transfers work
- [ ] Test staking functionality
- [ ] Test donation creation
- [ ] Test NFT minting
- [ ] Initialize DAO with first proposal
- [ ] Document deployment for team
- [ ] Back up private keys securely
- [ ] Set up monitoring/alerts

## Network Information

**VeryChain Mainnet:**
- Chain ID: 4613
- RPC: https://rpc.verylabs.io
- Explorer: https://veryscan.io
- Currency: VERY
- Block Time: 12 seconds
- Gas Price: 1-500 Gwei

## Support

If you encounter issues:
1. Check VeryChain documentation: https://wp.verylabs.io/verychain
2. Review Foundry book: https://book.getfoundry.sh/
3. Check transaction on explorer: https://veryscan.io
4. Review deployment logs in `broadcast/` directory

## Security Notes

⚠️ **IMPORTANT:**
- Never commit `.env` file to git
- Keep private keys secure and backed up
- Test on testnet first if available
- Audit contracts before mainnet deployment
- Consider multi-sig for contract ownership
- Set up emergency pause mechanisms
- Monitor contracts for unusual activity
