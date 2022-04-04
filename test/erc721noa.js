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
    var uns, cns, erc721noa;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;

        await hre.deployments.fixture(['NameService', 'Bridge23NFT']);
        uns = await getDeployment('UniversalNameService');
        cns = await getDeployment('CustodialNameService');
        erc721noa = await getDeployment('Bridge23NFT');
    });

    it("addressOfName", async function() {
        let name = genName('alice', uns.address);
        expect(
            await erc721noa.addressOfName(name)
        ).to.equal(genAddress(name));

        name = genName('alice', cns.address);
        expect(
            await erc721noa.addressOfName(name)
        ).to.equal(genAddress(name));
    });

    it("isNameOwner", async function() {
        let name = genName('alice', uns.address);
        expect(await erc721noa.isNameOwner(name, admin.address)).to.be.false;
        expect(await erc721noa.isNameOwner(name, test.address)).to.be.false;
        await uns.setOwner(node, admin.address);
        expect(await erc721noa.isNameOwner(name, admin.address)).to.be.true;
        expect(await erc721noa.isNameOwner(name, test.address)).to.be.false;
        await uns.connect(admin).setOwner(node, test.address);
        expect(await erc721noa.isNameOwner(name, admin.address)).to.be.false;
        expect(await erc721noa.isNameOwner(name, test.address)).to.be.true;

        name = genName('alice', cns.address);
        expect(await erc721noa.isNameOwner(name, admin.address)).to.be.true;
        expect(await erc721noa.isNameOwner(name, test.address)).to.be.false;
        await cns.connect(admin).setOwner(node, test.address);
        expect(await erc721noa.isNameOwner(name, admin.address)).to.be.false;
        expect(await erc721noa.isNameOwner(name, test.address)).to.be.true;
    });

    it("erc721 metadata", async function() {
        expect(await erc721noa.name()).to.equal("Bridge23NFT");
        expect(await erc721noa.symbol()).to.equal("B23NFT");
    });

    it("safeTransferFromName", async function() {
        const alice = genName('alice', cns.address);
        await cns.connect(admin).setOwner(genNode('alice'), test.address);
        await erc721noa.connect(admin).mint(genAddress(alice), 1);

        await expect(
            erc721noa.connect(admin)[
                'safeTransferFromName(bytes,address,uint256)'
            ](alice, admin.address, 1)
        ).to.be.revertedWith(
            "NameOwnedAccount: caller is not owner"
        );

        await expect(
            erc721noa.connect(test)[
                'safeTransferFromName(bytes,address,uint256)'
            ](alice, admin.address, 1)
        ).to.emit(erc721noa, 'Transfer').withArgs(
            genAddress(alice), admin.address, 1
        );
    });

    it("approveFromName", async function() {
        const alice = genName('alice', cns.address);
        await cns.connect(admin).setOwner(genNode('alice'), test.address);
        await erc721noa.connect(admin).mint(genAddress(alice), 1);

        await expect(
            erc721noa.connect(admin).approveFromName(alice, admin.address, 1)
        ).to.be.revertedWith(
            "NameOwnedAccount: caller is not owner"
        );

        await expect(
            erc721noa.connect(test).approveFromName(alice, admin.address, 1)
        ).to.emit(erc721noa, 'Approval').withArgs(
            genAddress(alice), admin.address, 1
        );

        expect(await erc721noa.getApproved(1)).to.equal(admin.address);
    });

    it("setApprovalForAllFromName", async function() {
        const alice = genName('alice', cns.address);
        await cns.connect(admin).setOwner(genNode('alice'), test.address);
        await erc721noa.connect(admin).mint(genAddress(alice), 1);

        await expect(
            erc721noa.connect(admin).setApprovalForAllFromName(alice, admin.address, true)
        ).to.be.revertedWith(
            "NameOwnedAccount: caller is not owner"
        );

        await expect(
            erc721noa.connect(test).setApprovalForAllFromName(alice, admin.address, true)
        ).to.emit(erc721noa, 'ApprovalForAll').withArgs(
            genAddress(alice), admin.address, true
        );

        expect(
            await erc721noa.isApprovedForAll(genAddress(alice), admin.address)
        ).to.be.true;
    });
});
