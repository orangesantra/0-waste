# PowerShell deployment script for VeryChain

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NoWaste Protocol - VeryChain Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (!(Test-Path ".env")) {
    Write-Host "❌ Error: .env file not found!" -ForegroundColor Red
    Write-Host "📝 Please copy .env.example to .env and fill in your values" -ForegroundColor Yellow
    exit 1
}

# Load environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        $name = $matches[1]
        $value = $matches[2]
        Set-Item -Path "env:$name" -Value $value
    }
}

# Check if private key is set
if ($env:PRIVATE_KEY -eq "your_private_key_here") {
    Write-Host "❌ Error: PRIVATE_KEY not set in .env file" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Environment variables loaded" -ForegroundColor Green
Write-Host ""

# Compile contracts
Write-Host "📦 Compiling contracts..." -ForegroundColor Yellow
forge build
Write-Host "✅ Compilation complete" -ForegroundColor Green
Write-Host ""

# Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
forge test
Write-Host "✅ Tests passed" -ForegroundColor Green
Write-Host ""

# Ask for confirmation
$response = Read-Host "🚀 Ready to deploy to VeryChain Mainnet. Continue? (y/n)"
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "❌ Deployment cancelled" -ForegroundColor Red
    exit 1
}

# Deploy to VeryChain
Write-Host ""
Write-Host "🚀 Deploying to VeryChain Mainnet..." -ForegroundColor Cyan
Write-Host "⏳ This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

forge script script/DeployNoWaste.s.sol `
    --rpc-url $env:VERYCHAIN_RPC_URL `
    --private-key $env:PRIVATE_KEY `
    --broadcast `
    --verify `
    --etherscan-api-key $env:VERYSCAN_API_KEY `
    -vvvv

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📄 Contract addresses saved to: deployment-addresses.md" -ForegroundColor Cyan
Write-Host "🔍 View on explorer: https://veryscan.io" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Update frontend/src/utils/constants.js with contract addresses"
Write-Host "2. Test contract interactions"
Write-Host "3. Initialize DAO governance"
Write-Host ""
