const { expect } = require("chai");
const { ethers } = hre = require("hardhat");
const { genNode, getDeployment } = require("./test_helper.js");

const node = genNode('alice');

describe("NameService", function () {
    var admin, test;
    var uns, cns;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;

        await hre.deployments.fixture(['NameService']);
        uns = await getDeployment('UniversalNameService');
        cns = await getDeployment('CustodialNameService');
    });

    it("cns", async function() {
        await expect(
            cns.connect(test).setOwner(node, test.address)
        ).to.be.revertedWith(
            'CustodialNameService: not name owner'
        );

        await expect(
            cns.connect(test).setOwner(node, ethers.constants.AddressZero)
        ).to.be.revertedWith(
            'CustodialNameService: new owner is zero address'
        );

        await expect(
            cns.connect(admin).setOwner(node, test.address)
        ).to.emit(cns, 'OwnershipTransfer').withArgs(
            node, admin.address, test.address
        );

        await expect(
            cns.connect(admin).setOwner(node, admin.address)
        ).to.be.revertedWith(
            'CustodialNameService: not name owner'
        );

        await expect(
            cns.connect(test).setOwner(node, admin.address)
        ).to.emit(cns, 'OwnershipTransfer').withArgs(
            node, test.address, admin.address
        );
    });

    it("uns", async function() {
        await expect(
            uns.connect(test).setOwner(node, ethers.constants.AddressZero)
        ).to.be.revertedWith(
            'UniversalNameService: new owner is zero address'
        );

        await expect(
            uns.connect(test).setOwner(node, test.address)
        ).to.emit(uns, 'OwnershipTransfer').withArgs(
            node, ethers.constants.AddressZero, test.address
        );

        await expect(
            uns.connect(admin).setOwner(node, test.address)
        ).to.be.revertedWith(
            'UniversalNameService: not name owner'
        );

        await expect(
            uns.connect(test).setOwner(node, admin.address)
        ).to.emit(uns, 'OwnershipTransfer').withArgs(
            node, test.address, admin.address
        );
    });
});
