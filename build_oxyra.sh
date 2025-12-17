#!/bin/bash
# Oxyra Build Script for Linux

set -e

echo "========================================"
echo "   Oxyra Blockchain Build Script"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${GREEN}Detected: Linux${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}Detected: macOS${NC}"
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

# Step 0: Update git submodules
echo ""
echo -e "${GREEN}Step 0: Updating git submodules...${NC}"
echo -e "${YELLOW}This is required for the build...${NC}"
git submodule update --init --recursive --force

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}ERROR: Failed to update submodules!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Submodules updated${NC}"

# Step 1: Check dependencies
echo ""
echo -e "${GREEN}Step 1: Checking dependencies...${NC}"
echo "Required: cmake, boost, openssl, zeromq, libsodium, unbound"
echo ""

# Check for cmake
if ! command -v cmake &> /dev/null; then
    echo -e "${RED}ERROR: cmake not found!${NC}"
    echo -e "${YELLOW}Install with: sudo apt install cmake (Ubuntu/Debian)${NC}"
    exit 1
fi

# Check for make
if ! command -v make &> /dev/null; then
    echo -e "${RED}ERROR: make not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ cmake found: $(cmake --version | head -n1)${NC}"
echo -e "${GREEN}✓ make found${NC}"

# Step 2: Clean old build
echo ""
echo -e "${GREEN}Step 2: Cleaning old build...${NC}"
if [ -d "build" ]; then
    read -p "Remove existing build directory? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf build
        echo -e "${YELLOW}Build directory cleaned.${NC}"
    fi
fi

# Step 3: Create build directory
echo ""
echo -e "${GREEN}Step 3: Creating build directory...${NC}"
mkdir -p build/release
cd build/release

# Step 4: CMake configuration
echo ""
echo -e "${GREEN}Step 4: Running CMake configuration...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

cmake -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_TESTS=OFF \
    -D ARCH="x86-64" \
    ../..

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}ERROR: CMake configuration failed!${NC}"
    cd ../..
    exit 1
fi

# Step 5: Build
echo ""
echo -e "${GREEN}Step 5: Building Oxyra...${NC}"
echo -e "${YELLOW}This will take 30-60 minutes depending on your system.${NC}"
echo -e "${CYAN}Go grab a coffee! ☕${NC}"
echo ""

# Detect number of cores
CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)

# Ask user about parallel build
echo -e "${YELLOW}Your system has $CORES CPU cores.${NC}"
read -p "Use all cores for faster build (may use more RAM)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BUILD_CORES=$CORES
    echo -e "${CYAN}Building with $BUILD_CORES cores (faster, uses more RAM)...${NC}"
else
    BUILD_CORES=$(($CORES / 2))
    if [ $BUILD_CORES -lt 1 ]; then
        BUILD_CORES=1
    fi
    echo -e "${CYAN}Building with $BUILD_CORES cores (slower, uses less RAM)...${NC}"
fi

make -j$BUILD_CORES

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}ERROR: Build failed!${NC}"
    cd ../..
    exit 1
fi

cd ../..

# Success message
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   BUILD SUCCESSFUL!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}Executables are in: build/release/bin/${NC}"
echo ""
echo -e "${YELLOW}Available binaries:${NC}"
ls -1 build/release/bin/ | grep -E '^(monerod|monero-wallet-cli|monero-wallet-rpc)' | while read binary; do
    echo -e "  ${NC}- $binary"
done

echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo -e "${CYAN}===========${NC}"
echo ""
echo -e "${YELLOW}1. Generate premine wallet:${NC}"
echo "   ./build/release/bin/monero-wallet-cli --generate-new-wallet premine_wallet"
echo ""
echo -e "${YELLOW}2. Generate genesis transaction (see OXYRA_SETUP_GUIDE.md)${NC}"
echo ""
echo -e "${YELLOW}3. Test the node:${NC}"
echo "   ./build/release/bin/monerod --testnet --data-dir ./oxyra-testnet"
echo ""
echo -e "${YELLOW}4. Read the full setup guide:${NC}"
echo "   cat OXYRA_SETUP_GUIDE.md"
echo ""
echo -e "${GREEN}========================================${NC}"

# Create quickstart script
cat > quickstart.sh << 'EOF'
#!/bin/bash
# Oxyra Quick Start Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Oxyra Quick Start Menu${NC}"
echo -e "${CYAN}======================${NC}"
echo ""
echo "1. Start Mainnet Node"
echo "2. Start Testnet Node"
echo "3. Create New Wallet"
echo "4. Start Mining (Solo)"
echo "5. Check Node Status"
echo "6. View Logs"
echo "7. Exit"
echo ""

read -p "Enter your choice (1-7): " choice

case $choice in
    1)
        echo -e "${GREEN}Starting Oxyra Mainnet Node...${NC}"
        ./build/release/bin/monerod --data-dir ./oxyra-blockchain --log-file ./oxyra.log
        ;;
    2)
        echo -e "${GREEN}Starting Oxyra Testnet Node...${NC}"
        ./build/release/bin/monerod --testnet --data-dir ./oxyra-testnet --log-file ./oxyra-testnet.log
        ;;
    3)
        echo -e "${GREEN}Creating new wallet...${NC}"
        ./build/release/bin/monero-wallet-cli --generate-new-wallet my_wallet
        ;;
    4)
        read -p "Enter your wallet address: " address
        read -p "Enter number of mining threads (default: 2): " threads
        threads=${threads:-2}
        echo -e "${GREEN}Starting solo mining...${NC}"
        ./build/release/bin/monerod --start-mining $address --mining-threads $threads
        ;;
    5)
        echo -e "${GREEN}Checking node status...${NC}"
        ./build/release/bin/monerod status
        ;;
    6)
        echo -e "${GREEN}Viewing logs...${NC}"
        if [ -f "oxyra.log" ]; then
            tail -f oxyra.log
        else
            echo -e "${YELLOW}No log file found. Run node first.${NC}"
        fi
        ;;
    7)
        echo -e "${CYAN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        ;;
esac
EOF

chmod +x quickstart.sh
echo -e "${GREEN}Created quickstart.sh for easy access to common commands${NC}"
echo -e "${YELLOW}Run it with: ./quickstart.sh${NC}"
