const deployers = require("../deployers/deployers");
const {task} = require("hardhat/config");
const helpers = require("./helpers.js");

task("deploy", "Deploys the smart contracts")
    .setAction(async () => {
        try {
            await deployers.decine.deploy();
        } catch (error) {
            console.error(error);
        }
    });

task("verify:project", "Tries to verify all deployed contracts").setAction(
    async () => {
        const contracts = await helpers.getDeployedContracts();
        try {
            await deployers.crx.verify(contracts.crx);
        } catch (error) {
            console.error(error);
        }

        try {
            await deployers.mastermind.verify(contracts.mastermind);
        } catch (error) {
            console.error(error);
        }

        try {
            await deployers.rf.verify(contracts.rf);
        } catch (error) {
            console.error(error);
        }

        try {
            await deployers.dex.verify(
                contracts.weth9,
                contracts.factory,
                contracts.router
            );
        } catch (error) {
            console.error(error);
        }

        try {
            await deployers.multicall.verify(contracts.multicall);
        } catch (error) {
            console.error(error);
        }

        try {
            await deployers.scientist.verify(
                contracts.scientist,
                contracts.factory,
                contracts.rf,
                contracts.crx,
                contracts.weth9
            );
        } catch (error) {
            console.error(error);
        }
    }
);
