# OpenFundScience

A decentralized science funding and publishing protocol that empowers researchers to raise funds, publish transparently, and tokenize intellectual property — all on-chain.

---

## Overview

OpenFundScience consists of ten core smart contracts that together build a transparent, community-driven ecosystem for decentralized scientific discovery:

1. **Researcher Identity Contract** – Verifies and registers researchers with soulbound credentials.
2. **Proposal & Grant Contract** – Manages project submissions and community-based funding.
3. **Funding Escrow Contract** – Holds and disburses funds based on milestone approvals.
4. **Milestone Review Contract** – Coordinates milestone validation by peer reviewers.
5. **Peer Review Staking Contract** – Enables transparent, incentivized peer review.
6. **Publishing Contract** – On-chain publishing with version control and timestamping.
7. **IP NFT Contract** – Tokenizes research output into licenseable or tradable NFTs.
8. **Reputation Contract** – Tracks contributor performance across the platform.
9. **Governance DAO Contract** – Community-led funding allocation and protocol decisions.
10. **IP Marketplace Contract** – Facilitates discovery and licensing of scientific IP.

---

## Features

- **Decentralized grant proposals** with DAO and community participation  
- **Milestone-based funding** using escrowed contracts  
- **Peer review staking** with transparent, reputation-based outcomes  
- **On-chain research publishing** with permanent, auditable storage  
- **NFT-based licensing** of IP, discoveries, and datasets  
- **Contributor reputation tracking** based on on-chain activity  
- **DAO governance** for protocol upgrades and funding rounds  
- **Open marketplace** for tokenized IP and licensing deals  

---

## Smart Contracts

### Researcher Identity Contract
- Register verified researchers with Clarity-based soulbound tokens  
- Prevents duplicate or anonymous researcher profiles  
- Integrates with off-chain credential verification (via oracles)

### Proposal & Grant Contract
- Submit research proposals with funding targets  
- Community and DAO-backed grant mechanisms  
- Tracks project states (submitted, funded, in progress, completed)

### Funding Escrow Contract
- Locks funds during project execution  
- Disburses by milestone completion validated by peer reviewers  
- Refunds in case of failure or dispute

### Milestone Review Contract
- Assigns peer reviewers randomly or via staking  
- Reviewers vote to approve/reject milestone completion  
- Final verdict triggers escrow release

### Peer Review Staking Contract
- Reviewers stake tokens to participate  
- Reputation score adjustment for good/bad reviews  
- Slashing for malicious or biased reviews

### Publishing Contract
- Store paper metadata and hashes (IPFS or Arweave)  
- Supports versioning, citations, and linking datasets  
- Immutable record of publication timestamp

### IP NFT Contract
- Tokenize research outputs (e.g. methods, data, software)  
- Attach licensing terms to NFTs  
- Enables fractional or exclusive licensing

### Reputation Contract
- Score for researchers, reviewers, and funders  
- Based on activity, approvals, disputes, and longevity  
- Used for role access and DAO voting power

### Governance DAO Contract
- Token-governed DAO for funding rounds and dispute arbitration  
- Submit and vote on new platform features or rule changes  
- Treasury management for DAO-held funds

### IP Marketplace Contract
- List and discover research-backed IP NFTs  
- Licensing, purchasing, and revenue sharing  
- Transparent record of buyers and licenses

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/openfundscience.git
   ```
3. Run tests:
    ```bash
    npm test
    ```
4. Deploy contracts:
    ```bash
    clarinet deploy
    ```

---

## Usage

Each contract operates independently but integrates into the broader OpenFundScience ecosystem. Researchers, reviewers, and token holders interact via the Clarity smart contracts to create a decentralized, incentivized research environment.

Refer to individual contract folders for ABI definitions, usage guides, and function call examples.

---

## License

MIT License