#!/bin/bash
# Ultra-fast Oxyra Build (daemon only, no wallet)
# Builds only the core daemon - fastest option

set -e

echo "================================"
echo "  Oxyra FAST Build (daemon only)"
echo "================================"
echo ""

# Update submodules
echo "[1/4] Updating submodules..."
git submodule update --init --recursive --force
echo "✓ Done"
echo ""

# Clean old build
echo "[2/4] Cleaning old build..."
rm -rf build
echo "✓ Done"
echo ""

# Create build directory
echo "[3/4] Creating build directory..."
mkdir -p build/release
cd build/release
echo "✓ Done"
echo ""

# Run CMake with minimal options
echo "[4/4] Building monerod only (fastest)..."
cmake -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_TESTS=OFF \
    -D BUILD_DOCUMENTATION=OFF \
    -D ARCH="x86-64" \
    ../..

# Build only daemon with 4 cores
echo "Building daemon with 4 cores..."
make -j4 daemon

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Build failed!"
    echo "Try with fewer cores: make -j2 daemon"
    exit 1
fi

cd ../..

echo ""
echo "================================"
echo "  BUILD SUCCESSFUL!"
echo "================================"
echo ""
echo "Daemon built: build/release/bin/monerod"
echo ""
ls -lh build/release/bin/monerod
echo ""
echo "To run:"
echo "  ./build/release/bin/monerod --testnet"
echo ""
echo "To build wallet later:"
echo "  cd build/release && make -j2 wallet_cli"
echo ""
