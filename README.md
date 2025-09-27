# NFT Scam Trap 🛡️

A smart contract security project designed to detect and prevent NFT-based scams through keyword analysis and suspicious behavior monitoring on Drosera Network.

## 🎯 Overview

This project implements a trap mechanism for NFT contracts that can identify and flag suspicious activities commonly associated with scam operations, including:

- Fake giveaway announcements
- Phishing attempts through NFT metadata
- Suspicious promotional language
- Common scam keywords and phrases


## 📁 Project Structure

```
nft-scam-trap/
├── .github/            # GitHub workflows and templates
├── lib/                # Forge dependencies and libraries
├── script/             # Deployment and interaction scripts
├── src/                # Smart contract source code
├── test/               # Contract tests
├── .gitignore          # Git ignore patterns
├── .gitmodules         # Git submodule configuration
├── README.md           # Project documentation
├── drosera.toml        # Security monitoring configuration
├── foundry.lock        # Dependency lock file
└── foundry.toml        # Foundry project configuration
```


### Installation

1. Clone the repository:
```bash
git clone https://github.com/Phascary/nft-scam-trap.git
cd nft-scam-trap
```

2. Install dependencies:
```bash
forge install
```

3. Build the contracts:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

## 🔧 Usage

### Deploying the Contract

```bash
forge create src/YourContract.sol:YourContract \
    --rpc-url YOUR_RPC_URL \
    --private-key YOUR_PRIVATE_KEY
```

### Testing Scam Detection

The project includes functionality to test various scam scenarios:

```bash
# Test suspicious NFT minting
cast send CONTRACT_ADDRESS \
    "mintSuspiciousNFT(string,string)" \
    "FREE BITCOIN AIRDROP" \
    "Suspicious description text" \
    --private-key YOUR_PRIVATE_KEY \
    --rpc-url YOUR_RPC_URL
```

## 🔍 Features

- **Keyword Detection**: Automatically flags NFTs with suspicious keywords
- **Pattern Analysis**: Identifies common scam patterns in metadata
- **Real-time Monitoring**: Integration with Drosera for continuous security monitoring
- **Gas Optimization**: Efficient contract design for minimal gas usage
- **Comprehensive Testing**: Full test suite covering various scam scenarios

## 🧪 Testing

Run the complete test suite:

```bash
# Run all tests
forge test

# Run tests with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/YourTest.t.sol
```

## 📊 Security Analysis

This project uses Drosera for advanced security monitoring. The configuration can be found in `drosera.toml`.

Key security features:
- Suspicious keyword detection
- Metadata analysis
- Real-time alerting

## 🛡️ Security Considerations

- Always test on testnets before mainnet deployment
- Keep private keys secure and never commit them to version control


---


