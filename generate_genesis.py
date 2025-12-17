#!/usr/bin/env python3
"""
Oxyra Genesis Block Generator

This script helps generate the genesis transaction for Oxyra blockchain
with a 3 billion OXRX premine.

Requirements:
- Python 3.6+
- You'll need to have a wallet address ready to receive the premine

Usage:
    python3 generate_genesis.py YOUR_WALLET_ADDRESS

The script will output the genesis transaction hex that you need to
update in src/cryptonote_config.h
"""

import sys
import hashlib
import struct

def create_premine_output(amount, address):
    """
    Create a transaction output for the premine
    Note: This is a simplified version. For production, you should use
    the actual Monero/Cryptonote transaction format.
    """
    print(f"""
╔═══════════════════════════════════════════════════════════════╗
║          OXYRA GENESIS TRANSACTION GENERATOR                 ║
╚═══════════════════════════════════════════════════════════════╝

IMPORTANT NOTES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. This is a TEMPLATE script. For production deployment, you need to:
   - Use proper Monero/Cryptonote transaction format
   - Create a valid RingCT transaction
   - Properly encode the destination address
   - Sign the transaction correctly

2. Recommended Approach:
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   Method A: Use Monero's Built-in Tools (Easiest)
   ------------------------------------------------
   a) First, build the Oxyra daemon
   b) Create a utility program using Monero's cryptonote libraries:
   
   #include "cryptonote_core/cryptonote_tx_utils.h"
   #include "cryptonote_basic/cryptonote_format_utils.h"
   
   // Create genesis transaction with premine
   // Amount: 3000000000 * COIN (3 billion with 12 decimals)
   // Destination: your_premine_address
   
   c) The utility will generate the proper hex blob
   
   Method B: Modify Existing Genesis (Advanced)
   ---------------------------------------------
   Take an existing Monero genesis transaction and:
   - Change the output amount to 3,000,000,000.000000000000
   - Update the destination key to your address
   - Recalculate transaction hash
   - Regenerate proof and signature
   
   Method C: Use Testnet for Testing
   ----------------------------------
   For initial testing, you can:
   - Use testnet with a simple genesis
   - Test mining and transactions
   - Once verified, create proper mainnet genesis

PREMINE CONFIGURATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Amount     : 3,000,000,000 OXRX
Atomic Units: 3,000,000,000,000,000,000,000 (with 12 decimals)
Address    : {address}
Hex Amount : {amount:x}

CURRENT GENESIS TRANSACTION IN CODE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The current genesis in src/cryptonote_config.h is Monero's default:
"013c01ff0001ffffffffffff03029b2e4c0281c0b02e7c53291a94d1d0cbff..."

This needs to be replaced with a transaction that:
✓ Has output of 3,000,000,000.000000000000 OXRX
✓ Sends to your premine wallet address
✓ Is properly formatted as RingCT transaction
✓ Has valid cryptographic proofs

TESTING WORKFLOW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Build Oxyra
-------------------
cd /d/temp/oxyrax
make release

Step 2: Generate Premine Wallet
--------------------------------
./build/release/bin/monero-wallet-cli --generate-new-wallet premine_wallet
> (save the address and seed!)

Step 3: Create Genesis Transaction Utility
-------------------------------------------
Create src/gen_genesis_tx.cpp:

#include <iostream>
#include "cryptonote_basic/cryptonote_format_utils.h"
#include "cryptonote_basic/cryptonote_basic.h"

int main() {{
    using namespace cryptonote;
    
    // Your premine address
    std::string address_str = "YOUR_PREMINE_ADDRESS_HERE";
    
    // 3 billion OXRX
    uint64_t amount = 3000000000ULL * COIN;
    
    // Create genesis transaction
    transaction tx;
    // ... (implementation using Monero's tx utils)
    
    // Output hex blob
    std::string tx_hex = epee::string_tools::buff_to_hex_nodelimer(
        t_serializable_object_to_blob(tx)
    );
    
    std::cout << "GENESIS_TX = \\"" << tx_hex << "\\";" << std::endl;
    
    return 0;
}}

Step 4: Compile and Run
------------------------
g++ -o gen_genesis_tx gen_genesis_tx.cpp -I./src -I./external \\
    -L./build/release/lib -lcommon -lcryptonote_basic -lcryptonote_core \\
    -lboost_system -lboost_filesystem

./gen_genesis_tx

Step 5: Update Configuration
-----------------------------
Copy the output and update src/cryptonote_config.h:
std::string const GENESIS_TX = "YOUR_NEW_GENESIS_HEX";

Step 6: Rebuild and Test
-------------------------
make clean && make release
./build/release/bin/monerod --testnet

ALTERNATIVE: QUICK START FOR TESTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For initial testing, you can temporarily use Monero's default genesis
and just test the following:
- Block time (120 seconds) ✓
- Zero block rewards ✓  
- Network connectivity on new ports ✓
- Mining with RandomX ✓
- Transaction fees only ✓

Then create proper genesis before mainnet launch.

RESOURCES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Monero Source: github.com/monero-project/monero
- CryptoNote Standard: cryptonote.org
- Monero Docs: www.getmonero.org/resources/developer-guides/
- Transaction Format: src/cryptonote_basic/cryptonote_format_utils.h

SECURITY WARNING:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  The premine wallet seed phrase is the KEY to 3 billion OXRX!
⚠️  Store it securely offline (multiple copies, different locations)
⚠️  Never share the seed phrase with anyone
⚠️  Use hardware wallet or cold storage for mainnet
⚠️  Test thoroughly on testnet before mainnet deployment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    """)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 generate_genesis.py YOUR_WALLET_ADDRESS")
        print("\nExample:")
        print("  python3 generate_genesis.py ox1234567890abcdef...")
        sys.exit(1)
    
    address = sys.argv[1]
    amount = 3000000000 * (10 ** 12)  # 3 billion with 12 decimals
    
    create_premine_output(amount, address)
    
    print("\n")
    print("═" * 80)
    print("NEXT STEPS:")
    print("═" * 80)
    print("1. Follow the 'Testing Workflow' above to create proper genesis")
    print("2. Or use testnet for initial testing with default genesis")
    print("3. Build: make release")
    print("4. Run: ./build/release/bin/monerod --testnet")
    print("5. Create wallet: ./build/release/bin/monero-wallet-cli --testnet")
    print("═" * 80)
