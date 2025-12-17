#!/bin/bash
# Simple Oxyra Build Script (minimal, no prompts)
# Use this if the main build script has issues

set -e

echo "================================"
echo "  Oxyra Simple Build Script"
echo "================================"
echo ""

# Update submodules
echo "[1/5] Updating submodules..."
git submodule update --init --recursive --force
echo "✓ Done"
echo ""

# Clean old build
echo "[2/5] Cleaning old build..."
rm -rf build
echo "✓ Done"
echo ""

# Create build directory
echo "[3/5] Creating build directory..."
mkdir -p build/release
cd build/release
echo "✓ Done"
echo ""

# Run CMake
echo "[4/5] Running CMake (optimized for faster build)..."
cmake -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_TESTS=OFF \
    -D BUILD_DOCUMENTATION=OFF \
    -D ARCH="x86-64" \
    ../..

if [ $? -ne 0 ]; then
    echo "ERROR: CMake failed!"
    exit 1
fi
echo "✓ Done"
echo ""

# Build only essential targets (faster)
echo "[5/5] Building core binaries only (much faster)..."
echo "Building: monerod and monero-wallet-cli"
make -j2 daemon wallet_cli

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Build failed!"
    echo ""
    echo "Common solutions:"
    echo "1. You may have run out of RAM. Try: make -j1 (slower, uses less RAM)"
    echo "2. Check error messages above"
    echo "3. Ensure all dependencies are installed"
    exit 1
fi

cd ../..

echo ""
echo "================================"
echo "  BUILD SUCCESSFUL!"
echo "================================"
echo ""
echo "Binaries are in: build/release/bin/"
echo ""
if [ -f build/release/bin/monerod ]; then
    ls -lh build/release/bin/monerod
fi
if [ -f build/release/bin/monero-wallet-cli ]; then
    ls -lh build/release/bin/monero-wallet-cli
fi
echo ""
echo "To run:"
echo "  ./build/release/bin/monerod --testnet"
echo ""
