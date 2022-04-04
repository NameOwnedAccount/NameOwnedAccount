const { expect } = require("chai");
const { ethers } = hre = require("hardhat");
const {
    deploy,
    genNode,
    genAddress,
    genName,
    getDeployment
} = require("./test_helper.js");

const node = genNode('alice');

describe("NOA", function () {
    var admin, test;
    var uns, cns, erc20noa;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;

        await hre.deployments.fixture(['NameService', 'Bridge23']);
        uns = await getDeployment('UniversalNameService');
        cns = await getDeployment('CustodialNameService');
        erc20noa = await getDeployment('Bridge23');
    });

    it("addressOfName", async function() {
        let name = genName('alice', uns.address);
        expect(
            await erc20noa.addressOfName(name)
        ).to.equal(genAddress(name));

        name = genName('alice', cns.address);
        expect(
            await erc20noa.addressOfName(name)
        ).to.equal(genAddress(name));
    });

    it("isNameOwner", async function() {
        let name = genName('alice', uns.address);
        expect(await erc20noa.isNameOwner(name, admin.address)).to.be.false;
        expect(await erc20noa.isNameOwner(name, test.address)).to.be.false;
        await uns.setOwner(node, admin.address);
        expect(await erc20noa.isNameOwner(name, admin.address)).to.be.true;
        expect(await erc20noa.isNameOwner(name, test.address)).to.be.false;
        await uns.connect(admin).setOwner(node, test.address);
        expect(await erc20noa.isNameOwner(name, admin.address)).to.be.false;
        expect(await erc20noa.isNameOwner(name, test.address)).to.be.true;

        name = genName('alice', cns.address);
        expect(await erc20noa.isNameOwner(name, admin.address)).to.be.true;
        expect(await erc20noa.isNameOwner(name, test.address)).to.be.false;
        await cns.connect(admin).setOwner(node, test.address);
        expect(await erc20noa.isNameOwner(name, admin.address)).to.be.false;
        expect(await erc20noa.isNameOwner(name, test.address)).to.be.true;
    });

    it("erc20 metadata", async function() {
        expect(await erc20noa.name()).to.equal("Bridge23");
        expect(await erc20noa.symbol()).to.equal("B23");
        expect(await erc20noa.decimals()).to.equal(18);
    });

    it("transferFromName", async function() {
        const alice = genName('alice', cns.address);
        await cns.connect(admin).setOwner(genNode('alice'), test.address);

        // mint
        await erc20noa.connect(admin).mint(genAddress(alice), 10000);

        // transfer from name failed
        await expect(
            erc20noa.connect(admin).transferFromName(alice, test.address, 5000)
        ).to.be.revertedWith("NameOwnedAccount: caller is not owner");

        // transfer from name success
        await expect(
            erc20noa.connect(test).transferFromName(alice, test.address, 5000)
        ).to.emit(erc20noa, 'Transfer').withArgs(
            genAddress(alice), test.address, 5000
        );
    });

    it("approveName", async function() {
        const alice = genName('alice', cns.address);
        await cns.connect(admin).setOwner(genNode('alice'), test.address);

        // approve
        await expect(
            erc20noa.connect(admin).approveFromName(alice, test.address, 10000)
        ).to.be.revertedWith('NameOwnedAccount: caller is not owner');

        await expect(
            erc20noa.connect(test).approveFromName(alice, test.address, 10000)
        ).to.emit(erc20noa, 'Approval').withArgs(
            genAddress(alice), test.address, 10000
        );

        // decrease allowance failed
        await expect(
            erc20noa.connect(test).decreaseAllowanceFromName(alice, test.address, 100000)
        ).to.be.revertedWith(
            "ERC20: decreased allowance below zero"
        );

        await expect(
            erc20noa.connect(admin).decreaseAllowanceFromName(alice, test.address, 6000)
        ).to.be.revertedWith('NameOwnedAccount: caller is not owner');

        // decrease allowance success
        await expect(
            erc20noa.connect(test).decreaseAllowanceFromName(alice, test.address, 6000)
        ).to.emit(erc20noa, 'Approval').withArgs(
            genAddress(alice), test.address, 4000
        );

        // increase allowance
        await expect(
            erc20noa.connect(admin).increaseAllowanceFromName(alice, test.address, 3000)
        ).to.be.revertedWith('NameOwnedAccount: caller is not owner');

        await expect(
            erc20noa.connect(test).increaseAllowanceFromName(alice, test.address, 3000)
        ).to.emit(erc20noa, 'Approval').withArgs(
            genAddress(alice), test.address, 7000
        );
    });
});
