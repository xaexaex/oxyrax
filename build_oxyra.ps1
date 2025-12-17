# Oxyra Build Script for Windows (PowerShell)
# Run this in MSYS2 MINGW64 environment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Oxyra Blockchain Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running in MSYS2
if (-not $env:MSYSTEM) {
    Write-Host "ERROR: This script must be run in MSYS2 MINGW64 shell!" -ForegroundColor Red
    Write-Host "Please open 'MSYS2 MINGW64' and run:" -ForegroundColor Yellow
    Write-Host "  ./build_oxyra.sh" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Checking dependencies..." -ForegroundColor Green
Write-Host "Required packages: cmake, boost, openssl, zeromq, libsodium, unbound"
Write-Host ""

$confirm = Read-Host "Have you installed all dependencies? (y/n)"
if ($confirm -ne "y") {
    Write-Host ""
    Write-Host "Please install dependencies first:" -ForegroundColor Yellow
    Write-Host "pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-unbound"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Cleaning old build..." -ForegroundColor Green
if (Test-Path "build") {
    $clean = Read-Host "Remove existing build directory? (y/n)"
    if ($clean -eq "y") {
        Remove-Item -Recurse -Force build
        Write-Host "Build directory cleaned." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Step 3: Creating build directory..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path "build/release" | Out-Null
Set-Location build/release

Write-Host ""
Write-Host "Step 4: Running CMake configuration..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

cmake -G "MSYS Makefiles" `
    -D CMAKE_BUILD_TYPE=Release `
    -D BUILD_TESTS=OFF `
    -D ARCH="x86-64" `
    ../..

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: CMake configuration failed!" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

Write-Host ""
Write-Host "Step 5: Building Oxyra..." -ForegroundColor Green
Write-Host "This will take 30-60 minutes depending on your system." -ForegroundColor Yellow
Write-Host "Go grab a coffee! ☕" -ForegroundColor Cyan
Write-Host ""

$cores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
Write-Host "Building with $cores cores..." -ForegroundColor Cyan

make -j$cores

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

Set-Location ../..

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Executables are in: build/release/bin/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available binaries:" -ForegroundColor Yellow
Get-ChildItem build/release/bin/*.exe | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "===========" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Generate premine wallet:" -ForegroundColor Yellow
Write-Host "   ./build/release/bin/monero-wallet-cli.exe --generate-new-wallet premine_wallet" -ForegroundColor White
Write-Host ""
Write-Host "2. Generate genesis transaction (see OXYRA_SETUP_GUIDE.md)" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Test the node:" -ForegroundColor Yellow
Write-Host "   ./build/release/bin/monerod.exe --testnet --data-dir ./oxyra-testnet" -ForegroundColor White
Write-Host ""
Write-Host "4. Read the full setup guide:" -ForegroundColor Yellow
Write-Host "   OXYRA_SETUP_GUIDE.md" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green

# Create a quick start script
$quickStart = @"
# Oxyra Quick Start Script
# This script helps you get started with Oxyra

Write-Host "Oxyra Quick Start Menu" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Start Mainnet Node"
Write-Host "2. Start Testnet Node"
Write-Host "3. Create New Wallet"
Write-Host "4. Start Mining (Solo)"
Write-Host "5. Check Node Status"
Write-Host "6. Exit"
Write-Host ""

`$choice = Read-Host "Enter your choice (1-6)"

switch (`$choice) {
    "1" {
        Write-Host "Starting Oxyra Mainnet Node..." -ForegroundColor Green
        ./build/release/bin/monerod.exe --data-dir ./oxyra-blockchain
    }
    "2" {
        Write-Host "Starting Oxyra Testnet Node..." -ForegroundColor Green
        ./build/release/bin/monerod.exe --testnet --data-dir ./oxyra-testnet
    }
    "3" {
        Write-Host "Creating new wallet..." -ForegroundColor Green
        ./build/release/bin/monero-wallet-cli.exe --generate-new-wallet my_wallet
    }
    "4" {
        `$address = Read-Host "Enter your wallet address"
        `$threads = Read-Host "Enter number of mining threads (default: 2)"
        if ([string]::IsNullOrWhiteSpace(`$threads)) { `$threads = "2" }
        Write-Host "Starting solo mining..." -ForegroundColor Green
        ./build/release/bin/monerod.exe --start-mining `$address --mining-threads `$threads
    }
    "5" {
        Write-Host "Checking node status..." -ForegroundColor Green
        ./build/release/bin/monerod.exe status
    }
    "6" {
        Write-Host "Goodbye!" -ForegroundColor Cyan
        exit
    }
    default {
        Write-Host "Invalid choice!" -ForegroundColor Red
    }
}
"@

Set-Content -Path "quickstart.ps1" -Value $quickStart
Write-Host "Created quickstart.ps1 for easy access to common commands" -ForegroundColor Green
