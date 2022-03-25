const { expect } = require("chai");
const { ethers } = hre = require("hardhat");

const hashString = function(str) {
    return ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(['string'], [str])
    );
}

const hashAddress = function(address) {
    return ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(['address'], [address])
    );
}

const base = ethers.BigNumber.from(10).pow(18);

describe("ERC20", function () {
    var admin, test, hashedAdmin, hashedTest;
    var bridge23;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;
        hashedAdmin = hashAddress(admin.address);
        hashedTest = hashAddress(test.address);

        await hre.deployments.fixture(['UniversalNameService', 'Bridge23']);
        const deployment = await hre.deployments.get('Bridge23');
        bridge23 = await ethers.getContractAt('Bridge23', deployment.address);
    });

    it("metadata", async function() {
        const deployment = await hre.deployments.get('UniversalNameService');
        expect(await bridge23.nameService()).to.equal(deployment.address);

        expect(await bridge23.name()).to.equal("Bridge23");
        expect(await bridge23.symbol()).to.equal("B23");
        expect(await bridge23.decimals()).to.equal(18);
    });

    it("mint", async function() {
        const amount = base.mul(1000);

        // legacy
        await bridge23.mint(hashedAdmin, amount);
        expect(await bridge23.totalSupplyV2()).to.equal(amount);

        expect(await bridge23.balanceOf(admin.address)).to.equal(amount);
        expect(await bridge23.balanceOfV2(hashedAdmin)).to.equal(amount);

        // new username
        const name = hashString('b23');
        await bridge23.mint(name, amount);
        expect(await bridge23.totalSupplyV2()).to.equal(amount.mul(2));
        expect(await bridge23.balanceOfV2(name)).to.equal(amount);

        await expect(
            bridge23.mint(name, base.mul(10000000))
        ).to.be.revertedWith("ERC20Capped: cap exceeded");
    });
});
