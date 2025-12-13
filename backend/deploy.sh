#!/bin/bash
# Quick deployment script for VeryChain

set -e

echo "========================================"
echo "NoWaste Protocol - VeryChain Deployment"
echo "========================================"

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Please copy .env.example to .env and fill in your values"
    exit 1
fi

# Load environment variables
source .env

# Check if private key is set
if [ "$PRIVATE_KEY" == "your_private_key_here" ]; then
    echo "❌ Error: PRIVATE_KEY not set in .env file"
    exit 1
fi

echo "✅ Environment variables loaded"
echo ""

# Compile contracts
echo "📦 Compiling contracts..."
forge build
echo "✅ Compilation complete"
echo ""

# Run tests
echo "🧪 Running tests..."
forge test
echo "✅ Tests passed"
echo ""

# Ask for confirmation
read -p "🚀 Ready to deploy to VeryChain Mainnet. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Deploy to VeryChain
echo ""
echo "🚀 Deploying to VeryChain Mainnet..."
echo "⏳ This may take a few minutes..."
echo ""

forge script script/DeployNoWaste.s.sol \
    --rpc-url $VERYCHAIN_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $VERYSCAN_API_KEY \
    -vvvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📄 Contract addresses saved to: deployment-addresses.md"
echo "🔍 View on explorer: https://veryscan.io"
echo ""
echo "⚠️  NEXT STEPS:"
echo "1. Update frontend/src/utils/constants.js with contract addresses"
echo "2. Test contract interactions"
echo "3. Initialize DAO governance"
echo ""
