const { expect } = require("chai");
const { ethers } = hre = require("hardhat");

const name = 'bridge23';
const id = ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(['string'], [name])
);

const hashAddress = function(address) {
    return ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(['address'], [address])
    );
}

describe("UniversalNameService", function () {
    var admin, test;
    var service;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        test = signers.test;
        admin = signers.admin;

        await hre.deployments.fixture(['UniversalNameService']);
        const deployment = await hre.deployments.get('UniversalNameService');
        service = await ethers.getContractAt(
            'UniversalNameService',
            deployment.address
        );
    });

    it("register", async function() {
        await expect(
            service.register(name, admin.address)
        ).to.emit(service, 'Register').withArgs(
            id, admin.address, name
        );

        expect(await service.name(id)).to.equal(name);
        expect(await service.owner(id)).to.equal(admin.address);

        await expect(
            service.register(name, admin.address)
        ).to.be.revertedWith('IdentityService: already registered');
    });

    it("authenticate", async function() {
        // hash of address
        const testId = hashAddress(test.address);
        expect(await service.authenticate(testId, test.address)).to.be.true;
        const adminId = hashAddress(admin.address);
        expect(await service.authenticate(adminId, admin.address)).to.be.true;

        // hash of string
        await service.register(name, admin.address);
        expect(await service.authenticate(id, admin.address)).to.be.true;
        expect(await service.authenticate(id, test.address)).to.be.false;
    });

    it("set owner", async function() {
        // set owner of address hash should fail
        const adminId = hashAddress(admin.address);
        await expect(
            service.connect(admin).setOwner(adminId, admin.address)
        ).to.be.revertedWith('IdentityService: not authorized');

        // set owner of not registered name should fail
        await expect(
            service.connect(admin).setOwner(id, admin.address)
        ).to.be.revertedWith('IdentityService: not authorized');

        await service.register(name, admin.address);

        // set owner of not owned name should fail
        await expect(
            service.connect(test).setOwner(id, admin.address)
        ).to.be.revertedWith('IdentityService: not authorized');

        // set owner of owned name should success
        await expect(
            service.connect(admin).setOwner(id, test.address)
        ).to.emit(service, 'SetOwner').withArgs(
            id, admin.address, test.address
        );
    });
});
