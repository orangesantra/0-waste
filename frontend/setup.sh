#!/bin/bash

# NoWaste Protocol - Frontend Setup Script
# This script helps you set up the frontend after deploying smart contracts

echo "🌱 NoWaste Protocol - Frontend Setup"
echo "======================================"
echo ""

# Check if we're in the frontend directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the frontend directory"
    exit 1
fi

# Step 1: Install dependencies
echo "📦 Step 1: Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"
echo ""

# Step 2: Check for contract addresses
echo "⚙️  Step 2: Checking contract configuration..."

if grep -q "0x0000000000000000000000000000000000000000" src/utils/constants.js; then
    echo "⚠️  WARNING: Contract addresses not configured!"
    echo ""
    echo "Please update src/utils/constants.js with your deployed contract addresses:"
    echo "  - NoWasteToken"
    echo "  - DonationManager"
    echo "  - ReputationSystem"
    echo "  - ImpactNFT"
    echo "  - CarbonCreditRegistry"
    echo "  - DAOGovernance"
    echo ""
    echo "After deploying contracts, run:"
    echo "  forge script script/Deploy.s.sol --rpc-url \$MUMBAI_RPC_URL --broadcast"
    echo ""
else
    echo "✅ Contract addresses configured"
fi

# Step 3: Environment setup
echo "🔧 Step 3: Checking environment configuration..."

if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# API Configuration (optional)
REACT_APP_API_URL=http://localhost:3001

# Default Chain ID (80001 for Mumbai Testnet, 137 for Polygon Mainnet)
REACT_APP_CHAIN_ID=80001

# IPFS Configuration (optional - for future use)
REACT_APP_IPFS_GATEWAY=https://gateway.pinata.cloud/ipfs/
EOF
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

echo ""
echo "======================================"
echo "🎉 Setup Complete!"
echo "======================================"
echo ""
echo "Next Steps:"
echo ""
echo "1. Deploy smart contracts to Polygon Mumbai:"
echo "   cd ../backend"
echo "   forge script script/Deploy.s.sol --rpc-url \$MUMBAI_RPC_URL --broadcast --verify"
echo ""
echo "2. Update contract addresses in:"
echo "   frontend/src/utils/constants.js"
echo ""
echo "3. Start the development server:"
echo "   npm start"
echo ""
echo "4. Connect MetaMask:"
echo "   - Add Polygon Mumbai network"
echo "   - Get test MATIC: https://faucet.polygon.technology/"
echo "   - Get test NOWASTE tokens from your deployed faucet"
echo ""
echo "📚 Documentation:"
echo "   - Frontend Guide: FRONTEND_README.md"
echo "   - Refactor Summary: ../FRONTEND_REFACTOR_SUMMARY.md"
echo "   - Whitepaper: ../WHITEPAPER.md"
echo ""
echo "🔗 Useful Links:"
echo "   - Polygon Mumbai Explorer: https://mumbai.polygonscan.com"
echo "   - MetaMask: https://metamask.io"
echo ""
