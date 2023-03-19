const dotenv = require("dotenv");
dotenv.config({ path: __dirname + "/../.env"});


module.exports = {
    config: {
        bscApiKey: process.env.BSCSCAN_API_KEY,
        privateKey: process.env.PRIVATE_KEY,
        airdropContractAddress: process.env.AIRDROP_CONTRACT_ADDRESS,
        swychAddress: process.env.SWYCH_ADDRESS,
        bscRpc: process.env.BSC_MAINNET_URL,
        balanceFetcher: process.env.BALANCE_FETCHER_ADDRESS
    }
};
