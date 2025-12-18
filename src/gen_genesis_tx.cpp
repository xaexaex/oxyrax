// Copyright (c) 2024, Oxyra Project
// 
// Oxyra Genesis Transaction Generator
// This utility creates the genesis transaction with 3 billion OXRX premine

#include <iostream>
#include <cstdint>
#include "cryptonote_basic/cryptonote_format_utils.h"
#include "cryptonote_basic/cryptonote_basic.h"
#include "cryptonote_basic/account.h"
#include "serialization/binary_utils.h"
#include "string_tools.h"
#include "crypto/crypto.h"
#include "device/device_default.hpp"

using namespace cryptonote;

// Generate a simple genesis transaction with premine
// Note: This creates a miner transaction (coinbase) with the premine amount
bool generate_oxyra_genesis_tx(std::string& tx_hex, const std::string& premine_address_str) {
    try {
        // Parse the premine address  
        cryptonote::address_parse_info info;
        if (!cryptonote::get_account_address_from_str(info, cryptonote::MAINNET, premine_address_str)) {
            std::cerr << "Failed to parse address: " << premine_address_str << std::endl;
            return false;
        }
        
        // Create genesis miner transaction using the proper construct_miner_tx function
        transaction tx;
        const uint64_t premine_amount = PREMINE_AMOUNT; // 90 million OXRX (3% premine)
        
        // For genesis block (height 0), we create a simple miner transaction
        // Genesis blocks typically have version 1
        tx.version = 1;
        tx.unlock_time = CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW; // 60 blocks
        
        // Create the miner input (coinbase)
        txin_gen in;
        in.height = 0; // Genesis block
        tx.vin.push_back(in);
        
        // Generate transaction keypair
        keypair txkey = keypair::generate(hw::get_device("default"));
        add_tx_pub_key_to_extra(tx, txkey.pub);
        
        // Create output with proper key derivation
        crypto::key_derivation derivation = AUTO_VAL_INIT(derivation);
        crypto::public_key out_eph_public_key = AUTO_VAL_INIT(out_eph_public_key);
        
        bool r = crypto::generate_key_derivation(info.address.m_view_public_key, txkey.sec, derivation);
        if (!r) {
            std::cerr << "Failed to generate key derivation" << std::endl;
            return false;
        }
        
        r = crypto::derive_public_key(derivation, 0, info.address.m_spend_public_key, out_eph_public_key);
        if (!r) {
            std::cerr << "Failed to derive public key" << std::endl;
            return false;
        }
        
        tx_out out;
        out.amount = premine_amount;
        
        txout_to_key tk;
        tk.key = out_eph_public_key;
        out.target = tk;
        
        tx.vout.push_back(out);
        
        // Serialize to hex
        std::string tx_blob = t_serializable_object_to_blob(tx);
        tx_hex = epee::string_tools::buff_to_hex_nodelimer(tx_blob);
        
        std::cout << "Genesis Transaction Generated!" << std::endl;
        std::cout << "Premine Amount: " << premine_amount << " atomic units" << std::endl;
        std::cout << "               = " << (premine_amount / COIN) << " OXRX" << std::endl;
        std::cout << "Destination: " << premine_address_str << std::endl;
        std::cout << "\nTransaction Hex:" << std::endl;
        std::cout << tx_hex << std::endl;
        
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return false;
    }
}

int main(int argc, char* argv[]) {
    std::cout << "========================================" << std::endl;
    std::cout << "  Oxyra Genesis Transaction Generator  " << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << std::endl;
    
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <premine_wallet_address>" << std::endl;
        std::cout << std::endl;
        std::cout << "Example:" << std::endl;
        std::cout << "  " << argv[0] << " ox1234567890abcdef..." << std::endl;
        std::cout << std::endl;
        std::cout << "Instructions:" << std::endl;
        std::cout << "1. First generate a wallet to receive the premine:" << std::endl;
        std::cout << "   ./monero-wallet-cli --generate-new-wallet premine_wallet" << std::endl;
        std::cout << std::endl;
        std::cout << "2. Get the wallet address (use 'address' command)" << std::endl;
        std::cout << std::endl;
        std::cout << "3. Run this tool with that address" << std::endl;
        std::cout << std::endl;
        std::cout << "4. Copy the output hex to src/cryptonote_config.h" << std::endl;
        std::cout << "   Update: std::string const GENESIS_TX = \"<hex_output>\";" << std::endl;
        std::cout << std::endl;
        std::cout << "5. Rebuild: make clean && make release" << std::endl;
        std::cout << std::endl;
        return 1;
    }
    
    std::string premine_address = argv[1];
    std::string genesis_tx_hex;
    
    std::cout << "Generating genesis transaction..." << std::endl;
    std::cout << "Premine: 3,000,000,000 OXRX" << std::endl;
    std::cout << "Address: " << premine_address << std::endl;
    std::cout << std::endl;
    
    if (!generate_oxyra_genesis_tx(genesis_tx_hex, premine_address)) {
        std::cerr << "\nFailed to generate genesis transaction!" << std::endl;
        return 1;
    }
    
    std::cout << "\n========================================" << std::endl;
    std::cout << "SUCCESS!" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "\nNext steps:" << std::endl;
    std::cout << "1. Copy the transaction hex above" << std::endl;
    std::cout << "2. Edit src/cryptonote_config.h" << std::endl;
    std::cout << "3. Find: std::string const GENESIS_TX = ..." << std::endl;
    std::cout << "4. Replace with the hex output above" << std::endl;
    std::cout << "5. Rebuild: make clean && make release" << std::endl;
    std::cout << "6. Test: ./build/release/bin/monerod --testnet" << std::endl;
    std::cout << "\nIMPORTANT: Keep your premine wallet seed phrase safe!" << std::endl;
    std::cout << "========================================" << std::endl;
    
    return 0;
}

/* 
 * Compilation instructions:
 * 
 * Add this to src/CMakeLists.txt:
 * 
 * add_executable(gen_genesis_tx
 *     gen_genesis_tx.cpp
 * )
 * 
 * target_link_libraries(gen_genesis_tx
 *     PRIVATE
 *         cryptonote_basic
 *         cryptonote_core
 *         common
 *         epee
 *         ${Boost_LIBRARIES}
 * )
 * 
 * Then build:
 * make gen_genesis_tx
 * 
 * Run:
 * ./build/release/bin/gen_genesis_tx YOUR_WALLET_ADDRESS
 */
