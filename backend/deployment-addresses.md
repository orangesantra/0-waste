# NoWaste Protocol - Deployment Addresses

**Network:** VeryChain Mainnet (Chain ID: 4613)  
**Deployed:** December 16, 2025  
**Deployer:** `0x0702f25B487aD122eAd1F24E42e3A74E14365FBE`  
**RPC:** https://rpc.verylabs.io  
**Explorer:** https://veryscan.io

---

## 📋 Contract Addresses

| Contract | Address | View on Explorer |
|----------|---------|------------------|
| **NoWasteToken** | `0x87bD0c0d09e7656af66D957C4C022183879A4E38` | [View →](https://veryscan.io/address/0x87bD0c0d09e7656af66D957C4C022183879A4E38) |
| **ReputationSystem** | `0x1fbBDD7556d15B013f87AB81710616b723e0ef51` | [View →](https://veryscan.io/address/0x1fbBDD7556d15B013f87AB81710616b723e0ef51) |
| **DonationManager** | `0xFD02f32CeF8728F1f992D2C5D555d0D2E828d8AE` | [View →](https://veryscan.io/address/0xFD02f32CeF8728F1f992D2C5D555d0D2E828d8AE) |
| **ImpactNFT** | `0x0D1F4146f3d4448bc632243ec8A99E753cB1e795` | [View →](https://veryscan.io/address/0x0D1F4146f3d4448bc632243ec8A99E753cB1e795) |
| **CarbonCreditRegistry** | `0x85BB687Cadd0a9634165d0448F3E0649c09D669a` | [View →](https://veryscan.io/address/0x85BB687Cadd0a9634165d0448F3E0649c09D669a) |
| **DAOGovernance** | `0x02282a94a68d373DeC1b0f1A5b0fc66C3C7E39d4` | [View →](https://veryscan.io/address/0x02282a94a68d373DeC1b0f1A5b0fc66C3C7E39d4) |

---

## 🔧 Configuration Parameters

### Token Economics
- **Total Supply:** 1,000,000,000 NOWASTE
- **Decimals:** 18
- **Burn Rate:** 1% on transfers
- **Symbol:** NOWASTE

### Staking Requirements
- **Restaurant Stake:** 1,000 NOWASTE
- **NGO Stake:** 500 NOWASTE
- **Courier Stake:** 750 NOWASTE
- **Validator Stake:** 200 NOWASTE
- **DAO Proposal Threshold:** 5,000 NOWASTE

### NFT & Carbon Credits
- **NFT Mint Cost:** 100 NOWASTE (burned)
- **NFT Name:** NoWaste Impact Certificate
- **NFT Symbol:** NWIC
- **CO2 Calculation:** 2.5 kg CO2 per 1 kg food saved

### Reputation Tiers
- **Bronze:** 0-249 points (1.0x multiplier)
- **Silver:** 250-499 points (1.25x multiplier)
- **Gold:** 500-749 points (1.5x multiplier)
- **Platinum:** 750-1000 points (2.0x multiplier)

---

## 📱 Add to MetaMask

### Network Configuration
```javascript
{
  "chainId": "0x1205", // 4613 in hex
  "chainName": "VeryChain Mainnet",
  "rpcUrls": ["https://rpc.verylabs.io"],
  "nativeCurrency": {
    "name": "VERY",
    "symbol": "VERY",
    "decimals": 18
  },
  "blockExplorerUrls": ["https://veryscan.io"]
}
```

### Add NOWASTE Token
```
Token Address: 0x87bD0c0d09e7656af66D957C4C022183879A4E38
Symbol: NOWASTE
Decimals: 18
```

---

## 🧪 Quick Test Commands

### Check Token Balance
```bash
cast call 0x87bD0c0d09e7656af66D957C4C022183879A4E38 \
  "balanceOf(address)(uint256)" \
  YOUR_ADDRESS \
  --rpc-url https://rpc.verylabs.io
```

### Check Reputation Score
```bash
cast call 0x1fbBDD7556d15B013f87AB81710616b723e0ef51 \
  "getReputationScore(address)(uint256)" \
  YOUR_ADDRESS \
  --rpc-url https://rpc.verylabs.io
```

### Approve Tokens for Staking
```bash
cast send 0x87bD0c0d09e7656af66D957C4C022183879A4E38 \
  "approve(address,uint256)" \
  0xFD02f32CeF8728F1f992D2C5D555d0D2E828d8AE \
  1000000000000000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url https://rpc.verylabs.io
```

---

## 📊 Deployment Summary

```json
{
  "network": "VeryChain Mainnet",
  "chainId": 4613,
  "deployedAt": "2025-12-16",
  "deployer": "0x0702f25B487aD122eAd1F24E42e3A74E14365FBE",
  "contracts": {
    "NoWasteToken": "0x87bD0c0d09e7656af66D957C4C022183879A4E38",
    "ReputationSystem": "0x1fbBDD7556d15B013f87AB81710616b723e0ef51",
    "DonationManager": "0xFD02f32CeF8728F1f992D2C5D555d0D2E828d8AE",
    "ImpactNFT": "0x0D1F4146f3d4448bc632243ec8A99E753cB1e795",
    "CarbonCreditRegistry": "0x85BB687Cadd0a9634165d0448F3E0649c09D669a",
    "DAOGovernance": "0x02282a94a68d373DeC1b0f1A5b0fc66C3C7E39d4"
  },
  "verified": false,
  "status": "deployed"
}
```

---

## ✅ Post-Deployment Checklist

- [x] All 6 contracts deployed successfully
- [x] Contract permissions configured
- [x] Frontend constants updated
- [x] Contract ABIs updated
- [ ] Verify contracts on VeryChain explorer
- [ ] Test token transfers
- [ ] Test donation creation
- [ ] Test NFT minting
- [ ] Initialize DAO with first proposal
- [ ] Set up monitoring/alerts
- [ ] Announce launch to community

---

## 🔒 Security Notes

⚠️ **IMPORTANT REMINDERS:**
- Private keys are stored in `.env` (never commit to git!)
- Deployer address has owner privileges on all contracts
- Consider transferring ownership to multi-sig wallet
- Set up monitoring for unusual contract activity
- Keep backup of deployment transaction hashes
- Document all admin operations

---

## 📚 Resources

- **VeryChain Docs:** https://wp.verylabs.io/verychain
- **Explorer:** https://veryscan.io
- **RPC Endpoint:** https://rpc.verylabs.io
- **Frontend Repo:** github.com/orangesantra/0-waste
- **Deployment Guide:** `backend/DEPLOYMENT.md`

---

## 🆘 Support

If you encounter issues:
1. Check transaction on VeryChain explorer
2. Review deployment logs in `backend/broadcast/`
3. Test with small amounts first
4. Contact VeryChain support: https://verylabs.io

**Status:** ✅ **LIVE ON MAINNET**
