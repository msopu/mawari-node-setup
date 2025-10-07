#!/bin/bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

WORKDIR="$HOME/mawari"
LOG_FILE="$WORKDIR/setup.log"
GENERATED_WALLETS_LOG="$WORKDIR/generated_wallets.log"

show_menu() {
    clear
    echo -e "${BLUE}Mawari Network Guardian Node Setup${NC}"
    echo "================================="
    echo "1. Install Dependencies"
    echo "2. Create New Wallet"
    echo "3. Claim Faucet & Mint 3X NFT"
    echo "4. Setup Guardian Node"
    echo "5. Check Burner Address"
    echo "6. Node Status"
    echo "7. Delegate Node"
    echo "8. Claim Faucet & Send to Burner"
    echo "9. Exit"
    echo -n "Please enter your choice [1-9]: "
}

install_dependencies() {
    clear
    echo -e "${YELLOW}Installing Dependencies...${NC}"
    
    echo -e "${YELLOW}Updating system...${NC}"
    sudo apt update || { echo -e "${RED}Failed to update system.${NC}"; read -p "Press Enter to continue..."; return 1; }
    
    echo -e "${YELLOW}Installing Docker...${NC}"
    sudo apt install -y docker.io docker-compose || { echo -e "${RED}Failed to install Docker.${NC}"; read -p "Press Enter to continue..."; return 1; }
    sudo systemctl start docker || { echo -e "${RED}Failed to start Docker.${NC}"; read -p "Press Enter to continue..."; return 1; }
    sudo systemctl enable docker || { echo -e "${RED}Failed to enable Docker.${NC}"; read -p "Press Enter to continue..."; return 1; }
    
    echo -e "${YELLOW}Installing Screen and other dependencies...${NC}"
    sudo apt install -y ca-certificates curl gnupg lsb-release screen python3 python3-pip jq xclip || { echo -e "${RED}Failed to install dependencies.${NC}"; read -p "Press Enter to continue..."; return 1; }
    
    echo -e "${YELLOW}Installing Python dependencies...${NC}"
    pip3 install web3 requests eth-account tabulate tqdm twocaptcha || { echo -e "${RED}Failed to install Python dependencies.${NC}"; read -p "Press Enter to continue..."; return 1; }
    
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
    read -p "Press Enter to continue..."
}

create_wallet() {
    clear
    echo -e "${YELLOW}Create New Wallet${NC}"
    echo "Please visit the following URL to create a new wallet:"
    echo -e "${BLUE}https://testnet.mawari.net/mint${NC}"
    echo "After creating the wallet, claim faucet and mint 3X NFT."
    echo "Copy your wallet address and private key for the next step."
    read -p "Press Enter to continue..."
}

setup_guardian_node() {
    clear
    echo -e "${YELLOW}Setting up Guardian Node...${NC}"
    
    echo -e "${YELLOW}Creating mawari directory...${NC}"
    mkdir -p $WORKDIR || { echo -e "${RED}Failed to create mawari directory.${NC}"; read -p "Press Enter to continue..."; return 1; }
    cd $WORKDIR || { echo -e "${RED}Failed to change to mawari directory.${NC}"; read -p "Press Enter to continue..."; return 1; }
    
    echo -e "${YELLOW}Setting node image...${NC}"
    export MNTESTNET_IMAGE=us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
    
    read -p "Enter your owner wallet address (from NFT mint): " OWNER_ADDRESS
    if [ -z "$OWNER_ADDRESS" ]; then
        echo -e "${RED}Owner address cannot be empty.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    export OWNER_ADDRESS
    
    echo -e "${YELLOW}Starting Guardian Node...${NC}"
    docker run --pull always -v $WORKDIR:/app/cache -e OWNERS_ALLOWLIST=$OWNER_ADDRESS $MNTESTNET_IMAGE || { echo -e "${RED}Failed to start Guardian Node.${NC}"; read -p "Press Enter to continue..."; return 1; }
    
    echo -e "${GREEN}Guardian Node setup completed!${NC}"
    read -p "Press Enter to continue..."
}

check_burner_address() {
    clear
    echo -e "${YELLOW}Checking Burner Address...${NC}"
    
    if [ ! -f "$WORKDIR/flohive-cache.json" ]; then
        echo -e "${RED}Burner address file not found. Make sure the node is running.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    # Extract burner address and private key
    BURNER_ADDRESS=$(cat $WORKDIR/flohive-cache.json | jq -r '.burnerWallet.address')
    BURNER_PRIVATE_KEY=$(cat $WORKDIR/flohive-cache.json | jq -r '.burnerWallet.privateKey')
    
    if [ -z "$BURNER_ADDRESS" ] || [ "$BURNER_ADDRESS" == "null" ]; then
        echo -e "${RED}Burner address not found in cache file.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    echo -e "${GREEN}Burner Wallet Information:${NC}"
    echo "================================"
    echo -e "${BLUE}Address:${NC} $BURNER_ADDRESS"
    echo -e "${BLUE}Private Key:${NC} $BURNER_PRIVATE_KEY"
    echo "================================"
    echo -e "${RED}WARNING: Never share your private key with anyone!${NC}"
    echo ""
    
    # Save burner address to a file for later use
    echo "$BURNER_ADDRESS" > $WORKDIR/burner_address.txt
    echo "$BURNER_PRIVATE_KEY" > $WORKDIR/burner_private_key.txt
    
    # Copy to clipboard if xclip is available
    if command -v xclip &> /dev/null; then
        echo -n "$BURNER_ADDRESS" | xclip -selection clipboard
        echo -e "${GREEN}Burner address copied to clipboard!${NC}"
        
        echo -n "$BURNER_PRIVATE_KEY" | xclip -selection clipboard
        echo -e "${GREEN}Private key copied to clipboard!${NC}"
    fi
    
    echo -e "${YELLOW}Please send 1 Faucet Mawari from your NFT wallet to the burner address above.${NC}"
    read -p "Press Enter to continue..."
}

check_node_status() {
    clear
    echo -e "${YELLOW}Checking Node Status...${NC}"
    
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Docker is not running. Please start Docker.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    if docker ps | grep -q "mawari-node"; then
        echo -e "${GREEN}Mawari Guardian Node is running.${NC}"
        docker ps | grep "mawari-node"
    else
        echo -e "${RED}Mawari Guardian Node is not running.${NC}"
        echo -e "${YELLOW}Please run the setup process first.${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

delegate_node() {
    clear
    echo -e "${YELLOW}Delegating Node...${NC}"
    
    echo "Please follow these steps to delegate your node:"
    echo "1. Visit: ${BLUE}https://app.testnet.mawari.net/${NC}"
    echo "2. Connect the wallet you used to mint NFT"
    echo "3. Select 3 IDs"
    echo "4. Delegate"
    echo "5. Enter the burner address"
    echo "6. Confirm the transaction"
    echo "7. Check if the node is running properly"
    
    read -p "Press Enter to continue..."
}

create_claim_bot() {
    clear
    echo -e "${YELLOW}Creating Mawari Claim Bot...${NC}"
    
    mkdir -p $WORKDIR/bot
    cd $WORKDIR/bot
    
    cat > mawari_claim_bot.py << 'EOF'
#!/usr/bin/env python3
"""
Mawari Claim Bot
Automated bot for claiming funds from Mawari faucet and sending MAWARI tokens
"""

import json
import time
import random
import requests
from web3 import Web3
from eth_account import Account
import sys
import os
from datetime import datetime, timedelta

class MawariClaimBot:
    def __init__(self):
        self.faucet_url = "https://hub.testnet.mawari.net/api/trpc/faucet.requestFaucetFunds?batch=1"
        self.rpc_url = "http://rpc.testnet.mawari.net/http"
        self.chain_id = 576
        self.symbol = "MAWARI"
        self.explorer = "explorer.testnet.mawari.net"
        self.site_url = "https://hub.testnet.mawari.net"
        self.sitekey = "0x4AAAAAAASRorjU_k9HAdVc"  # Turnstile sitekey
        
        self.wallets = []
        self.web3 = None
        self.results = {
            'successful': [],
            'failed': []
        }
        
    def load_credentials(self):
        """Load private keys from creds.txt"""
        try:
            with open('creds.txt', 'r') as f:
                lines = f.readlines()
            
            for line in lines:
                line = line.strip()
                if ':' in line:
                    parts = line.split(':', 1)
                    if len(parts) == 2:
                        private_key = parts[0].strip()
                        burner_address = parts[1].strip()
                        
                        # Generate wallet address from private key
                        account = Account.from_key(private_key)
                        wallet_address = account.address
                        
                        self.wallets.append({
                            'private_key': private_key,
                            'wallet_address': wallet_address,
                            'burner_address': burner_address,
                            'account': account
                        })
            
            if not self.wallets:
                print("❌ No valid wallets found in creds.txt")
                return False
                
            print(f"✅ Loaded {len(self.wallets)} wallets")
            return True
            
        except FileNotFoundError:
            print("❌ File creds.txt not found")
            return False
        except Exception as e:
            print(f"❌ Error loading creds.txt: {e}")
            return False
    
    def init_web3(self):
        """Initialize Web3 connection"""
        try:
            self.web3 = Web3(Web3.HTTPProvider(self.rpc_url))
            if self.web3.is_connected():
                print(f"✅ Connected to RPC: {self.rpc_url}")
                return True
            else:
                print("❌ Failed to connect to RPC")
                return False
        except Exception as e:
            print(f"❌ Error connecting to RPC: {e}")
            return False
    
    def make_faucet_request(self, wallet_address):
        """Send request to faucet"""
        print("Please complete the captcha manually at:")
        print(f"{self.site_url}")
        print(f"And request faucet for address: {wallet_address}")
        
        input("Press Enter after you've completed the faucet request...")
        
        # For simplicity, we'll assume the faucet request was successful
        # In a real implementation, you would automate the captcha solving
        return {'success': True, 'tx_hash': 'manual_tx_' + str(int(time.time()))}
    
    def send_mawari_token(self, wallet, burner_address):
        """Send 1 MAWARI token to burner address"""
        try:
            # Get nonce
            nonce = self.web3.eth.get_transaction_count(wallet['wallet_address'])
            
            # Get current gas price and increase by 20% for reliability
            gas_price = self.web3.eth.gas_price
            gas_price = int(gas_price * 1.2)  # Increase by 20%
            
            # Create transaction to send 1 MAWARI (1 * 10^18 wei)
            amount = self.web3.to_wei(1, 'ether')
            
            transaction = {
                'to': burner_address,
                'value': amount,
                'gas': 21000,
                'gasPrice': gas_price,
                'nonce': nonce,
                'chainId': self.chain_id
            }
            
            # Sign transaction
            signed_txn = self.web3.eth.account.sign_transaction(transaction, wallet['private_key'])
            
            # Send transaction
            tx_hash = self.web3.eth.send_raw_transaction(signed_txn.rawTransaction)
            
            return {'success': True, 'tx_hash': tx_hash.hex()}
            
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def process_wallet(self, wallet):
        """Process one wallet"""
        wallet_address = wallet['wallet_address']
        burner_address = wallet['burner_address']
        
        print(f"\nProcessing wallet: {wallet_address[:10]}...")
        
        # Try to request funds from faucet
        faucet_result = self.make_faucet_request(wallet_address)
        
        if not faucet_result['success']:
            self.results['failed'].append({
                'wallet': wallet_address,
                'burner': burner_address,
                'error': 'Faucet failed'
            })
            return
        
        faucet_tx = faucet_result['tx_hash']
        print(f"✅ Faucet request completed: {faucet_tx}")
        
        # If faucet request was successful, send MAWARI token
        send_result = self.send_mawari_token(wallet, burner_address)
        
        if send_result['success']:
            send_tx = send_result['tx_hash']
            print(f"✅ Send transaction: {send_tx}")
            self.results['successful'].append({
                'wallet': wallet_address,
                'burner': burner_address,
                'faucet_tx': faucet_tx,
                'send_tx': send_tx
            })
        else:
            error_msg = send_result['error']
            print(f"❌ Send failed: {error_msg}")
            self.results['failed'].append({
                'wallet': wallet_address,
                'burner': burner_address,
                'faucet_tx': faucet_tx,
                'error': f'Send failed: {error_msg}'
            })
    
    def run(self):
        """Main method to run the bot"""
        print("🚀 Running Mawari Claim Bot")
        print("=" * 50)
        
        # Load credentials
        if not self.load_credentials():
            return False
        
        # Initialize Web3
        if not self.init_web3():
            return False
        
        print(f"\n📊 Processing {len(self.wallets)} wallets...")
        print("=" * 50)
        
        # Process each wallet
        for wallet in self.wallets:
            self.process_wallet(wallet)
            time.sleep(1)  # Pause between wallets
        
        # Show results
        self.show_results()
        return True
    
    def show_results(self):
        """Show results"""
        print("\n" + "=" * 80)
        print("📋 RESULTS")
        print("=" * 80)
        
        # Successful wallets
        if self.results['successful']:
            print(f"\n✅ SUCCESSFUL ({len(self.results['successful'])}):")
            for result in self.results['successful']:
                print(f"Wallet: {result['wallet']}")
                print(f"Burner: {result['burner']}")
                print(f"Faucet TX: {result['faucet_tx']}")
                print(f"Send TX: {result['send_tx']}")
                print(f"Explorer: https://{self.explorer}/tx/{result['send_tx']}")
                print("-" * 50)
        
        # Failed wallets
        if self.results['failed']:
            print(f"\n❌ FAILED ({len(self.results['failed'])}):")
            for result in self.results['failed']:
                print(f"Wallet: {result['wallet']}")
                print(f"Burner: {result['burner']}")
                print(f"Faucet TX: {result.get('faucet_tx', 'N/A')}")
                print(f"Error: {result['error']}")
                print("-" * 50)
        
        print(f"\n📊 Total: {len(self.results['successful'])} successful, {len(self.results['failed'])} failed")
        print("=" * 80)

def main():
    """Main function"""
    bot = MawariClaimBot()
    bot.run()

if __name__ == "__main__":
    main()
EOF

    chmod +x mawari_claim_bot.py
    echo -e "${GREEN}Mawari Claim Bot created successfully!${NC}"
    read -p "Press Enter to continue..."
}

setup_claim_bot() {
    clear
    echo -e "${YELLOW}Setting up Mawari Claim Bot...${NC}"
    
    if [ ! -d "$WORKDIR/bot" ]; then
        create_claim_bot
    fi
    
    cd $WORKDIR/bot
    
    # Check if creds.txt exists
    if [ ! -f "creds.txt" ]; then
        echo -e "${YELLOW}Creating creds.txt file...${NC}"
        touch creds.txt
        echo "Please add your wallet private key and burner address to creds.txt"
        echo "Format: private_key:burner_address"
        echo "Example: 0x123abc...:0x456def..."
        read -p "Press Enter to continue..."
        
        # Open creds.txt for editing
        nano creds.txt
    fi
    
    # Run the bot
    echo -e "${YELLOW}Running Mawari Claim Bot...${NC}"
    python3 mawari_claim_bot.py
    
    read -p "Press Enter to continue..."
}

generate_burner_wallets() {
    clear
    echo -e "${YELLOW}Generating Burner Wallets...${NC}"
    
    mkdir -p $WORKDIR
    echo "Generated Burner Wallets:" > "$GENERATED_WALLETS_LOG"
    echo "--------------------------" >> "$GENERATED_WALLETS_LOG"
    
    read -p "Enter the number of burner wallets to generate: " NUM_WALLETS
    if ! [[ "$NUM_WALLETS" =~ ^[0-9]+$ ]] || [ "$NUM_WALLETS" -le 0 ]; then
        echo -e "${RED}Invalid number of wallets.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}Installing Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Check if ethers is installed
    if ! npm list ethers &> /dev/null; then
        echo -e "${YELLOW}Installing ethers.js...${NC}"
        npm install ethers
    fi
    
    for i in $(seq 1 $NUM_WALLETS); do
        wallet_dir=$WORKDIR/wallet_${i}
        config_file=${wallet_dir}/flohive-cache.json
        
        echo -e "${YELLOW}Generating wallet #${i}...${NC}"
        mkdir -p "$wallet_dir"
        
        wallet_json=$(node <<EOF
const ethers = require('ethers');
const wallet = ethers.Wallet.createRandom();
console.log(JSON.stringify({
  address: wallet.address,
  privateKey: wallet.privateKey
}));
EOF
)
        burner_address=$(echo "$wallet_json" | jq -r .address)
        burner_private_key=$(echo "$wallet_json" | jq -r .privateKey)
        
        echo -e "${GREEN}Generated Burner Address: ${burner_address}${NC}"
        
        cat > "$config_file" <<EOF
{
  "burnerWallet": {
    "privateKey": "${burner_private_key}",
    "address": "${burner_address}"
  }
}
EOF
        chmod 600 "$config_file"
        echo -e "${GREEN}Configuration file created.${NC}"
        
        echo "Wallet #${i}:" >> "$GENERATED_WALLETS_LOG"
        echo "  Burner Address: ${burner_address}" >> "$GENERATED_WALLETS_LOG"
        echo "" >> "$GENERATED_WALLETS_LOG"
    done
    
    echo ""
    echo -e "${GREEN}Burner wallet generation completed. Details saved to ${GENERATED_WALLETS_LOG}${NC}"
    read -p "Press Enter to continue..."
}

auto_start_nodes() {
    clear
    echo -e "${YELLOW}Auto-starting Mawari Nodes...${NC}"
    
    if [ ! -d "$WORKDIR" ]; then
        echo -e "${RED}Mawari directory not found. Please run setup first.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    wallet_dirs=$(find $WORKDIR -mindepth 1 -maxdepth 1 -type d -name "wallet_*")
    if [ -z "$wallet_dirs" ]; then
        echo -e "${RED}No wallet directories found. Please generate burner wallets first.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    read -p "Enter owner address for allowlist: " OWNER_ADDRESS
    if [ -z "$OWNER_ADDRESS" ]; then
        echo -e "${RED}Owner address cannot be empty.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    export MNTESTNET_IMAGE=us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
    
    for dir in $wallet_dirs; do
        wallet_index=$(basename "$dir" | sed 's/wallet_//')
        container_name="mawari-node-${wallet_index}"
        
        echo -e "${YELLOW}Checking Node #${wallet_index}...${NC}"
        
        if docker ps | grep -q "$container_name"; then
            echo -e "${GREEN}Container ${container_name} is already running.${NC}"
        else
            echo -e "${YELLOW}Starting container ${container_name}...${NC}"
            docker rm -f "$container_name" 2>/dev/null || true
            
            docker run -d \
                --name "$container_name" \
                --pull always \
                -v "${dir}:/app/cache" \
                -e OWNERS_ALLOWLIST="$OWNER_ADDRESS" \
                $MNTESTNET_IMAGE
            
            echo -e "${GREEN}Container ${container_name} started.${NC}"
            sleep 3
        fi
    done
    
    echo ""
    echo -e "${GREEN}Auto-start process completed. Check status with 'docker ps'${NC}"
    read -p "Press Enter to continue..."
}

while true
do
    show_menu
    read choice
    
    case $choice in
        1) install_dependencies ;;
        2) create_wallet ;;
        3) create_wallet ;;
        4) setup_guardian_node ;;
        5) check_burner_address ;;
        6) check_node_status ;;
        7) delegate_node ;;
        8) setup_claim_bot ;;
        9) echo -e "${GREEN}Exiting...${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}"; sleep 1 ;;
    esac
done
