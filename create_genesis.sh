#!/bin/bash
# Create a test premine wallet for Oxyra genesis block

WALLET_FILE="/tmp/oxyra_premine_genesis_test"
rm -f "$WALLET_FILE"*

cd /mnt/d/temp/oxyrax/build/bin

# Create wallet non-interactively
./monero-wallet-cli \
  --generate-new-wallet "$WALLET_FILE" \
  --password "" \
  --mnemonic-language English \
  --command "address; exit" \
  --offline 2>&1 | tee /tmp/wallet_output.txt

# Extract the address
ADDRESS=$(grep -oP 'ox[a-zA-Z0-9]{95}' /tmp/wallet_output.txt | head -1)

if [ -z "$ADDRESS" ]; then
    echo "Failed to extract address, trying alternative method..."
    ADDRESS=$(cat /tmp/wallet_output.txt | grep -A 2 "Standard address" | grep "^ox" | head -1 | tr -d ' ')
fi

echo ""
echo "========================================"
echo "PREMINE WALLET ADDRESS:"
echo "$ADDRESS"
echo "========================================"
echo ""
echo "Now generating genesis transaction..."
echo ""

# Generate the genesis transaction
cd /mnt/d/temp/oxyrax/build
if [ -n "$ADDRESS" ]; then
    ./gen_genesis_tx "$ADDRESS"
else
    echo "ERROR: Could not extract wallet address!"
    exit 1
fi
