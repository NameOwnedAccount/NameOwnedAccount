const { expect } = require("chai");
const { ethers } = hre = require("hardhat");
const { deploy, genNode, genName, getDeployment } = require("./test_helper.js");

const genAddress = (name, ns) => {
    const addressOfNameHash = ethers.utils.keccak256(
        ethers.utils.toUtf8Bytes("addressOfName(bytes name)")
    );
    const raw = ethers.utils.concat([
        0xff,
        ns,
        genNode(name),
        addressOfNameHash
    ]);
    const hash = ethers.utils.keccak256(raw);
    return ethers.utils.getAddress(
        ethers.utils.hexlify(
            ethers.utils.arrayify(hash).slice(12)
        )
    );
};

const node = genNode('alice');

describe("NOA", function () {
    var admin, test;
    var uns, cns, erc20noa;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;

        await hre.deployments.fixture(['NameService']);
        uns = await getDeployment('UniversalNameService');
        cns = await getDeployment('CustodialNameService');
        erc20noa = await deploy(admin, 'ERC20NOA', ['TestToken', 'TT']);
    });

    it("addressOfName", async function() {
        let name = genName('alice', uns.address);
        expect(
            await erc20noa.addressOfName(name)
        ).to.equal(genAddress('alice', uns.address));

        name = genName('alice', cns.address);
        expect(
            await erc20noa.addressOfName(name)
        ).to.equal(genAddress('alice', cns.address));
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
});
