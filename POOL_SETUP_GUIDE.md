# Oxyra Mining Pool Setup Guide

## Overview

This guide will help you set up a mining pool for Oxyra (OXRX) blockchain. Since Oxyra has **zero block rewards**, miners only earn transaction fees, making pool economics different from traditional cryptocurrencies.

## Important Considerations

⚠️ **Zero Block Rewards**: Oxyra miners receive ONLY transaction fees, no block subsidy
⚠️ **Pool Viability**: Pool operation requires significant transaction volume for profitability
⚠️ **Alternative**: Solo mining may be more suitable for low-transaction-volume periods

## Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04/22.04 LTS (recommended) or CentOS/RHEL 8+
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 50GB+ SSD
- **Network**: Static IP with open ports (3333, 5555, 7777, 8117, 17080, 17081)
- **CPU**: 4+ cores recommended

### Software Requirements
- Node.js 14+ (LTS recommended)
- Redis 6+
- Oxyra daemon (`monerod`)
- Oxyra wallet RPC (`monero-wallet-rpc`)
- Nginx (for frontend, optional)
- SSL Certificate (Let's Encrypt recommended)

## Step 1: Install Dependencies

### Ubuntu/Debian
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 16 LTS
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Install Redis
sudo apt install -y redis-server

# Install other dependencies
sudo apt install -y build-essential libssl-dev libboost-all-dev git
```

### CentOS/RHEL
```bash
# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# Install Redis
sudo yum install -y redis

# Enable and start Redis
sudo systemctl enable redis
sudo systemctl start redis
```

## Step 2: Setup Oxyra Daemon

### Install Oxyra Node

1. **Build Oxyra** (if not already done):
```bash
cd /opt
git clone https://github.com/xaexaex/oxyrax.git oxyra
cd oxyra
make release
```

2. **Create daemon service**:
```bash
sudo nano /etc/systemd/system/oxyrad.service
```

Add:
```ini
[Unit]
Description=Oxyra Daemon
After=network.target

[Service]
Type=forking
User=oxyra
Group=oxyra
WorkingDirectory=/opt/oxyra
ExecStart=/opt/oxyra/build/release/bin/monerod \
    --data-dir=/var/lib/oxyra \
    --log-file=/var/log/oxyra/daemon.log \
    --log-level=0 \
    --detach \
    --p2p-bind-ip=0.0.0.0 \
    --p2p-bind-port=17080 \
    --rpc-bind-ip=127.0.0.1 \
    --rpc-bind-port=17081 \
    --confirm-external-bind \
    --max-concurrency=4

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

3. **Create user and directories**:
```bash
sudo useradd -r -s /bin/false oxyra
sudo mkdir -p /var/lib/oxyra /var/log/oxyra
sudo chown -R oxyra:oxyra /var/lib/oxyra /var/log/oxyra
```

4. **Start daemon**:
```bash
sudo systemctl daemon-reload
sudo systemctl enable oxyrad
sudo systemctl start oxyrad
sudo systemctl status oxyrad
```

5. **Verify daemon is running**:
```bash
curl http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json'
```

## Step 3: Setup Wallet RPC

### Create Pool Wallet

1. **Generate pool wallet**:
```bash
cd /opt/oxyra
./build/release/bin/monero-wallet-cli --generate-new-wallet /var/lib/oxyra/pool_wallet
```

Save the **seed phrase** securely!

2. **Create wallet RPC service**:
```bash
sudo nano /etc/systemd/system/oxyra-wallet-rpc.service
```

Add:
```ini
[Unit]
Description=Oxyra Wallet RPC
After=oxyrad.service
Requires=oxyrad.service

[Service]
Type=simple
User=oxyra
Group=oxyra
WorkingDirectory=/opt/oxyra
ExecStart=/opt/oxyra/build/release/bin/monero-wallet-rpc \
    --wallet-file=/var/lib/oxyra/pool_wallet \
    --password=YOUR_WALLET_PASSWORD \
    --rpc-bind-port=17082 \
    --rpc-bind-ip=127.0.0.1 \
    --daemon-address=127.0.0.1:17081 \
    --trusted-daemon \
    --disable-rpc-login \
    --log-file=/var/log/oxyra/wallet-rpc.log

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

3. **Set permissions and start**:
```bash
sudo chown oxyra:oxyra /var/lib/oxyra/pool_wallet*
sudo systemctl daemon-reload
sudo systemctl enable oxyra-wallet-rpc
sudo systemctl start oxyra-wallet-rpc
sudo systemctl status oxyra-wallet-rpc
```

4. **Test wallet RPC**:
```bash
curl http://127.0.0.1:17082/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance"}' -H 'Content-Type: application/json'
```

## Step 4: Install Pool Software

### Option A: cryptonote-nodejs-pool (Recommended)

1. **Clone the pool software**:
```bash
cd /opt
git clone https://github.com/dvandal/cryptonote-nodejs-pool.git oxyra-pool
cd oxyra-pool
```

2. **Install dependencies**:
```bash
npm update
npm install
```

### Option B: nodejs-pool (Enterprise-grade)

```bash
cd /opt
git clone https://github.com/Snipa22/nodejs-pool.git oxyra-pool
cd oxyra-pool
npm install
```

## Step 5: Configure Pool

### Create Oxyra Configuration

1. **Copy template configuration**:
```bash
cd /opt/oxyra-pool
cp config_examples/config.json config.json
```

2. **Edit configuration**:
```bash
nano config.json
```

Use the template from `pool_config_template.json` and update:

**Critical settings to change**:
```json
{
    "coin": "oxyra",
    "symbol": "OXRX",
    "poolAddress": "YOUR_POOL_WALLET_ADDRESS_HERE",
    
    "daemon": {
        "host": "127.0.0.1",
        "port": 17081
    },
    
    "wallet": {
        "host": "127.0.0.1",
        "port": 17082
    }
}
```

### Update Pool Modules for Oxyra

1. **Edit coin configuration** (`lib/coins/oxyra.json`):
```bash
mkdir -p lib/coins
nano lib/coins/oxyra.json
```

Add:
```json
{
    "name": "oxyra",
    "symbol": "OXRX",
    "algorithm": "randomx",
    "coinUnits": 1000000000000,
    "coinDecimalPlaces": 12,
    "coinDifficultyTarget": 120,
    "blockTime": 120,
    "hashrateUnits": "H/s"
}
```

2. **Update payment module** to handle zero block rewards:

Edit `lib/paymentProcessor.js` to ensure it:
- Calculates rewards from transaction fees only
- Handles blocks with zero subsidy
- Properly attributes fee-only rewards

## Step 6: Start Pool

### Run Pool Services

1. **Test pool in foreground**:
```bash
cd /opt/oxyra-pool
node init.js
```

Check for errors. Common issues:
- Daemon not responding → Check `oxyrad` service
- Wallet not responding → Check `oxyra-wallet-rpc` service
- Redis connection failed → Check `redis` service

2. **Create pool service**:
```bash
sudo nano /etc/systemd/system/oxyra-pool.service
```

Add:
```ini
[Unit]
Description=Oxyra Mining Pool
After=redis.service oxyrad.service oxyra-wallet-rpc.service
Requires=redis.service oxyrad.service oxyra-wallet-rpc.service

[Service]
Type=simple
User=oxyra
Group=oxyra
WorkingDirectory=/opt/oxyra-pool
ExecStart=/usr/bin/node init.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

3. **Start pool**:
```bash
sudo chown -R oxyra:oxyra /opt/oxyra-pool
sudo systemctl daemon-reload
sudo systemctl enable oxyra-pool
sudo systemctl start oxyra-pool
sudo systemctl status oxyra-pool
```

## Step 7: Setup Pool Frontend

### Install and Configure Frontend

1. **Clone frontend**:
```bash
cd /opt
git clone https://github.com/dvandal/cryptonote-nodejs-pool-ui.git oxyra-pool-ui
cd oxyra-pool-ui
```

2. **Configure**:
```bash
cp config_example.json config.json
nano config.json
```

Update:
```json
{
    "api": "http://localhost:8117",
    "poolHost": "pool.oxyra.network",
    "coin": "oxyra",
    "symbol": "OXRX",
    "coinUnits": 1000000000000,
    "coinDecimalPlaces": 12
}
```

3. **Build frontend**:
```bash
npm install
npm run build
```

### Configure Nginx

1. **Install Nginx**:
```bash
sudo apt install -y nginx
```

2. **Create Nginx configuration**:
```bash
sudo nano /etc/nginx/sites-available/oxyra-pool
```

Add:
```nginx
server {
    listen 80;
    server_name pool.oxyra.network;
    
    root /opt/oxyra-pool-ui/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://127.0.0.1:8117;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

3. **Enable and restart**:
```bash
sudo ln -s /etc/nginx/sites-available/oxyra-pool /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Setup SSL (Recommended)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d pool.oxyra.network
```

## Step 8: Test Mining Connection

### Test with XMRig

1. **Download XMRig**:
```bash
wget https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-x64.tar.gz
tar xf xmrig-6.21.0-linux-x64.tar.gz
cd xmrig-6.21.0
```

2. **Create config**:
```bash
nano config.json
```

Add:
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
            "url": "pool.oxyra.network:3333",
            "user": "YOUR_OXYRA_WALLET_ADDRESS",
            "pass": "x",
            "keepalive": true,
            "tls": false
        }
    ]
}
```

3. **Start mining**:
```bash
./xmrig
```

Expected output:
```
[2024-01-01 12:00:00.000]  net      new job from pool.oxyra.network:3333
[2024-01-01 12:00:05.123]  cpu      accepted (1/0) diff 1000
```

## Troubleshooting

### Problem: Pool can't connect to daemon
**Solution**:
```bash
# Check daemon status
sudo systemctl status oxyrad
sudo journalctl -u oxyrad -n 50

# Test RPC
curl http://127.0.0.1:17081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json'
```

### Problem: Wallet RPC not responding
**Solution**:
```bash
# Check wallet service
sudo systemctl status oxyra-wallet-rpc
sudo journalctl -u oxyra-wallet-rpc -n 50

# Restart wallet
sudo systemctl restart oxyra-wallet-rpc
```

### Problem: Redis connection failed
**Solution**:
```bash
# Check Redis
sudo systemctl status redis
redis-cli ping  # Should return PONG

# Restart Redis
sudo systemctl restart redis
```

### Problem: No shares being submitted
**Solution**:
- Check miner configuration
- Verify wallet address is valid
- Check firewall: `sudo ufw allow 3333,5555,7777/tcp`
- View pool logs: `sudo journalctl -u oxyra-pool -f`

### Problem: Payments not processing
**Solution**:
- Check wallet balance: Wallet needs OXRX for transaction fees
- Verify `minPayment` in config.json
- Check payment processor logs in pool
- Remember: Oxyra has ZERO block rewards, only transaction fees!

## Monitoring

### View Logs

```bash
# Pool logs
sudo journalctl -u oxyra-pool -f

# Daemon logs
tail -f /var/log/oxyra/daemon.log

# Wallet RPC logs
tail -f /var/log/oxyra/wallet-rpc.log
```

### Check Pool Stats

```bash
# API endpoint
curl http://localhost:8117/stats

# Pool stats
curl http://localhost:8117/pool/stats

# Live stats
curl http://localhost:8117/live_stats
```

## Security Best Practices

1. **Firewall Configuration**:
```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 17080/tcp # Oxyra P2P
sudo ufw allow 3333,5555,7777/tcp # Mining ports
sudo ufw enable
```

2. **Secure Redis**:
```bash
sudo nano /etc/redis/redis.conf
# Set: bind 127.0.0.1
# Set: requirepass YOUR_STRONG_PASSWORD
sudo systemctl restart redis
```

3. **Regular Backups**:
```bash
# Backup pool wallet
sudo cp /var/lib/oxyra/pool_wallet* /backup/

# Backup Redis data
redis-cli BGSAVE
sudo cp /var/lib/redis/dump.rdb /backup/
```

4. **Update Regularly**:
```bash
# Update system
sudo apt update && sudo apt upgrade

# Update pool software
cd /opt/oxyra-pool
git pull
npm update
sudo systemctl restart oxyra-pool
```

## Pool Economics with Zero Block Rewards

### Understanding Fee-Only Mining

Since Oxyra has zero block rewards:
- Miners earn **only** from transaction fees
- Pool must have active transaction volume
- During low-activity periods, blocks may have zero value
- Solo mining may be more economical for miners

### Pool Fee Structure

Recommended fee structure for zero-reward chains:
- **Pool Fee**: 1-3% (lower than typical to incentivize miners)
- **Minimum Payout**: Set higher to reduce transaction costs
- **Payment Frequency**: Less frequent to batch transactions

### Sustainable Pool Operation

To maintain a viable pool:
1. **Promote Network Usage**: More transactions = more fees
2. **Efficient Payouts**: Batch payments to minimize costs
3. **Transparent Stats**: Show fee earnings clearly to miners
4. **Community Building**: Educate users about fee-based model

## Next Steps

1. ✅ Pool is running and accepting connections
2. ⏭️ Configure monitoring and alerting
3. ⏭️ Set up block explorer integration
4. ⏭️ Create pool statistics dashboard
5. ⏭️ Implement miner notifications
6. ⏭️ Add DDoS protection (Cloudflare, fail2ban)
7. ⏭️ Create pool documentation for miners

## Resources

- Oxyra GitHub: https://github.com/xaexaex/oxyrax
- Pool Software: https://github.com/dvandal/cryptonote-nodejs-pool
- XMRig: https://github.com/xmrig/xmrig
- Monero Pool Docs: https://github.com/monero-project/monero

## Support

For pool-related issues:
1. Check pool logs
2. Verify daemon and wallet RPC connectivity
3. Test with solo mining first
4. Review configuration against template

Remember: **Zero block rewards** means pool viability depends entirely on transaction volume!
