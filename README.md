
# 🚀 Mawari Network Guardian Node Setup

<div align="center">
  <img src="https://img.shields.io/badge/Mawari-Network-blue?style=for-the-badge&logo=ethereum&logoColor=white" alt="Mawari Network">
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</div>

<div align="center">
  <h3>Automated Guardian Node Setup & Management Script</h3>
  <p>Complete solution for Mawari Network Guardian Node deployment with wallet management, faucet claiming, and delegation automation</p>
</div>

---

## ✨ Key Features

- **🔧 One-Click Installation**: Automated dependency installation (Docker, Python, etc.)
- **🌐 Node Management**: Easy Guardian Node setup, monitoring, and status checking
- **💳 Wallet Operations**: Wallet creation, burner address management, and private key access
- **🚰 Faucet Automation**: Automated faucet claiming and token transfer to burner wallets
- **🔗 Delegation Support**: Streamlined node delegation process with step-by-step guidance
- **🛡️ Security First**: Secure private key handling with clipboard integration
- **📊 Multi-Wallet Support**: Generate and manage multiple burner wallets simultaneously
- **🔄 Screen Integration**: Run nodes in detached screen sessions for persistent operation

---

## 📋 Prerequisites

- Linux-based operating system (Ubuntu 20.04+ recommended)
- Basic command-line knowledge
- Mawari Network wallet for claiming and delegation
- Internet connection for package downloads

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/xPOURY4/mawari-node-setup.git
cd mawari-node-setup
```

### 2. Make Script Executable
```bash
chmod +x mawari-setup.sh
```

### 3. Run in Screen Session (Recommended)
```bash
screen -S mawari
./mawari-setup.sh
```

### 4. Detach from Screen
After starting the script, detach from the screen session:
```
Ctrl + A, then D
```

### 5. Reattach to Screen (When Needed)
```bash
screen -r mawari
```

---

## 📖 Detailed Usage Guide

### Running the Script

The script provides an interactive menu system. You can run it either in a screen session (recommended for persistent operation) or directly in your terminal.

#### Option A: Screen Session (Recommended)
```bash
# Create new screen session
screen -S mawari

# Run the script
./mawari-setup.sh

# Detach from screen (script continues running)
Ctrl + A, then D

# Reattach later
screen -r mawari
```

#### Option B: Direct Terminal
```bash
./mawari-setup.sh
```

### Main Menu Options

| Option | Description |
|--------|-------------|
| **1** | Install Dependencies - Docker, Python, and required packages |
| **2** | Create New Wallet - Guidance for wallet creation and NFT minting |
| **3** | Claim Faucet & Mint 3X NFT - Instructions for faucet claiming |
| **4** | Setup Guardian Node - Deploy and start Guardian Node container |
| **5** | Check Burner Address - View burner address and private key |
| **6** | Node Status - Check running node status and logs |
| **7** | Delegate Node - Step-by-step delegation instructions |
| **8** | Claim Faucet & Send to Burner - Automated claiming and transfer |
| **9** | Exit - Safely exit the script |

---

## 🔐 Security Features

### Private Key Management
- **Secure Display**: Private keys are displayed with clear warnings
- **Clipboard Integration**: Automatic copying to clipboard (when `xclip` is installed)
- **File Storage**: Secure storage in `~/mawari/` with restricted permissions
- **Warning Messages**: Clear security warnings before displaying sensitive data

### Screen Session Benefits
- **Persistent Operation**: Nodes continue running even after terminal closure
- **Isolated Environment**: Separates node operation from management tasks
- **Reattachable**: Easily reconnect to monitor or manage nodes
- **Background Execution**: Nodes run without occupying your terminal

---

## 🛠️ Advanced Operations

### Checking Burner Address (Option 5)
```bash
# Access burner wallet information
- Displays burner address and private key
- Copies both to clipboard automatically
- Saves to files: 
  - ~/mawari/burner_address.txt
  - ~/mawari/burner_private_key.txt
- Shows security warnings
```

### Node Status Monitoring (Option 6)
```bash
# Check all running nodes
- Lists active Docker containers
- Shows resource usage
- Provides quick access to logs
```

### Automated Faucet Claiming (Option 8)
```bash
# Automated claiming process
- Creates claim bot if needed
- Guides through credential setup
- Automates faucet claiming and token transfer
- Provides transaction receipts
```

---

## 📁 Directory Structure

```
~/mawari/
├── flohive-cache.json          # Node configuration
├── burner_address.txt          # Saved burner addresses
├── burner_private_key.txt     # Saved private keys
├── generated_wallets.log      # Wallet generation log
├── setup.log                  # Installation logs
├── bot/                       # Claim bot directory
│   ├── mawari_claim_bot.py    # Claim bot script
│   └── creds.txt              # Wallet credentials
└── wallet_*/                  # Individual wallet directories
    └── flohive-cache.json     # Wallet-specific config
```

---

## 🐳 Docker Integration

The script uses Docker containers for reliable node deployment:

```bash
docker run -d \
  --name mawari-node \
  --pull always \
  -v ~/mawari:/app/cache \
  -e OWNERS_ALLOWLIST=YOUR_WALLET_ADDRESS \
  us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
```

---

## 🔍 Monitoring & Management

### Check Node Status
```bash
# View running containers
docker ps | grep mawari-node

# View logs
docker logs mawari-node

# Monitor resources
docker stats mawari-node
```

### Screen Session Management
```bash
# List all screen sessions
screen -ls

# Reattach to specific session
screen -r mawari

# Kill a screen session
screen -XS mawari quit
```

---

## 🛡️ Best Practices

1. **Always use screen sessions** for persistent node operation
2. **Never share private keys** - displayed with clear warnings
3. **Regularly check node status** using option 6
4. **Keep backups** of important files in `~/mawari/`
5. **Monitor resource usage** with `docker stats`
6. **Update regularly** by pulling the latest repository changes

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Mawari Network](https://mawari.net/) for the Guardian Node implementation
- [Docker](https://www.docker.com/) for containerization technology
- [Web3.py](https://web3py.readthedocs.io/) for Ethereum integration
- The open-source community for various tools and libraries

---

## 👨‍💻 Author

**Pourya**  
- GitHub: [xPOURY4](https://github.com/xPOURY4)
- Twitter: [TheRealPourya](https://twitter.com/TheRealPourya)

---

<div align="center">
  <i>If you found this project helpful, please consider giving it a ⭐️ on GitHub!</i>
  <br><br>
  <img src="https://img.shields.io/github/stars/xPOURY4/mawari-node-setup?style=social" alt="GitHub stars">
</div>
