const {describe} = require("mocha");
const deployer = require("../deployers/deployers.js");

describe("Cycle Contract", () => {
    let decine, decineToken, decineLoyaltyToken, decineNFT;

    it("Should deploy the smart contracts", async () => {
        ({decine, decineToken, decineLoyaltyToken, decineNFT} =
            await deployer.decine.deploy());
    });
});
