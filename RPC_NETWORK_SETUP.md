# Oxyra RPC Network Setup Guide

## Understanding RPC Binding

### Current Setup (Localhost Only)
```bash
./monerod --rpc-bind-ip=127.0.0.1 --rpc-bind-port=17081 --confirm-external-bind --offline --disable-dns-checkpoints
```

**What this means:**
- `--rpc-bind-ip=127.0.0.1` → Only accepts connections from **the same machine**
- External wallets, miners, or pool software **cannot connect**
- Secure but limited to local use

---

## Binding to Your Public IP

### Option 1: Bind to Specific Public IP
```bash
./monerod --rpc-bind-ip=YOUR_PUBLIC_IP --rpc-bind-port=17081 --confirm-external-bind --offline --disable-dns-checkpoints
```

**Example:**
```bash
./monerod --rpc-bind-ip=203.0.113.45 --rpc-bind-port=17081 --confirm-external-bind --offline --disable-dns-checkpoints
```

**Use when:**
- Your server has a static public IP
- You know exactly which IP to bind to
- You want to restrict to one network interface

---

### Option 2: Bind to All Interfaces (Recommended)
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --offline --disable-dns-checkpoints
```

**What this means:**
- `0.0.0.0` → Listens on **all network interfaces**
- Accepts connections from any IP (localhost, LAN, internet)
- Most flexible for pools and public nodes

---

## Adding Security (CRITICAL!)

### Minimum Security Setup
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:YOUR_STRONG_PASSWORD --offline --disable-dns-checkpoints
```

### Restricted RPC (Public Node)
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --restricted-rpc --offline --disable-dns-checkpoints
```

### Full Security (Pool/Private Setup)
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:YOUR_STRONG_PASSWORD --rpc-access-control-origins http://your-pool.com --offline --disable-dns-checkpoints
```

---

## Flag Explanations

| Flag | Purpose |
|------|---------|
| `--rpc-bind-ip=IP` | IP address to listen on (127.0.0.1=localhost, 0.0.0.0=all) |
| `--rpc-bind-port=17081` | Port number for RPC (17081=mainnet, 27081=testnet) |
| `--confirm-external-bind` | **Required** when binding to non-localhost |
| `--rpc-login user:pass` | **Protect RPC with username/password** |
| `--restricted-rpc` | Limit RPC to safe read-only commands |
| `--offline` | Don't connect to other nodes (solo/testing) |
| `--disable-dns-checkpoints` | Skip DNS checkpoint verification |

---

## Connecting Nodes to Main Node (P2P Network)

### Understanding Node Connections

- **P2P Port 17080** (mainnet) or **27080** (testnet): Used for node-to-node communication
- **RPC Port 17081**: Used for wallet/API connections (covered above)
- Nodes need to connect via P2P to sync blockchain and share transactions

---

### Setting Up Main/Seed Node

The **main node** acts as the first/seed node that other nodes connect to:

```bash
# Main node with public P2P access
./monerod --p2p-bind-ip=0.0.0.0 --p2p-bind-port=17080 --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind
```

**With specific external IP (recommended):**
```bash
./monerod --p2p-bind-ip=0.0.0.0 --p2p-bind-port=17080 --p2p-external-port=17080 --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:password
```

**Open P2P firewall port:**
```powershell
# Windows
New-NetFirewallRule -DisplayName "Oxyra P2P" -Direction Inbound -LocalPort 17080 -Protocol TCP -Action Allow

# Linux (UFW)
sudo ufw allow 17080/tcp
```

---

### Connecting Additional Nodes to Main Node

**Node 2, 3, 4... connecting to main node:**

```bash
# Connect to main node at 203.0.113.45
./monerod --add-peer 203.0.113.45:17080 --p2p-bind-port=17080 --rpc-bind-port=17081
```

**Connect to multiple seed nodes:**
```bash
./monerod --add-peer 203.0.113.45:17080 --add-peer 198.51.100.20:17080 --add-peer 192.0.2.10:17080 --p2p-bind-port=17080 --rpc-bind-port=17081
```

**Exclusive connection (only connect to specified nodes):**
```bash
./monerod --add-exclusive-node 203.0.113.45:17080 --p2p-bind-port=17080 --rpc-bind-port=17081
```

**Priority node (always try to maintain connection):**
```bash
./monerod --add-priority-node 203.0.113.45:17080 --p2p-bind-port=17080 --rpc-bind-port=17081
```

---

### P2P Connection Flags Explained

| Flag | Purpose |
|------|---------|
| `--p2p-bind-ip=0.0.0.0` | Listen for P2P connections on all interfaces |
| `--p2p-bind-port=17080` | P2P port to listen on (17080=mainnet, 27080=testnet) |
| `--p2p-external-port=17080` | External port if different from bind port (NAT/router) |
| `--add-peer IP:PORT` | Connect to this peer on startup |
| `--add-exclusive-node IP:PORT` | ONLY connect to these nodes (ignore others) |
| `--add-priority-node IP:PORT` | Always maintain connection to this node |
| `--seed-node IP:PORT` | Use as seed node for peer discovery |
| `--hide-my-port` | Don't announce P2P port to other nodes |
| `--offline` | Don't connect to any peers (solo mode) |

---

### Multi-Node Network Setup Examples

#### Example 1: 3-Node Network

**Node 1 (Main Seed) - IP: 203.0.113.45**
```bash
./monerod --p2p-bind-ip=0.0.0.0 --p2p-bind-port=17080 --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:pass1
```

**Node 2 (Backup Seed) - IP: 198.51.100.20**
```bash
./monerod --add-peer 203.0.113.45:17080 --p2p-bind-ip=0.0.0.0 --p2p-bind-port=17080 --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:pass2
```

**Node 3 (Regular Node) - IP: 192.0.2.10**
```bash
./monerod --add-peer 203.0.113.45:17080 --add-peer 198.51.100.20:17080 --p2p-bind-port=17080 --rpc-bind-port=17081
```

#### Example 2: Private Pool Network

**Mining Pool Node:**
```bash
./monerod --add-exclusive-node MAIN_NODE_IP:17080 --p2p-bind-port=17080 --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login pooladmin:SecurePass
```

**Wallet connects to pool node locally:**
```bash
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 127.0.0.1:17081 --daemon-login pooladmin:SecurePass --rpc-bind-port 17083
```

#### Example 3: Testnet Multi-Node

**Testnet Node 1:**
```bash
./monerod --testnet --p2p-bind-ip=0.0.0.0 --p2p-bind-port=27080 --rpc-bind-port=27081
```

**Testnet Node 2:**
```bash
./monerod --testnet --add-peer NODE1_IP:27080 --p2p-bind-port=27080 --rpc-bind-port=27081
```

---

### Verifying Node Connections

**Check connected peers:**
```bash
curl http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_connections"}' -H 'Content-Type: application/json'
```

**With authentication:**
```bash
curl -u admin:password http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_connections"}' -H 'Content-Type: application/json'
```

**Check peer count:**
```bash
curl http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json' | grep -i "incoming\|outgoing"
```

**Using daemon command line:**
```bash
# After starting daemon, in another terminal:
./monerod --rpc-bind-port=17081 status
./monerod --rpc-bind-port=17081 print_cn  # Show connections
```

---

### Network Configuration Tips

**For seed nodes:**
- Use static public IP addresses
- Open both P2P (17080) and RPC (17081) ports
- Use `--p2p-bind-ip=0.0.0.0` to accept all connections
- Consider `--rpc-login` for security

**For regular nodes:**
- Connect to multiple seed nodes for redundancy
- Can use `--hide-my-port` if behind NAT
- Use `--add-priority-node` for critical peers

**For private networks:**
- Use `--add-exclusive-node` to create closed network
- Disable DNS seeds with `--disable-dns-checkpoints`
- Use `--offline` flag during testing

---

## Network Configuration

### 1. Find Your Public IP
```bash
# Windows PowerShell
(Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Linux/macOS
curl https://api.ipify.org
```

### 2. Open Firewall Ports

**Windows Firewall:**
```powershell
# P2P Port (node connections)
New-NetFirewallRule -DisplayName "Oxyra P2P" -Direction Inbound -LocalPort 17080 -Protocol TCP -Action Allow

# RPC Port (wallet/API)
New-NetFirewallRule -DisplayName "Oxyra RPC" -Direction Inbound -LocalPort 17081 -Protocol TCP -Action Allow

# Wallet RPC Port (optional)
New-NetFirewallRule -DisplayName "Oxyra Wallet RPC" -Direction Inbound -LocalPort 17083 -Protocol TCP -Action Allow
```

**Linux (UFW):**
```bash
sudo ufw allow 17080/tcp  # P2P
sudo ufw allow 17081/tcp  # RPC
sudo ufw allow 17083/tcp  # Wallet RPC (optional)
```/NAT:
- Log into router admin panel
- Forward these ports to your server's **local IP**:
  - **17080** (TCP) → P2P connections
  - **17081** (TCP) → RPC access
  - **17083** (TCP) → Wallet RPC (if needed)
- Save and reboot router if required
sudo firewall-cmd --permanent --add-port=17080/tcp  # P2P
sudo firewall-cmd --permanent --add-port=17081/tcp  # RPC
sudo firewall-cmd --permanent --add-port=17083/tcp  # Wallet RPC
sudo firewall-cmd --reload
```

### 3. Router Port Forwarding
If behind a router:
- Log into router admin panel
- Forward external port `17081` → internal IP port `17081`
- Use your server's **local IP** as destination

---

## Testing Your Setup

### Test from Same Machine
```bash
curl http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json'
```

### Test from Another Machine (No Auth)
```bash
curl http://YOUR_PUBLIC_IP:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json'
```

### Test with Authentication
```bash
curl -u admin:password http://YOUR_PUBLIC_IP:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json'
```

---

## Wallet RPC Connection to Public Daemon

### Connecting Wallet RPC to Remote Daemon

Once your daemon is running on a public IP, connect your wallet RPC from **any machine**:

**From the same server (localhost):**
```bash
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 127.0.0.1:17081 --daemon-login admin:password --rpc-bind-port 17083 --disable-rpc-login
```

**From a different server (remote connection):**
```bash
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address YOUR_DAEMON_PUBLIC_IP:17081 --daemon-login admin:password --rpc-bind-port 17083 --disable-rpc-login
```

**Example:**
```bash
# Daemon running on 203.0.113.45
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 203.0.113.45:17081 --daemon-login admin:password --rpc-bind-port 17083 --disable-rpc-login
```

---

### Exposing Wallet RPC Publicly

If you need external access to wallet RPC (for pool software, API, etc.):

**Wallet RPC on public IP (with authentication):**
```bash
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 127.0.0.1:17081 --daemon-login admin:daemonpass --rpc-bind-ip 0.0.0.0 --rpc-bind-port 17083 --rpc-login walletuser:walletpass --confirm-external-bind
```

**What this does:**
- Connects to local daemon on port 17081
- Exposes wallet RPC on all interfaces (0.0.0.0) port 17083
- Requires authentication: `walletuser:walletpass`
- Pool software can connect to `YOUR_IP:17083` with these credentials

**Firewall configuration for wallet RPC:**
```powershell
# Windows
New-NetFirewallRule -DisplayName "Oxyra Wallet RPC" -Direction Inbound -LocalPort 17083 -Protocol TCP -Action Allow

# Linux (UFW)
sudo ufw allow 17083/tcp
```

---

### Complete Pool Setup (Daemon + Wallet RPC)

**On daemon server:**
```bash
# Start daemon with public RPC
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:SecurePass123! --p2p-bind-port=17080
```

**Option A: Wallet RPC on same server**
```bash
# Wallet RPC connects locally, exposes publicly
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 127.0.0.1:17081 --daemon-login admin:SecurePass123! --rpc-bind-ip 0.0.0.0 --rpc-bind-port 17083 --rpc-login poolrpc:WalletPass456! --confirm-external-bind
```

**Option B: Wallet RPC on different server**
```bash
# On wallet server, connect to remote daemon
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address DAEMON_PUBLIC_IP:17081 --daemon-login admin:SecurePass123! --rpc-bind-ip 0.0.0.0 --rpc-bind-port 17083 --rpc-login poolrpc:WalletPass456! --confirm-external-bind
```

**Testing wallet RPC connection:**
```bash
# Get wallet balance (with authentication)
curl -u walletuser:walletpass http://YOUR_WALLET_IP:17083/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0}}' -H 'Content-Type: application/json'
```

---

## Common Scenarios

### Scenario 1: Pool Server (All-in-One)
Daemon and wallet on same server:
```bash
# Terminal 1: Start daemon
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login pooladmin:SecurePass123! --p2p-bind-port=17080

# Terminal 2: Start wallet RPC
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 127.0.0.1:17081 --daemon-login pooladmin:SecurePass123! --rpc-bind-ip 0.0.0.0 --rpc-bind-port 17083 --rpc-login poolrpc:WalletPass456! --confirm-external-bind
```

**Pool software config:**
- Daemon: `127.0.0.1:17081` (username: `pooladmin`, password: `SecurePass123!`)
- Wallet: `127.0.0.1:17083` (username: `poolrpc`, password: `WalletPass456!`)

### Scenario 2: Separate Daemon & Wallet Servers
Daemon on one server, wallet on another:

**Server 1 (Daemon - IP: 203.0.113.45):**
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login daemonuser:DaemonPass123! --p2p-bind-port=17080
```

**Server 2 (Wallet RPC - IP: 203.0.113.50):**
```bash
./monero-wallet-rpc --wallet-file pool_wallet --password walletpass --daemon-address 203.0.113.45:17081 --daemon-login daemonuser:DaemonPass123! --rpc-bind-ip 0.0.0.0 --rpc-bind-port 17083 --rpc-login walletuser:WalletPass456! --confirm-external-bind
```

**Pool software config:**
- Daemon: `203.0.113.45:17081`
- Wallet: `203.0.113.50:17083`

### Scenario 3: Public Node (Read-Only)
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --restricted-rpc --p2p-bind-port=17080
```

### Scenario 4: Development/Testing
```bash
# Testnet daemon
./monerod --testnet --rpc-bind-ip=0.0.0.0 --rpc-bind-port=27081 --confirm-external-bind --offline --disable-dns-checkpoints

# Testnet wallet (different terminal)
./monero-wallet-rpc --testnet --wallet-file test_wallet --password testpass --daemon-address 127.0.0.1:27081 --rpc-bind-port 27083 --disable-rpc-login
```

---

## Security Best Practices

### ✅ DO:
- Always use `--rpc-login` for internet-exposed nodes
- Use `--restricted-rpc` for public nodes
- Use strong passwords (16+ characters)
- Enable firewall rules
- Monitor access logs
- Use HTTPS/SSL for production

### ❌ DON'T:
- Expose unrestricted RPC to the internet without authentication
- Use default or weak passwords
- Skip firewall configuration
- Expose wallet RPC publicly without protection

---

## Troubleshooting

### "Cannot bind to address"
- Port already in use → Check with `netstat -an | findstr 17081`
- Permission denied → Run as administrator (Windows) or sudo (Linux)
- IP not available → Verify IP with `ipconfig` (Windows) or `ip addr` (Linux)

### "Connection refused" from remote

### Nodes not connecting to each other
- Check P2P port (17080) is open in firewall
- Verify `--p2p-bind-ip=0.0.0.0` on seed node
- Test P2P connectivity: `telnet SEED_IP 17080`
- Check peer list: `curl http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_connections"}'`
- Ensure nodes are not in `--offline` mode
- Check logs for connection errors
- Firewall blocking → Check Windows Firewall or iptables
- Router not forwarding → Verify port forwarding configuration
- Wrong IP → Confirm with `ipconfig` or public IP checker

### "Authentication failed"
- Check username/password in `--rpc-login`
- Ensure wallet uses `--daemon-login` with correct credentials
- Verify no extra spaces in credentials

### "Failed to connect to daemon"
- Verify daemon is running: `curl http://DAEMON_IP:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}'`
- Check daemon IP and port in `--daemon-address`
- Ensure firewall allows connections
- Verify daemon authentication with `--daemon-login`

### Wallet RPC not accessible remotely
- Check wallet is bound to `0.0.0.0` not `127.0.0.1`
- Verify `--confirm-external-bind` flag is present
- Check firewall rules for port 17083
- Test locally first: `curl http://127.0.0.1:17083/json_rpc`

---

## Quick Reference

### Daemon Configurations

**Local development:**
```bash
./monerod --rpc-bind-ip=127.0.0.1 --rpc-bind-port=17081
```

**Pool/production:**
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --rpc-login admin:strongpass
```

**Public node:**
```bash
./monerod --rpc-bind-ip=0.0.0.0 --rpc-bind-port=17081 --confirm-external-bind --restricted-rpc
```

### Wallet RPC Configurations

**Local wallet (private):**
```bash
./monero-wallet-rpc --wallet-file wallet --password pass --daemon-address 127.0.0.1:17081 --rpc-bind-port 17083 --disable-rpc-login
```

**Public wallet RPC (for pools):**
```bash
./monero-wallet-rpc --wallet-file wallet --password pass --daemon-address 127.0.0.1:17081 --daemon-login admin:daemonpass --rpc-bind-ip 0.0.0.0 --rpc-bind-port 17083 --rpc-login walletuser:walletpass --confirm-external-bind
``` - mainnet
- **17081**: Daemon RPC (mainnet)
- **17083**: Wallet RPC (mainnet)
- **27080**: P2P network (testnet)
- **27081**: Daemon RPC (testnet)
- **27083**: Wallet RPC (testnet)

### Complete Network Setup Command

**Full-featured seed node (mainnet):**
```bash
./monerod \
  --p2p-bind-ip=0.0.0.0 \
  --p2p-bind-port=17080 \
  --rpc-bind-ip=0.0.0.0 \
  --rpc-bind-port=17081 \
  --confirm-external-bind \
  --rpc-login admin:SecurePassword123! \
  --log-level=0 \
  --max-concurrency=4 \
  --detach
```

**Node connecting to seed network:**
```bash
./monerod \
  --add-peer SEED1_IP:17080 \
  --add-peer SEED2_IP:17080 \
  --p2p-bind-port=17080 \
  --rpc-bind-port=17081 \
  --log-level=0 \
  --detach
``` wallet --password pass --daemon-address REMOTE_IP:17081 --daemon-login admin:daemonpass --rpc-bind-port 17083 --disable-rpc-login
```

### Port Summary
- **17080**: P2P network (node-to-node communication)
- **17081**: Daemon RPC (mainnet)
- **17083**: Wallet RPC (mainnet)
- **27081**: Daemon RPC (testnet)
- **27083**: Wallet RPC (testnet)
