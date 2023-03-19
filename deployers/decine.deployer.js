const hre = require("hardhat");
const {upgrades} = require("hardhat");

const decineConfig = {
    signingAddress: process.env.SIGNING_ADDRESS
};

exports.deploy = async () => {
    console.log(decineConfig);
    console.info("==================================");
    console.info("Deploying DeCine contracts...");
    console.info("==================================");
    console.info("Deploying DeCineToken contract...");
    console.info("==================================");
    let factory = await hre.ethers.getContractFactory("DeCineToken");
    let deployTx = await upgrades.deployProxy(factory, []);
    const decineToken = await deployTx.deployed();
    console.info("DeCineToken contract deployed to:", decineToken.address);
    console.info("==================================");
    console.info("Deploying DeCineLoyaltyToken contract...");
    console.info("==================================");
    factory = await hre.ethers.getContractFactory("DeCineLoyaltyToken");
    deployTx = await upgrades.deployProxy(factory, []);
    const decineLoyaltyToken = await deployTx.deployed();
    console.info(
        "DeCineLoyaltyToken contract deployed to:",
        decineLoyaltyToken.address
    );
    console.info("==================================");
    console.info("Deploying DeCineNFT contract...");
    console.info("==================================");
    factory = await hre.ethers.getContractFactory("DeCineNFT");
    deployTx = await upgrades.deployProxy(factory, []);
    const decineNFT = await deployTx.deployed();
    console.info("DeCineNFT contract deployed to:", decineNFT.address);
    console.info("==================================");
    console.info("Deploying DeCine contract...");
    console.info("==================================");
    console.log(
      [
        decineToken.address,
        decineLoyaltyToken.address,
        decineNFT.address,
        decineConfig.signingAddress
    ]
    );
    factory = await hre.ethers.getContractFactory("DeCine");
    deployTx = await upgrades.deployProxy(factory, [
        decineToken.address,
        decineLoyaltyToken.address,
        decineNFT.address,
        decineConfig.signingAddress
    ]);
    const decine = await deployTx.deployed();
    console.info("DeCine contract deployed to:", decine.address);
    console.info("==================================");

    return {
        decine,
        decineToken,
        decineLoyaltyToken,
        decineNFT
    };
};

exports.verify = async (decine, dct, dcl, dcNft) => {
    console.info("==================================");
    console.info("Verifying DeCine smart contract...");
    console.info("==================================");

    await hre.run("verify:verify", {
        address: decine,
        constructorArguments: [
            dct,
            dcl,
            dcNft,
            decineConfig.signingAddress
        ]
    });

    console.info("==================================");
    console.info("Verifying DeCineToken smart contract...");
    console.info("==================================");

    await hre.run("verify:verify", {
        address: dct,
        constructorArguments: []
    });

    console.info("==================================");
    console.info("Verifying DeCineLoyaltyToken smart contract...");
    console.info("==================================");

    await hre.run("verify:verify", {
        address: dcl,
        constructorArguments: []
    });

    console.info("==================================");
    console.info("Verifying DeCineNFT smart contract...");
    console.info("==================================");

    await hre.run("verify:verify", {
        address: dcNft,
        constructorArguments: []
    });

    console.info("==================================");
};
