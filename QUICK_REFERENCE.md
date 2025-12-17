# Oxyra Quick Reference Guide

## Essential Information

**Coin**: Oxyra  
**Ticker**: OXRX  
**Algorithm**: RandomX (CPU-friendly)  
**Block Time**: 120 seconds  
**Block Reward**: 0 OXRX (miners earn transaction fees only)  
**Total Supply**: 3,000,000,000 OXRX (all premined)  
**Decimals**: 12  

## Network Configuration

### Mainnet
- **P2P Port**: 17080
- **RPC Port**: 17081
- **ZMQ Port**: 17082
- **Address Prefix**: `o` (e.g., o123abc...)

### Testnet
- **P2P Port**: 27080
- **RPC Port**: 27081
- **ZMQ Port**: 27082

### Stagenet
- **P2P Port**: 37080
- **RPC Port**: 37081
- **ZMQ Port**: 37082

## Quick Commands

### Build Oxyra
```bash
# Windows (MSYS2 MINGW64)
./build_oxyra.ps1

# Linux/macOS
chmod +x build_oxyra.sh
./build_oxyra.sh

# Manual build
make release
```

### Run Node
```bash
# Mainnet
./build/release/bin/monerod --data-dir ./oxyra-blockchain

# Testnet
./build/release/bin/monerod --testnet --data-dir ./oxyra-testnet

# Background
./build/release/bin/monerod --data-dir ./oxyra-blockchain --detach
```

### Wallet Operations
```bash
# Create wallet
./build/release/bin/monero-wallet-cli --generate-new-wallet my_wallet

# Restore from seed
./build/release/bin/monero-wallet-cli --restore-deterministic-wallet

# Connect to node
./build/release/bin/monero-wallet-cli --daemon-address localhost:17081 --wallet-file my_wallet
```

### Mining
```bash
# Solo mining (daemon)
./build/release/bin/monerod --start-mining YOUR_WALLET_ADDRESS --mining-threads 4

# XMRig (pool/solo)
./xmrig -o pool.example.com:3333 -u YOUR_WALLET_ADDRESS -k
```

## File Locations

### Modified Files
- `src/cryptonote_config.h` - Network config, economics
- `src/cryptonote_basic/cryptonote_basic_impl.cpp` - Zero block rewards

### New Files
- `OXYRA_SETUP_GUIDE.md` - Complete setup guide
- `POOL_SETUP_GUIDE.md` - Pool deployment guide
- `IMPLEMENTATION_SUMMARY.md` - Technical summary
- `pool_config_template.json` - Pool configuration
- `build_oxyra.sh` / `build_oxyra.ps1` - Build scripts
- `generate_genesis.py` - Genesis helper
- `src/gen_genesis_tx.cpp` - Genesis generator

## Important Notes

### ⚠️ Zero Block Rewards
- Miners receive **ONLY transaction fees**
- No block subsidy/coinbase reward
- Network security depends on transaction volume
- May need incentive mechanisms during low activity

### ⚠️ Premine Security
- 3 billion OXRX in genesis block
- Goes to premine wallet address
- **CRITICAL**: Secure the seed phrase
- Loss = loss of entire premine

### ⚠️ Genesis Block
- Must be generated before mainnet
- Contains premine transaction
- Cannot be changed after launch
- Test thoroughly on testnet first

## Troubleshooting

### Build Errors
```bash
# Clean and rebuild
make clean
rm -rf build
make release
```

### Node Won't Start
```bash
# Check ports
netstat -an | grep 17081

# Check logs
./build/release/bin/monerod --log-level 1

# Reset blockchain
rm -rf ./oxyra-blockchain
```

### Wallet Won't Connect
```bash
# Verify daemon is running
./build/release/bin/monerod status

# Check RPC port
curl http://localhost:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json'
```

### Mining Issues
- **No rewards**: Expected! Oxyra has zero block rewards
- **Fees earned**: Only from transactions in blocks you mine
- **Difficulty**: Adjust with pool or solo mining config

## Development Workflow

### 1. Initial Setup
```bash
git clone https://github.com/xaexaex/oxyrax.git
cd oxyrax
make release
```

### 2. Testing
```bash
# Start testnet node
./build/release/bin/monerod --testnet --data-dir ./test-data

# Create test wallet  
./build/release/bin/monero-wallet-cli --testnet --generate-new-wallet test

# Mine some blocks
./build/release/bin/monerod --testnet --start-mining YOUR_ADDRESS --mining-threads 2

# Send transaction (generates fees)
# In wallet: transfer ADDRESS AMOUNT
```

### 3. Genesis Generation
```bash
# Create premine wallet
./build/release/bin/monero-wallet-cli --generate-new-wallet premine

# Generate genesis TX (see guides)
# Update src/cryptonote_config.h
# Rebuild
make clean && make release
```

### 4. Mainnet Launch
```bash
# Deploy seed nodes
# Start daemon
./build/release/bin/monerod --data-dir ./mainnet-data --detach

# Monitor
tail -f mainnet-data/bitmonero.log
```

## Pool Setup Summary

### Requirements
- Ubuntu 20.04+ or CentOS 8+
- Node.js 16+
- Redis 6+
- Oxyra daemon + wallet RPC
- 4GB+ RAM, 50GB+ storage

### Quick Setup
```bash
# Install pool software
git clone https://github.com/dvandal/cryptonote-nodejs-pool.git
cd cryptonote-nodejs-pool
npm install

# Configure (use pool_config_template.json)
cp config_example.json config.json
nano config.json

# Start pool
node init.js
```

### Pool Ports
- **3333**: Low-end miners
- **5555**: Mid-range miners
- **7777**: High-end miners
- **8117**: Pool API/frontend

## Useful Links

### Documentation
- Full Setup: `OXYRA_SETUP_GUIDE.md`
- Pool Setup: `POOL_SETUP_GUIDE.md`
- Implementation: `IMPLEMENTATION_SUMMARY.md`

### External Resources
- Monero: https://github.com/monero-project/monero
- RandomX: https://github.com/tevador/RandomX
- Pool Software: https://github.com/dvandal/cryptonote-nodejs-pool
- XMRig: https://github.com/xmrig/xmrig

## Common Scenarios

### Scenario 1: Developer Testing
```bash
make release
./build/release/bin/monerod --testnet --data-dir ./test
./build/release/bin/monero-wallet-cli --testnet --generate-new-wallet test
# Test transactions, mining, etc.
```

### Scenario 2: Pool Operator
```bash
# Build node
make release
# Set up daemon + wallet RPC (systemd services)
# Install pool software
# Configure for Oxyra
# Deploy frontend
# Test with XMRig
```

### Scenario 3: Solo Miner
```bash
# Run full node
./build/release/bin/monerod --data-dir ./data
# Create wallet
./build/release/bin/monero-wallet-cli --generate-new-wallet mining
# Start mining
./build/release/bin/monerod --start-mining YOUR_ADDRESS --mining-threads 4
```

### Scenario 4: Exchange Integration
```bash
# Run full node with RPC
./build/release/bin/monerod --rpc-bind-ip 127.0.0.1 --rpc-bind-port 17081
# Run wallet RPC
./build/release/bin/monero-wallet-rpc --wallet-file exchange --rpc-bind-port 17082
# Integrate with exchange backend
# Monitor deposits/withdrawals
```

## Key Differences from Monero

| Aspect | Monero | Oxyra |
|--------|--------|-------|
| Name | bitmonero | oxyra |
| Block Reward | Yes (~0.6 XMR) | No (0 OXRX) |
| Supply | Unlimited | 3B fixed |
| P2P Port | 18080 | 17080 |
| RPC Port | 18081 | 17081 |
| Address | 4... | o... |
| Premine | None | 3B OXRX |

## Security Checklist

- [ ] Premine wallet seed stored securely offline
- [ ] Multiple backup copies in different locations
- [ ] Node firewall configured correctly
- [ ] RPC not exposed to internet
- [ ] SSL/TLS for pool connections
- [ ] Regular backups of wallets and databases
- [ ] Monitoring and alerting set up
- [ ] Security updates applied regularly

## Contact & Support

- GitHub Issues: https://github.com/xaexaex/oxyrax/issues
- Read guides: OXYRA_SETUP_GUIDE.md, POOL_SETUP_GUIDE.md
- Check logs: `tail -f oxyra.log`
- Community: (Add Discord/Telegram when available)

---

**Remember**: Test everything on testnet before mainnet deployment!

**Version**: 1.0 (based on Monero v0.18.x)
