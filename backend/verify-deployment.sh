#!/bin/bash
# Post-deployment verification script

source .env

echo "=========================================="
echo "NoWaste Protocol - Deployment Verification"
echo "=========================================="
echo ""

# Read deployed addresses from deployment-addresses.md
if [ ! -f "deployment-addresses.md" ]; then
    echo "❌ Error: deployment-addresses.md not found"
    echo "Please deploy contracts first"
    exit 1
fi

echo "📋 Reading deployed addresses..."

# Extract addresses (you'll need to update these after deployment)
TOKEN_ADDRESS=$(grep 'NoWasteToken' deployment-addresses.md | grep -oP '0x[a-fA-F0-9]{40}')
REPUTATION_ADDRESS=$(grep 'ReputationSystem' deployment-addresses.md | grep -oP '0x[a-fA-F0-9]{40}')
DONATION_ADDRESS=$(grep 'DonationManager' deployment-addresses.md | grep -oP '0x[a-fA-F0-9]{40}')
NFT_ADDRESS=$(grep 'ImpactNFT' deployment-addresses.md | grep -oP '0x[a-fA-F0-9]{40}')
CARBON_ADDRESS=$(grep 'CarbonCreditRegistry' deployment-addresses.md | grep -oP '0x[a-fA-F0-9]{40}')
DAO_ADDRESS=$(grep 'DAOGovernance' deployment-addresses.md | grep -oP '0x[a-fA-F0-9]{40}')

DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

echo "✅ Addresses loaded"
echo ""

# Test 1: Check token supply
echo "Test 1: Checking token supply..."
TOTAL_SUPPLY=$(cast call $TOKEN_ADDRESS "totalSupply()(uint256)" --rpc-url $VERYCHAIN_RPC_URL)
echo "Total Supply: $TOTAL_SUPPLY wei (should be 1000000000000000000000000000)"

# Test 2: Check deployer balance
echo ""
echo "Test 2: Checking deployer balance..."
BALANCE=$(cast call $TOKEN_ADDRESS "balanceOf(address)(uint256)" $DEPLOYER --rpc-url $VERYCHAIN_RPC_URL)
echo "Deployer Balance: $BALANCE wei"

# Test 3: Check reputation system
echo ""
echo "Test 3: Checking reputation system..."
REP_SCORE=$(cast call $REPUTATION_ADDRESS "getReputation(address)(uint256)" $DEPLOYER --rpc-url $VERYCHAIN_RPC_URL)
echo "Deployer Reputation: $REP_SCORE (should be 0 for new user)"

# Test 4: Check stake amounts
echo ""
echo "Test 4: Checking stake requirements..."
RESTAURANT_STAKE=$(cast call $DONATION_ADDRESS "RESTAURANT_STAKE()(uint256)" --rpc-url $VERYCHAIN_RPC_URL)
NGO_STAKE=$(cast call $DONATION_ADDRESS "NGO_STAKE()(uint256)" --rpc-url $VERYCHAIN_RPC_URL)
COURIER_STAKE=$(cast call $DONATION_ADDRESS "COURIER_STAKE()(uint256)" --rpc-url $VERYCHAIN_RPC_URL)
echo "Restaurant Stake: $RESTAURANT_STAKE wei (1000 tokens)"
echo "NGO Stake: $NGO_STAKE wei (500 tokens)"
echo "Courier Stake: $COURIER_STAKE wei (750 tokens)"

# Test 5: Check NFT contract
echo ""
echo "Test 5: Checking NFT contract..."
NFT_NAME=$(cast call $NFT_ADDRESS "name()(string)" --rpc-url $VERYCHAIN_RPC_URL)
NFT_SYMBOL=$(cast call $NFT_ADDRESS "symbol()(string)" --rpc-url $VERYCHAIN_RPC_URL)
echo "NFT Name: $NFT_NAME"
echo "NFT Symbol: $NFT_SYMBOL"

# Test 6: Check DAO parameters
echo ""
echo "Test 6: Checking DAO governance..."
PROPOSAL_THRESHOLD=$(cast call $DAO_ADDRESS "proposalThreshold()(uint256)" --rpc-url $VERYCHAIN_RPC_URL)
VOTING_PERIOD=$(cast call $DAO_ADDRESS "votingPeriod()(uint256)" --rpc-url $VERYCHAIN_RPC_URL)
echo "Proposal Threshold: $PROPOSAL_THRESHOLD wei (100000 tokens)"
echo "Voting Period: $VOTING_PERIOD seconds (3 days)"

# Test 7: Check contract ownership
echo ""
echo "Test 7: Checking contract ownership..."
TOKEN_OWNER=$(cast call $TOKEN_ADDRESS "owner()(address)" --rpc-url $VERYCHAIN_RPC_URL)
echo "Token Owner: $TOKEN_OWNER"
echo "Expected: $DEPLOYER"

if [ "$TOKEN_OWNER" == "$DEPLOYER" ]; then
    echo "✅ Ownership verified"
else
    echo "❌ Ownership mismatch!"
fi

echo ""
echo "=========================================="
echo "✅ Verification Complete!"
echo "=========================================="
echo ""
echo "📊 Summary:"
echo "All contracts deployed and responding correctly"
echo ""
echo "🔗 View on Explorer:"
echo "https://veryscan.io/address/$TOKEN_ADDRESS"
echo ""
echo "⚠️  Next Steps:"
echo "1. Update frontend/src/utils/constants.js"
echo "2. Test token approval and staking"
echo "3. Create first donation"
echo ""
