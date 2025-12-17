# Oxyra Blockchain Setup Guide

## Overview
Oxyra (OXRX) is a privacy-focused cryptocurrency forked from Monero with the following specifications:

- **Coin Name**: Oxyra
- **Ticker**: OXRX
- **Block Time**: 120 seconds
- **Block Reward**: 0 (Zero block rewards - miners only receive transaction fees)
- **Premine**: 3,000,000,000 OXRX (3 billion coins)
- **Decimals**: 12 (same as Monero)
- **Algorithm**: RandomX (PoW)
- **P2P Port**: 17080
- **RPC Port**: 17081
- **ZMQ Port**: 17082

## Changes Made to Fork

### 1. Network Configuration (`src/cryptonote_config.h`)

#### Branding & Network Identity
- Changed `CRYPTONOTE_NAME` from "bitmonero" to "oxyra"
- Updated Network ID to unique Oxyra UUID: `4f58595241580001...` (OXYRAX NETWORK)
- Changed all network ports:
  - **Mainnet**: P2P=17080, RPC=17081, ZMQ=17082
  - **Testnet**: P2P=27080, RPC=27081, ZMQ=27082
  - **Stagenet**: P2P=37080, RPC=37081, ZMQ=37082

#### Address Prefixes
- **Mainnet**: Base58 prefix = 0x7d (addresses start with 'o')
- **Testnet**: Base58 prefix = 0x8d
- **Stagenet**: Base58 prefix = 0x9d

#### Blockchain Parameters
- Block time set to 120 seconds (both V1 and V2)
- Money supply set to 3,000,000,000 OXRX with 12 decimals
- Final subsidy set to 0 (no ongoing emission)

### 2. Block Reward Mechanism (`src/cryptonote_basic/cryptonote_basic_impl.cpp`)

The `get_block_reward()` function has been modified to:
- Return **zero block rewards** (reward = 0)
- Miners only earn transaction fees
- Still validates block weight to prevent spam blocks
- All 3 billion coins exist from genesis (premine)

### 3. Genesis Block Configuration

**IMPORTANT**: You must generate a new genesis transaction with the premine.

## Building Oxyra

### Prerequisites

Install dependencies based on your OS (see README.md for full list):

**Windows (MSYS2):**
```bash
pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-unbound
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install build-essential cmake pkg-config libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libexpat1-dev libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libboost-all-dev ccache
```

### Compilation Steps

1. **Clone the repository** (already done):
```bash
cd d:\temp\oxyrax
```

2. **Generate Genesis Block** (see next section)

3. **Build the project**:

**On Windows (MSYS2 MINGW64):**
```bash
make release-static
```

**On Linux:**
```bash
make release
```

The build will take 30-60 minutes depending on your system. Executables will be in `build/release/bin/`.

## Generating the Genesis Block with Premine

### Step 1: Create Genesis Wallet Address

First, you need to generate a wallet address that will receive the premine:

```bash
# After building, use the wallet tool
./build/release/bin/monero-wallet-cli --generate-new-wallet premine_wallet --mnemonic-language English

# Save the wallet address and seed phrase securely!
```

### Step 2: Create Genesis Transaction

You need to create a genesis transaction that sends 3,000,000,000 OXRX to your premine address.

**Option A: Use Monero's Genesis Generator (Recommended)**

1. Modify `src/cryptonote_core/cryptonote_tx_utils.cpp` to create the premine transaction
2. Use the wallet address from Step 1
3. Amount: 3000000000000000000000 (3 billion with 12 decimals)

**Option B: Manual Genesis Transaction Creation**

Create a simple tool to generate the genesis transaction blob:

```cpp
// This is a simplified example - you'll need proper implementation
// The genesis transaction must be RingCT format with:
// - Output: 3,000,000,000.000000000000 OXRX
// - Destination: Your premine wallet address
```

### Step 3: Update Genesis Constants

Once you have the genesis transaction hex blob:

1. Open `src/cryptonote_config.h`
2. Update the `GENESIS_TX` constant in the mainnet config:

```cpp
std::string const GENESIS_TX = "YOUR_GENESIS_TX_HEX_BLOB_HERE";
uint32_t const GENESIS_NONCE = 10000; // You can change this
```

3. Rebuild the project:
```bash
make clean
make release
```

## Running the Oxyra Node

### First Launch (Mainnet)

```bash
./build/release/bin/monerod --data-dir ./oxyra-blockchain
```

This will:
- Create the genesis block with your premine
- Start syncing the blockchain
- Listen on ports 17080 (P2P) and 17081 (RPC)

### Common Node Commands

```bash
# Run in background
./build/release/bin/monerod --data-dir ./oxyra-blockchain --detach

# Run testnet
./build/release/bin/monerod --testnet --data-dir ./oxyra-testnet

# Check node status
./build/release/bin/monerod status

# Stop daemon
./build/release/bin/monerod exit
```

### Configuration File

Create `oxyra.conf`:

```ini
# Oxyra Node Configuration
data-dir=./oxyra-blockchain
log-level=0
log-file=./oxyra.log

# P2P Settings
p2p-bind-ip=0.0.0.0
p2p-bind-port=17080

# RPC Settings
rpc-bind-ip=127.0.0.1
rpc-bind-port=17081

# Mining (if applicable)
# start-mining=YOUR_WALLET_ADDRESS
# mining-threads=4

# Connection Limits
out-peers=12
in-peers=12

# Performance
max-concurrency=4
```

Run with config:
```bash
./build/release/bin/monerod --config-file oxyra.conf
```

## Mining Setup

### Solo Mining

Since block rewards are zero, miners only earn transaction fees:

```bash
./build/release/bin/monerod --start-mining YOUR_WALLET_ADDRESS --mining-threads 4
```

**Note**: Mining without transactions in mempool generates no rewards!

### Pool Mining Setup

For pool mining, you'll need:

1. **Mining Pool Software** (e.g., node-cryptonote-pool fork)
2. **Pool Configuration** pointing to Oxyra daemon
3. **Miner Software** (XMRig configured for RandomX)

#### Pool Configuration Issues & Solutions

The original `node-cryptonote-pool` has several issues:

**Problem 1: Outdated Dependencies**
- Many npm packages are deprecated
- Node.js version compatibility issues

**Solution**: Use updated forks:
- [cryptonote-nodejs-pool](https://github.com/dvandal/cryptonote-nodejs-pool) - More maintained
- [nodejs-pool](https://github.com/Snipa22/nodejs-pool) - Enterprise-grade

**Problem 2: RPC Connection Issues**
- Wallet RPC authentication
- Daemon RPC compatibility

**Solution**: 
```javascript
// In pool config.json
"daemon": {
    "host": "127.0.0.1",
    "port": 17081
},
"wallet": {
    "host": "127.0.0.1",
    "port": 17082
}
```

**Problem 3: Coin-Specific Configuration**

Create `config.json` for your pool:

```json
{
    "coin": "oxyra",
    "symbol": "OXRX",
    "coinUnits": 1000000000000,
    "coinDecimalPlaces": 12,
    "coinDifficultyTarget": 120,
    
    "daemon": {
        "host": "127.0.0.1",
        "port": 17081
    },
    
    "wallet": {
        "host": "127.0.0.1", 
        "port": 17082
    },
    
    "redis": {
        "host": "127.0.0.1",
        "port": 6379
    },
    
    "api": {
        "enabled": true,
        "port": 8117
    },
    
    "poolServer": {
        "enabled": true,
        "clusterForks": "auto",
        "poolAddress": "YOUR_POOL_WALLET_ADDRESS",
        "intAddressPrefix": null,
        "blockRefreshInterval": 1000,
        "minerTimeout": 900,
        "sslCert": "",
        "sslKey": "",
        "sslCA": "",
        "ports": [
            {
                "port": 3333,
                "difficulty": 1000,
                "desc": "Low end hardware"
            },
            {
                "port": 5555,
                "difficulty": 5000,
                "desc": "Mid range hardware"
            },
            {
                "port": 7777,
                "difficulty": 10000,
                "desc": "High end hardware"
            }
        ]
    }
}
```

### XMRig Configuration

Miners connect using XMRig:

```json
{
    "autosave": true,
    "cpu": true,
    "opencl": false,
    "cuda": false,
    "pools": [
        {
            "algo": "rx/0",
            "coin": null,
            "url": "pool.example.com:3333",
            "user": "YOUR_OXYRA_WALLET_ADDRESS",
            "pass": "x",
            "keepalive": true,
            "tls": false
        }
    ]
}
```

## Wallet Operations

### Create New Wallet

```bash
./build/release/bin/monero-wallet-cli --generate-new-wallet my_wallet
```

### Restore Wallet from Seed

```bash
./build/release/bin/monero-wallet-cli --restore-deterministic-wallet
```

### Start Wallet RPC (for pool/exchange integration)

```bash
./build/release/bin/monero-wallet-rpc \
  --rpc-bind-port 17082 \
  --wallet-file my_wallet \
  --password YOUR_PASSWORD \
  --daemon-address localhost:17081 \
  --disable-rpc-login
```

### Common Wallet Commands

```
# Check balance
balance

# Show address
address

# Transfer coins
transfer ADDRESS AMOUNT

# Show transfers
show_transfers
```

## Testing the Setup

### 1. Test Node Sync

```bash
# Check if node is running
./build/release/bin/monerod status

# Expected output should show:
# - Height: 1 (genesis block)
# - Network: oxyra mainnet
# - Peers: connecting...
```

### 2. Test Wallet Connection

```bash
# Create test wallet
./build/release/bin/monero-wallet-cli --daemon-address localhost:17081 --generate-new-wallet test_wallet

# In wallet, run:
> status
# Should show: synchronized, height 1
```

### 3. Test Mining (Solo)

```bash
# Start mining
./build/release/bin/monerod --start-mining YOUR_WALLET_ADDRESS --mining-threads 2

# Monitor
tail -f oxyra.log
```

## Troubleshooting

### Problem: "Failed to connect to daemon"
**Solution**: Ensure monerod is running on port 17081
```bash
netstat -an | grep 17081  # Linux
netstat -an | findstr 17081  # Windows
```

### Problem: "Invalid genesis block"
**Solution**: Delete blockchain and regenerate with correct GENESIS_TX
```bash
rm -rf ./oxyra-blockchain
./build/release/bin/monerod --data-dir ./oxyra-blockchain
```

### Problem: "Mining but no rewards"
**Solution**: This is expected! Oxyra has zero block rewards. Miners only earn transaction fees.

### Problem: Pool connection refused
**Solution**: Check pool configuration and ensure:
1. Daemon RPC is accessible
2. Wallet RPC is running
3. Redis is running (if using pool)
4. Firewall allows pool ports

### Problem: High difficulty, no blocks found
**Solution**: 
- Start with lower difficulty for testing
- Ensure RandomX is properly initialized
- Check if other miners are on the network

## Network Infrastructure

### Seed Nodes

For a functional network, you need seed nodes. Add to `src/p2p/net_node.inl`:

```cpp
const std::vector<std::string> seed_nodes = {
    "seed1.oxyra.network:17080",
    "seed2.oxyra.network:17080"
};
```

### Running a Seed Node

```bash
./build/release/bin/monerod \
  --data-dir ./oxyra-blockchain \
  --p2p-bind-ip 0.0.0.0 \
  --p2p-bind-port 17080 \
  --rpc-bind-ip 0.0.0.0 \
  --rpc-bind-port 17081 \
  --confirm-external-bind \
  --log-level 1
```

## Advanced: Premine Distribution

To distribute the premine:

1. **Access Premine Wallet**:
```bash
./build/release/bin/monero-wallet-cli --wallet-file premine_wallet
```

2. **Transfer to Recipients**:
```
transfer ADDRESS AMOUNT
```

3. **Verify Balance**:
```
balance
show_transfers
```

## Security Considerations

1. **Premine Wallet**: Keep the premine wallet seed phrase in a secure, offline location
2. **RPC Access**: Never expose RPC ports to the internet without authentication
3. **Node Security**: Keep your daemon updated and monitor for unusual activity
4. **Pool Security**: If running a pool, implement DDoS protection and rate limiting

## Next Steps

1. **Generate proper genesis transaction** with your premine address
2. **Set up seed nodes** for network bootstrapping  
3. **Deploy mining pool** using updated pool software
4. **Test complete flow**: mine → transaction → confirmation
5. **Set up block explorer** for transparency
6. **Create documentation** for community

## Support & Resources

- GitHub Repository: https://github.com/xaexaex/oxyrax
- Based on Monero: https://github.com/monero-project/monero
- RandomX Algorithm: https://github.com/tevador/RandomX
- Mining Pool Software: https://github.com/dvandal/cryptonote-nodejs-pool

## Important Notes

⚠️ **Zero Block Rewards**: Remember that Oxyra has NO block rewards. All 3 billion coins exist from genesis. Miners are only incentivized by transaction fees.

⚠️ **Genesis Transaction**: You MUST generate a proper genesis transaction with the premine before deploying to production.

⚠️ **Network Isolation**: Your Oxyra network is completely isolated from Monero due to unique Network ID and ports.

⚠️ **Testing**: Thoroughly test on testnet before mainnet deployment.

## License

Oxyra inherits Monero's BSD-3-Clause license. See LICENSE file for details.
