const hre = require("hardhat");
const fs = require("fs/promises");
const PATH_TO_DEPLOYED_CONTRACTS = "./deployed-contracts.json";

exports.getAddrs = async () => {
    const data = await fs.readFile(PATH_TO_DEPLOYED_CONTRACTS, {
        encoding: "utf8"
    });
    return JSON.parse(data);
};

exports.getDeployedContracts = async () => {
    const addrs = await exports.getAddrs();
    return {
        crx: (await hre.ethers.getContractFactory("Cortex")).attach(addrs.crx),
        mastermind: (await hre.ethers.getContractFactory("MasterMind")).attach(
            addrs?.mastermind || "0x0"
        ),
        rf: (await hre.ethers.getContractFactory("ResearchFacility")).attach(
            addrs?.rf || "0x0"
        ),
        scientist: (await hre.ethers.getContractFactory("Scientist")).attach(
            addrs?.scientist || "0x0"
        ),
        factory: (
            await hre.ethers.getContractFactory("UniswapV2Factory")
        ).attach(addrs?.factory || "0x0"),
        router: (
            await hre.ethers.getContractFactory("UniswapV2Router02")
        ).attach(addrs?.router || "0x0"),
        weth9: (await hre.ethers.getContractFactory("WETH9")).attach(
            addrs?.weth9 || "0x0"
        ),
        multicall: (await hre.ethers.getContractFactory("Multicall2")).attach(
            addrs?.multicall || "0x0"
        )
    };
};

exports.updateDeployedAddrs = async (newAddrs) => {
    const old = await exports.getAddrs();
    const addrs = {
        ...old,
        ...newAddrs // this overwrites the old addresses with the new ones.
    };

    let data = JSON.stringify(addrs, null, 2);
    await fs.writeFile("./deployed-contracts.json", data);
};
