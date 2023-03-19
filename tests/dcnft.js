const {describe} = require("mocha");
const {expect} = require("chai");
const {ethers} = require("hardhat");
const deployer = require("../deployers/deployers.js");

describe("DeCine NFT Contract", () => {
    let owner, user, protocol, protocol2;
    let decineNFT;

    before(async () => {
        [owner, user, protocol, protocol2] = await ethers.getSigners();
    });

    it("Should deploy the smart contracts", async () => {
        ({decineNFT} =
            await deployer.decine.deploy());
    });

    it("Should not allow users other than the owner to add an authorized operator", async () => {
        await expect(decineNFT.connect(user).setAuthorizedOperator(user.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should allow owner to add an authorized operator", async () => {
        await expect(decineNFT.connect(owner).setAuthorizedOperator(owner.address)).not.to.be.reverted;
    });

    it("Should not allow unauthorized operators to add an authorized protocol", async () => {
        await expect(decineNFT.connect(user).setAuthorizedProtocol(user.address)).to.be.revertedWith("NOT_AUTHORIZED_OPERATOR");
    });

    it("Should allow the authorized operator to add an authorized protocol", async () => {
        await expect(decineNFT.connect(owner).setAuthorizedProtocol(protocol.address)).not.to.be.reverted;
        await expect(decineNFT.connect(owner).setAuthorizedProtocol(protocol2.address)).not.to.be.reverted;
    });

    it("Should allow authorized protocols to mint NFTs", async () => {
        await expect(decineNFT.connect(protocol).safeMint(user.address)).not.to.be.reverted;
        expect(await decineNFT.balanceOf(user.address)).to.equal(1);
        await expect(decineNFT.connect(protocol2).safeMint(user.address)).not.to.be.reverted;
        expect(await decineNFT.balanceOf(user.address)).to.equal(2);
    });

    it("Should correctly generate user NFT metadata", async () => {
        const tokenURI = await decineNFT.tokenURI(1);
        console.log(tokenURI);
        const metadata = JSON.parse(Buffer.from(tokenURI.split(",")[1], "base64").toString());
        console.log(metadata);
        const svg = metadata.image;
        console.log(Buffer.from(svg.split(",")[1], "base64").toString());
    });

    it("Should not allow unauthorized protocols to update user ratings", async () => {
        await expect(decineNFT.connect(user).updateNftAttributes(1, 3)).to.be.revertedWith("NOT_AUTHORIZED");
    });

    it("Should not allow authorizes protocols to update user ratings of other protocols", async () => {
        await expect(decineNFT.connect(user).updateNftAttributes(2, 5)).to.be.revertedWith("NOT_AUTHORIZED");
    });

    it("Should allow authorized protocols to update user ratings", async () => {
        await expect(decineNFT.connect(protocol).updateNftAttributes(1, 3)).not.to.be.reverted;
    });

    it("Should correctly generate user NFT metadata", async () => {
        const tokenURI = await decineNFT.tokenURI(1);
        console.log(tokenURI);
        const metadata = JSON.parse(Buffer.from(tokenURI.split(",")[1], "base64").toString());
        console.log(metadata);
        const svg = metadata.image;
        console.log(Buffer.from(svg.split(",")[1], "base64").toString());
    });
});
