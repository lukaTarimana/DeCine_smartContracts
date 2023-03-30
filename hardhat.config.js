require("hardhat-contract-sizer");
require("solidity-coverage");
require("hardhat-gas-reporter");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("hardhat-output-validator");
require("hardhat-exposed");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

const config = {
    defaultNetwork: "hardhat",
    networks: {
        mainnet: {
            url: `${
                process.env.BSC_MAINNET_URL
                    ? process.env.BSC_MAINNET_URL
                    : "https://rpc.ankr.com/bsc"
            }`,
            chainId: 56,
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
        },
        testnet: {
            url: `${
                process.env.BSC_TESTNET_URL
                    ? process.env.BSC_TESTNET_URL
                    : "https://data-seed-prebsc-1-s1.binance.org:8545/"
            }`,
            gas: "auto",
            chainId: 97,
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
        },
        framesh: {
            url: "http://127.0.0.1:1248",
            gas: "auto",
            timeout: 10 * 60 * 1000 // 10 minutes
        },
        local: {
            url: "http://127.0.0.1:8545/",
            chainId: 31337
        },
        hardhat: {
            forking: {
                enabled: true,
                url: "https://rpc.ankr.com/bsc" // mainnet
            },
            accounts: process.env.PRIVATE_KEY
                ? {
                      privateKey: `0x${process.env.PRIVATE_KEY}`,
                      balance: "10000000000000000000000"
                  }
                : {}
        }
    },
    etherscan: {
        apiKey: process.env.BSCSCAN_API_KEY ? process.env.BSCSCAN_API_KEY : ""
    },
    solidity: {
        version: "0.8.19",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    paths: {
        sources: "./contracts",
        tests: "./tests",
        cache: "./cache",
        artifacts: "./artifacts"
    },
    mocha: {
        timeout: 12000000
    },
    gasReporter: {
        currency: "BNB",
        gasPrice: 21
    },
    contractSizer: {
        alphaSort: false,
        runOnCompile: true,
        disambiguatePaths: false
    },
    outputValidator: {
        runOnCompile: true,
        errorMode: false,
        checks: {
            title: "warn",
            details: "warn",
            params: "warn",
            returns: "warn",
            compilationWarnings: "warn",
            variables: false,
            events: true
        },
        exclude: ["contracts-exposed/", "contracts/tests/", "node_modules/erc721a-upgradeable/contracts", "erc721a-upgradeable/contracts/"]
    }
};

module.exports = config;
