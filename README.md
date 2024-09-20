# TokenSwap Smart Contract

## Overview

TokenSwap is a decentralized exchange (DEX) smart contract that allows users to create and execute token swap orders on the Ethereum blockchain. It provides a simple and secure way for users to exchange ERC20 tokens directly with each other without the need for a centralized intermediary.

## Features

- Create swap orders
- Cancel existing orders
- Execute orders
- View order details
- Non-custodial (contract never takes ownership of tokens)
- Reentrancy protection
- Owner-managed contract

## Smart Contract Details

The main contract `TokenSwap.sol` is built using Solidity version 0.8.24 and utilizes OpenZeppelin libraries for enhanced security and standard implementations.

### Key Functions

1. `createOrder`: Create a new swap order
2. `cancelOrder`: Cancel an existing order (only by the creator)
3. `executeOrder`: Execute an existing order (by the counterparty)
4. `getOrder`: Retrieve details of a specific order
5. `getOrderCount`: Get the total number of orders created
6. `getTokenOffered`: Get the address of the token offered in an order
7. `getTokenRequested`: Get the address of the token requested in an order

## Development Environment

This project uses Hardhat as the development environment. The configuration supports:

- Mainnet forking for testing
- Deployment to Lisk Sepolia testnet
- Etherscan-compatible block explorer integration

## Prerequisites

- Node.js (v14+ recommended)
- npm or yarn

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd tokenswap
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a `.env` file in the root directory with the following variables:
   ```
   ALCHEMY_MAINNET_API_KEY_URL=<your-alchemy-api-key>
   ACCOUNT_PRIVATE_KEY=<your-private-key>
   LISK_RPC_URL=<lisk-sepolia-rpc-url>
   ```

## Usage

### Compile Contracts
npx hardhat compile

### Run Tests
npx hardhat test

### Deploy to Lisk Sepolia Testnet
npx hardhat run scripts/deploy.js --network lisk-sepolia


## Security Considerations

- The contract uses OpenZeppelin's `SafeERC20` to prevent common ERC20 token vulnerabilities.
- Reentrancy protection is implemented using OpenZeppelin's `ReentrancyGuard`.
- The contract is `Ownable`, allowing for potential future upgrades or emergency functions.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
