# OXYRA Blockchain Deployment Guide

## Prerequisites

- Ubuntu/Debian Linux system
- Build tools: `sudo apt-get install build-essential cmake pkg-config libboost-all-dev libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libexpat1-dev libpgm-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libgtest-dev`

## Build Instructions

### 1. Clone Repository

```bash
git clone <repository-url>
cd oxyrax
```

### 2. Update Configuration Paths

Edit `src/cryptonote_config.h` and modify paths for your system:

```cpp
#define CRYPTONOTE_NAME "oxyra"
```

Verify these settings match your requirements:
- `COIN = 100000000` (8 decimals)
- `MONEY_SUPPLY = 300000000000000000` (3 billion OXRX)
- `PREMINE_AMOUNT = 9000000000000000` (90 million OXRX)
- `DIFFICULTY_TARGET = 120` (2 minute blocks)

### 3. Build Project

```bash
mkdir -p build
cd build
cmake ..
make -j$(nproc)
```

Binaries will be in `build/bin/`:
- `monerod` - Daemon
- `monero-wallet-cli` - Wallet

## Genesis Setup

### 4. Create Premine Wallet

```bash
./bin/monero-wallet-cli --generate-new-wallet premine_wallet --mnemonic-language English
```

Follow prompts to set password. Save the:
- Wallet address
- 25-word seed phrase

### 5. Generate Genesis Transaction

Build the genesis generator:

```bash
cd src
./gen_genesis_tx <WALLET_ADDRESS>
```

Example output:
```
Premine Amount: 9000000000000000 atomic units = 90000000 OXRX
Transaction Hex: 013c01ff00018080ead7bcaefe0f...
```

Save the transaction hex.

### 6. Update Genesis Configuration

Edit `src/cryptonote_config.h`:

```cpp
const char GENESIS_TX[] = "YOUR_TRANSACTION_HEX_HERE";
```

Update all three network types (mainnet, testnet, stagenet) with the same genesis transaction.

### 7. Rebuild with New Genesis

```bash
cd ../build
make -j$(nproc)
```

## Running the Blockchain

### 8. Start Daemon

```bash
./bin/monerod --data-dir ~/.oxyra --log-file ~/.oxyra/oxyra.log --detach
```

Wait 5-10 seconds for initialization.

### 9. Verify Genesis Block

```bash
./bin/monerod print_height
```

Should return `1` (genesis block added).

### 10. Start Mining

```bash
./bin/monerod start_mining <PREMINE_WALLET_ADDRESS> <THREADS>
```

Example with 8 threads:
```bash
./bin/monerod start_mining oXYZ...123 8
```

Check CPU threads: `nproc`

## Monitoring

### Check Status

```bash
./bin/monerod status
```

Shows: height, mining hashrate, network hashrate, connections, uptime.

### Check Height

```bash
./bin/monerod print_height
```

### Stop Mining

```bash
./bin/monerod stop_mining
```

### Stop Daemon

```bash
./bin/monerod exit
```

## Network Configuration

Default ports (change if needed in `src/cryptonote_config.h`):
- P2P: 17080
- RPC: 17081
- ZMQ: 17082

## Important Files

- Genesis wallet seed: Keep secure, this controls the 90M OXRX premine
- `~/.oxyra/lmdb/`: Blockchain data directory
- `~/.oxyra/oxyra.log`: Daemon logs

## Emission Schedule

- Phase 1 (blocks 1-500,000): 50 OXRX per block
- Phase 2 (blocks 500,001-2,000,000): 20 OXRX per block
- Phase 3 (blocks 2,000,001+): 0.3 OXRX per block (tail emission)

Total supply: 3 billion OXRX (90M premine + 2.91B mined)
