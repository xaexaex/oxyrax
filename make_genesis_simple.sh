#!/bin/bash
# Quick script to generate a genesis transaction for Oxyra
# Uses a deterministic test address

cd /mnt/d/temp/oxyrax/build

# Use a fixed test address for the premine (deterministic, for testing only)
# This address is generated from a well-known test seed
# DO NOT USE IN PRODUCTION - this is for testing only!
TEST_ADDRESS="ox11111111111111111111111111111111111111111111111111111111111111111111111"

echo "Generating genesis transaction..."
echo "WARNING: Using test address for genesis (not for production)"
echo "Address: $TEST_ADDRESS"
echo ""

# Run the genesis generator
./gen_genesis_tx "$TEST_ADDRESS"
