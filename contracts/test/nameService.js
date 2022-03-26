const { expect } = require("chai");
const { ethers } = hre = require("hardhat");

const hashString = function(str) {
    return ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(['string'], [str])
    );
};

const hashAddress = function(address) {
    return ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(['address'], [address])
    );
};

const name = 'bridge23';
const id = hashString(name);

describe("UniversalNameService", function () {
    var admin, test, hashedAdmin, hashedTest;
    var service, authenticator;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;
        hashedAdmin = hashAddress(admin.address);
        hashedTest = hashAddress(test.address);

        await hre.deployments.fixture(['UniversalNameService']);
        const deployment1 = await hre.deployments.get('UniversalNameService');
        service = await ethers.getContractAt(
            'UniversalNameService',
            deployment1.address
        );

        const deployment2 = await hre.deployments.deploy(
            "Authenticator",
            {
                from: admin.address,
                args: [service.address],
                log: true
            }
        );
        authenticator = await ethers.getContractAt(
            'Authenticator',
            deployment2.address
        );
    });

    it("metadata", async function() {
        await expect(
            service.connect(admin).setOwner(name, hashedAdmin)
        ).to.emit(service, 'OwnerUpdated').withArgs(
            id, ethers.constants.HashZero, hashedAdmin
        );
        expect(await service.owner(id)).to.equal(hashedAdmin);

        const name2 = "23号桥";
        await service.connect(admin).setOwner(name2, hashedAdmin)
        const id2 = hashString(name2);
        expect(await service.owner(id2)).to.equal(hashedAdmin);
    });

    it("authenticator", async function() {
        expect(await authenticator.nameService()).to.equal(service.address);

        // hash of address
        expect(await authenticator.authenticate(hashedTest, hashedTest)).to.be.true;
        expect(await authenticator.authenticate(hashedAdmin, hashedAdmin)).to.be.true;

        // hash of string
        await service.setOwner(name, hashedAdmin);
        expect(await authenticator.authenticate(id, hashedAdmin)).to.be.true;
        expect(await authenticator.authenticate(id, hashedTest)).to.be.false;

        const name2 = "proxy";
        const id2 = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['string'], ['proxy'])
        );
        await service.setOwner(name2, id);
        expect(await authenticator.authenticate(id2, hashedAdmin)).to.be.true;
        expect(await authenticator.authenticate(id2, hashedTest)).to.be.false;
    });

    it("set owner", async function() {
        // set owner id2 -> id -> admin.address
        const name2 = "name2";
        const id2 = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['string'], [name2])
        );
        await service.setOwner(name, hashedAdmin);
        await service.setOwner(name2, id);
        expect(await authenticator.authenticate(id, hashedAdmin)).to.be.true;
        expect(await authenticator.authenticate(id2, id)).to.be.true;
        expect(await authenticator.authenticate(id2, hashedAdmin)).to.be.true;

        // set owner of not owned name should fail
        await expect(
            service.connect(test).setOwner(name, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');
        await expect(
            service.connect(test).setOwner(name2, hashedAdmin)
        ).to.be.revertedWith('IdentityService: not authorized');

        // set owner of owned name should success
        await expect(
            service.connect(admin).setOwner(name, hashedTest)
        ).to.emit(service, 'OwnerUpdated').withArgs(
            id, hashedAdmin, hashedTest
        );
        expect(await authenticator.authenticate(id, hashedTest)).to.be.true;
        expect(await authenticator.authenticate(id2, hashedTest)).to.be.true;

        // circular dependency should fail: id -> id2 -> id
        await expect(
            service.connect(test).setOwner(name, id2)
        ).to.be.revertedWith('IdentityService: circular dependency');

        // set owner of id should success
        await expect(
            service.connect(test).setOwner(name2, hashedAdmin)
        ).to.emit(service, 'OwnerUpdated').withArgs(
            id2, id, hashedAdmin
        );
        expect(await authenticator.authenticate(id2, hashedTest)).to.be.false;
        expect(await authenticator.authenticate(id2, hashedAdmin)).to.be.true;
        expect(await authenticator.authenticate(id2, id)).to.be.false;
    });
});
