#!/bin/bash
# Generate simple testnet genesis for Oxyra

echo "Generating testnet genesis for Oxyra..."

# For testnet, we can use a simplified genesis
# This is just for testing - mainnet needs proper premine genesis

cat > /tmp/genesis_info.txt << 'GENESIS'
Testnet Genesis Transaction:
This is a temporary genesis for Oxyra testnet.
For mainnet, you MUST generate proper genesis with 3B premine.
GENESIS

echo "Testnet genesis prepared."
echo "You can now start the testnet node."
