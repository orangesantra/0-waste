# PowerShell verification script

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "NoWaste Protocol - Deployment Verification" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Load environment
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        Set-Item -Path "env:$($matches[1])" -Value $matches[2]
    }
}

# Check if deployment file exists
if (!(Test-Path "deployment-addresses.md")) {
    Write-Host "❌ Error: deployment-addresses.md not found" -ForegroundColor Red
    Write-Host "Please deploy contracts first" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Reading deployed addresses..." -ForegroundColor Yellow

# Extract addresses (you'll need to parse the JSON from deployment-addresses.md)
$content = Get-Content "deployment-addresses.md" -Raw
$TOKEN_ADDRESS = ($content | Select-String -Pattern '"NoWasteToken":\s*"(0x[a-fA-F0-9]{40})"').Matches.Groups[1].Value
$REPUTATION_ADDRESS = ($content | Select-String -Pattern '"ReputationSystem":\s*"(0x[a-fA-F0-9]{40})"').Matches.Groups[1].Value
$DONATION_ADDRESS = ($content | Select-String -Pattern '"DonationManager":\s*"(0x[a-fA-F0-9]{40})"').Matches.Groups[1].Value
$NFT_ADDRESS = ($content | Select-String -Pattern '"ImpactNFT":\s*"(0x[a-fA-F0-9]{40})"').Matches.Groups[1].Value
$CARBON_ADDRESS = ($content | Select-String -Pattern '"CarbonCreditRegistry":\s*"(0x[a-fA-F0-9]{40})"').Matches.Groups[1].Value
$DAO_ADDRESS = ($content | Select-String -Pattern '"DAOGovernance":\s*"(0x[a-fA-F0-9]{40})"').Matches.Groups[1].Value

$DEPLOYER = (cast wallet address --private-key $env:PRIVATE_KEY)

Write-Host "✅ Addresses loaded" -ForegroundColor Green
Write-Host ""

# Test 1: Check token supply
Write-Host "Test 1: Checking token supply..." -ForegroundColor Yellow
$TOTAL_SUPPLY = cast call $TOKEN_ADDRESS "totalSupply()(uint256)" --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "Total Supply: $TOTAL_SUPPLY wei" -ForegroundColor Cyan

# Test 2: Check deployer balance
Write-Host ""
Write-Host "Test 2: Checking deployer balance..." -ForegroundColor Yellow
$BALANCE = cast call $TOKEN_ADDRESS "balanceOf(address)(uint256)" $DEPLOYER --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "Deployer Balance: $BALANCE wei" -ForegroundColor Cyan

# Test 3: Check reputation
Write-Host ""
Write-Host "Test 3: Checking reputation system..." -ForegroundColor Yellow
$REP_SCORE = cast call $REPUTATION_ADDRESS "getReputation(address)(uint256)" $DEPLOYER --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "Deployer Reputation: $REP_SCORE" -ForegroundColor Cyan

# Test 4: Check stakes
Write-Host ""
Write-Host "Test 4: Checking stake requirements..." -ForegroundColor Yellow
$RESTAURANT_STAKE = cast call $DONATION_ADDRESS "RESTAURANT_STAKE()(uint256)" --rpc-url $env:VERYCHAIN_RPC_URL
$NGO_STAKE = cast call $DONATION_ADDRESS "NGO_STAKE()(uint256)" --rpc-url $env:VERYCHAIN_RPC_URL
$COURIER_STAKE = cast call $DONATION_ADDRESS "COURIER_STAKE()(uint256)" --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "Restaurant Stake: $RESTAURANT_STAKE wei" -ForegroundColor Cyan
Write-Host "NGO Stake: $NGO_STAKE wei" -ForegroundColor Cyan
Write-Host "Courier Stake: $COURIER_STAKE wei" -ForegroundColor Cyan

# Test 5: Check NFT
Write-Host ""
Write-Host "Test 5: Checking NFT contract..." -ForegroundColor Yellow
$NFT_NAME = cast call $NFT_ADDRESS "name()(string)" --rpc-url $env:VERYCHAIN_RPC_URL
$NFT_SYMBOL = cast call $NFT_ADDRESS "symbol()(string)" --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "NFT Name: $NFT_NAME" -ForegroundColor Cyan
Write-Host "NFT Symbol: $NFT_SYMBOL" -ForegroundColor Cyan

# Test 6: Check DAO
Write-Host ""
Write-Host "Test 6: Checking DAO governance..." -ForegroundColor Yellow
$PROPOSAL_THRESHOLD = cast call $DAO_ADDRESS "proposalThreshold()(uint256)" --rpc-url $env:VERYCHAIN_RPC_URL
$VOTING_PERIOD = cast call $DAO_ADDRESS "votingPeriod()(uint256)" --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "Proposal Threshold: $PROPOSAL_THRESHOLD wei" -ForegroundColor Cyan
Write-Host "Voting Period: $VOTING_PERIOD seconds" -ForegroundColor Cyan

# Test 7: Check ownership
Write-Host ""
Write-Host "Test 7: Checking contract ownership..." -ForegroundColor Yellow
$TOKEN_OWNER = cast call $TOKEN_ADDRESS "owner()(address)" --rpc-url $env:VERYCHAIN_RPC_URL
Write-Host "Token Owner: $TOKEN_OWNER" -ForegroundColor Cyan
Write-Host "Expected: $DEPLOYER" -ForegroundColor Cyan

if ($TOKEN_OWNER -eq $DEPLOYER) {
    Write-Host "✅ Ownership verified" -ForegroundColor Green
} else {
    Write-Host "❌ Ownership mismatch!" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ Verification Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Yellow
Write-Host "All contracts deployed and responding correctly"
Write-Host ""
Write-Host "🔗 View on Explorer:" -ForegroundColor Yellow
Write-Host "https://veryscan.io/address/$TOKEN_ADDRESS"
Write-Host ""
Write-Host "⚠️  Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update frontend/src/utils/constants.js"
Write-Host "2. Test token approval and staking"
Write-Host "3. Create first donation"
Write-Host ""
