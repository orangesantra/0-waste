# NoWaste Protocol - Frontend Setup Script (Windows)
# This script helps you set up the frontend after deploying smart contracts

Write-Host "🌱 NoWaste Protocol - Frontend Setup" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

# Check if we're in the frontend directory
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: Please run this script from the frontend directory" -ForegroundColor Red
    exit 1
}

# Step 1: Install dependencies
Write-Host "📦 Step 1: Installing dependencies..." -ForegroundColor Cyan
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Check for contract addresses
Write-Host "⚙️  Step 2: Checking contract configuration..." -ForegroundColor Cyan

$constantsPath = "src/utils/constants.js"
$content = Get-Content $constantsPath -Raw

if ($content -match "0x0000000000000000000000000000000000000000") {
    Write-Host "⚠️  WARNING: Contract addresses not configured!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please update src/utils/constants.js with your deployed contract addresses:"
    Write-Host "  - NoWasteToken"
    Write-Host "  - DonationManager"
    Write-Host "  - ReputationSystem"
    Write-Host "  - ImpactNFT"
    Write-Host "  - CarbonCreditRegistry"
    Write-Host "  - DAOGovernance"
    Write-Host ""
    Write-Host "After deploying contracts, run:"
    Write-Host '  forge script script/Deploy.s.sol --rpc-url $env:MUMBAI_RPC_URL --broadcast'
    Write-Host ""
} else {
    Write-Host "✅ Contract addresses configured" -ForegroundColor Green
}

# Step 3: Environment setup
Write-Host "🔧 Step 3: Checking environment configuration..." -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file..."
    
    $envContent = @"
# API Configuration (optional)
REACT_APP_API_URL=http://localhost:3001

# Default Chain ID (80001 for Mumbai Testnet, 137 for Polygon Mainnet)
REACT_APP_CHAIN_ID=80001

# IPFS Configuration (optional - for future use)
REACT_APP_IPFS_GATEWAY=https://gateway.pinata.cloud/ipfs/
"@
    
    Set-Content -Path ".env" -Value $envContent
    Write-Host "✅ .env file created" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Deploy smart contracts to Polygon Mumbai:"
Write-Host "   cd ..\backend"
Write-Host '   forge script script/Deploy.s.sol --rpc-url $env:MUMBAI_RPC_URL --broadcast --verify'
Write-Host ""
Write-Host "2. Update contract addresses in:"
Write-Host "   frontend\src\utils\constants.js"
Write-Host ""
Write-Host "3. Start the development server:"
Write-Host "   npm start"
Write-Host ""
Write-Host "4. Connect MetaMask:" -ForegroundColor Cyan
Write-Host "   - Add Polygon Mumbai network"
Write-Host "   - Get test MATIC: https://faucet.polygon.technology/"
Write-Host "   - Get test NOWASTE tokens from your deployed faucet"
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   - Frontend Guide: FRONTEND_README.md"
Write-Host "   - Refactor Summary: ..\FRONTEND_REFACTOR_SUMMARY.md"
Write-Host "   - Whitepaper: ..\WHITEPAPER.md"
Write-Host ""
Write-Host "🔗 Useful Links:" -ForegroundColor Cyan
Write-Host "   - Polygon Mumbai Explorer: https://mumbai.polygonscan.com"
Write-Host "   - MetaMask: https://metamask.io"
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
