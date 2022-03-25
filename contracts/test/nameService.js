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

const name = 'bridge23';
const id = hashString(name);

describe("UniversalNameService", function () {
    var admin, test, hashedAdmin, hashedTest;
    var service;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;
        hashedAdmin = hashAddress(admin.address);
        hashedTest = hashAddress(test.address);

        await hre.deployments.fixture(['UniversalNameService']);
        const deployment = await hre.deployments.get('UniversalNameService');
        service = await ethers.getContractAt(
            'UniversalNameService',
            deployment.address
        );
    });

    it("register", async function() {
        await expect(
            service.connect(test).register(name, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');

        await expect(
            service.connect(admin).register(name, hashedAdmin)
        ).to.emit(service, 'Register').withArgs(
            id, hashedAdmin, name
        );

        expect(await service.name(id)).to.equal(name);
        expect(await service.owner(id)).to.equal(hashedAdmin);

        await expect(
            service.register(name, hashedAdmin)
        ).to.be.revertedWith('IdentityService: already registered');
    });

    it("register chinese", async function() {
        const name = "23号桥";
        await service.connect(admin).register(name, hashedAdmin)
        const id = hashString(name);
        expect(await service.name(id)).to.equal(name);
        expect(await service.owner(id)).to.equal(hashedAdmin);
    });

    it("authenticate", async function() {
        // hash of address
        expect(await service.authenticate(hashedTest, hashedTest)).to.be.true;
        expect(await service.authenticate(hashedAdmin, hashedAdmin)).to.be.true;

        // hash of string
        await service.register(name, hashedAdmin);
        expect(await service.authenticate(id, hashedAdmin)).to.be.true;
        expect(await service.authenticate(id, hashedTest)).to.be.false;

        const name2 = "proxy";
        const id2 = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['string'], ['proxy'])
        );
        await service.register(name2, id);
        expect(await service.authenticate(id2, hashedAdmin)).to.be.true;
        expect(await service.authenticate(id2, hashedTest)).to.be.false;
    });

    it("set owner", async function() {
        // set owner of address hash should fail
        await expect(
            service.connect(admin).setOwner(hashedAdmin, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');

        // set owner of not registered name should fail
        await expect(
            service.connect(admin).setOwner(id, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');

        // set owner id2 -> id -> admin.address
        const name2 = "name2";
        const id2 = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['string'], [name2])
        );
        await service.connect(admin).register(name, hashedAdmin);
        await service.connect(admin).register(name2, id);
        expect(await service.authenticate(id, hashedAdmin)).to.be.true;
        expect(await service.authenticate(id2, id)).to.be.true;
        expect(await service.authenticate(id2, hashedAdmin)).to.be.true;

        // set owner of not owned name should fail
        await expect(
            service.connect(test).setOwner(id, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');
        await expect(
            service.connect(test).setOwner(id2, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');

        // set owner of owned name should success
        await expect(
            service.connect(admin).setOwner(id, hashedTest)
        ).to.emit(service, 'SetOwner').withArgs(
            id, hashedAdmin, hashedTest
        );
        expect(await service.authenticate(id, hashedTest)).to.be.true;
        expect(await service.authenticate(id2, hashedTest)).to.be.true;

        // circular dependency should fail: id -> id2 -> id
        await expect(
            service.connect(test).setOwner(id, id2)
        ).to.be.revertedWith('IdentityService: circular dependency');

        // set owner of id should success
        await expect(
            service.connect(test).setOwner(id2, hashedAdmin)
        ).to.emit(service, 'SetOwner').withArgs(
            id2, id, hashedAdmin
        );
        expect(await service.authenticate(id2, hashedTest)).to.be.false;
        expect(await service.authenticate(id2, hashedAdmin)).to.be.true;
        expect(await service.authenticate(id2, id)).to.be.false;
    });
});
