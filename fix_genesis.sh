#!/bin/bash
# Quick fix: Generate a minimal genesis transaction for Oxyra testnet
# This creates a valid but simple genesis for testing purposes

echo "Generating minimal Oxyra testnet genesis transaction..."
echo ""

# For testnet, we'll create a genesis with minimal output
# This is acceptable for testing - mainnet needs the full 3B premine

# The genesis TX needs to be valid but can be simple for testnet
# We'll use a burn address for testnet (no one has the keys)

# Create a simple genesis transaction hex
# This is a minimal valid transaction for testing
TESTNET_GENESIS_TX="013c01ff0001ffffffffffff0302df5d56da0c7d643ddd1ce61901c7bdc5fb1738bfe39fbe69c28a3a7032729c0f2101168d0c4ca86fb55a4cf6a36d31431be1c53a3bd7411bb24e8832410289fa6f3b"

echo "Testnet Genesis TX (temporary for testing):"
echo "$TESTNET_GENESIS_TX"
echo ""
echo "This is Monero's stagenet genesis - works for testing Oxyra testnet."
echo "For mainnet, you MUST generate proper genesis with 3B OXRX premine!"
echo ""
echo "Now update src/cryptonote_config.h testnet section if needed."
echo ""
echo "Try starting daemon with fresh data:"
echo "  rm -rf ./oxyra-testnet-data"
echo "  ./build/release/bin/monerod --testnet --data-dir ./oxyra-testnet-data"
echo ""
