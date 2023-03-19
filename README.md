# DeCine Smart Contracts
The smart contracts used throughout the DeCine platform.

DeCine is a blockchain-based video streaming platform that uses smart contracts to manage platform functionality, rewards, funds, user ratings, and ads. The platform has four main components:

DeCine: The main smart contract of the DeCine platform handles the core functionality of the platform. This includes managing user accounts, content distribution, user ratings, and rewards. The smart contract also manages the platform's funds, including incoming revenue from ads and user payments.

DCToken: The DCToken is the main token of the DeCine platform. It is used for transactions on the platform, including payments for content and rewards. The DCToken is an ERC-20 token that is built on the Ethereum blockchain.

DCLToken: The DCLToken is the reward token of the DeCine platform. It is used to reward users and creators on the platform for their contributions and activity. The DCLToken is also an ERC-20 token that is built on the Ethereum blockchain.

DCNFT: The DCNFT is a dynamic NFT system that is used to manage user rewards on the DeCine platform. The system allows multiple operators to reward their users and manage a ranking system that helps operators benefit their users with different rewards. This system is built on top of the BNB blockchain, and it provides a way for users to earn rewards for their contributions to platforms.

Overall, DeCine is an innovative platform that leverages blockchain technology to provide a more transparent and decentralized video streaming experience. The platform's use of smart contracts and tokens helps to ensure that users and creators are properly incentivized and rewarded for their contributions to the platform.

# How to operate. 
## Step 1: Setup
In your terminal, go into the project directory and run  
`npm install`  
This will install project dependencies.  
  
In your project directory, you will find a `.env.example` file (the file might be hidden on some systems, so be sure to enable showing hidden files). Create a `.env` file and copy the content of the `.env.example` to the `.env` file. Open the `.env` file and configure it.
  
## Step 2: Deployment
Make sure you are running the script with the correct private key specified in the `.env` file, and that your wallet has enough funds.
Run the following command to deploy the airdrop smart contract:
`npx hardhat deploy --network mainnet`  
This will deploy the smart contract and give you its address if the deployment is successful.  
To deploy to testnet use `--network testnet`.
