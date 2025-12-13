# 🚀 Quick Start - VeryChain Deployment

## Prerequisites Checklist

- [ ] Foundry installed (`curl -L https://foundry.paradigm.xyz | bash && foundryup`)
- [ ] VERY tokens in wallet (get ~2 VERY for gas)
- [ ] Private key ready
- [ ] VeryChain explorer account (optional, for verification)

## 5-Minute Deployment

### 1. Setup Environment (1 min)

```bash
cd backend
cp .env.example .env
```

Edit `.env`:
```env
PRIVATE_KEY=your_actual_private_key_without_0x
VERYCHAIN_RPC_URL=https://rpc.verylabs.io
VERYSCAN_API_KEY=your_api_key_or_leave_blank
```

### 2. Test Compilation (30 sec)

```bash
forge build
```

### 3. Run Tests (1 min)

```bash
forge test
```

### 4. Deploy (2 min)

**Windows PowerShell:**
```powershell
.\deploy.ps1
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Manual (if scripts don't work):**
```bash
forge script script/DeployNoWaste.s.sol \
    --rpc-url https://rpc.verylabs.io \
    --broadcast \
    --verify \
    -vvvv
```

### 5. Update Frontend (30 sec)

After deployment completes, copy addresses from `deployment-addresses.md`:

**File:** `frontend/src/utils/constants.js`

```javascript
export const CONTRACT_ADDRESSES = {
  4613: { // VeryChain
    NoWasteToken: '0xYOUR_DEPLOYED_ADDRESS',
    DonationManager: '0xYOUR_DEPLOYED_ADDRESS',
    ReputationSystem: '0xYOUR_DEPLOYED_ADDRESS',
    ImpactNFT: '0xYOUR_DEPLOYED_ADDRESS',
    CarbonCreditRegistry: '0xYOUR_DEPLOYED_ADDRESS',
    DAOGovernance: '0xYOUR_DEPLOYED_ADDRESS'
  }
};
```

## ✅ Verification

Check your deployment on VeryChain Explorer:
```
https://veryscan.io/address/YOUR_CONTRACT_ADDRESS
```

## 🧪 Quick Test

Test token transfer:
```bash
cast send YOUR_TOKEN_ADDRESS \
    "transfer(address,uint256)" \
    0xRECIPIENT_ADDRESS \
    1000000000000000000 \
    --private-key $PRIVATE_KEY \
    --rpc-url https://rpc.verylabs.io
```

## 📊 Deployment Cost

Total: **~0.014 VERY** (~$0.50 USD assuming VERY = $35)

## 🆘 Common Issues

**"Insufficient funds"**
→ Get more VERY tokens

**"Nonce too high"**
→ Reset MetaMask or wait

**"RPC error"**
→ Check internet, try again

**"Verification failed"**
→ Not critical, contracts still work

## 🎉 Success!

Your NoWaste Protocol is live on VeryChain!

**Next Steps:**
1. Test frontend locally: `cd frontend && npm start`
2. Create first donation
3. Share contracts with team
4. Set up monitoring

## 📚 Resources

- **Deployment Guide:** `DEPLOYMENT.md`
- **VeryChain Docs:** https://wp.verylabs.io/verychain
- **Explorer:** https://veryscan.io
- **RPC:** https://rpc.verylabs.io

## 🔒 Security

- ✅ Backup `.env` file securely
- ✅ Never commit private keys
- ✅ Test small transactions first
- ✅ Consider multi-sig for ownership

---

**Need Help?** Check `DEPLOYMENT.md` for detailed instructions.
