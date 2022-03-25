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
const AddressZero = hashAddress(ethers.constants.AddressZero);

describe("ERC20", function () {
    var admin, test, hashedAdmin, hashedTest;
    var service, bridge23;

    beforeEach(async function() {
        const signers = await ethers.getNamedSigners();
        admin = signers.admin;
        test = signers.test;
        hashedAdmin = hashAddress(admin.address);
        hashedTest = hashAddress(test.address);

        await hre.deployments.fixture(['UniversalNameService', 'Bridge23']);
        let deployment = await hre.deployments.get('UniversalNameService');
        service = await ethers.getContractAt(
            'UniversalNameService',
            deployment.address
        );

        deployment = await hre.deployments.get('Bridge23');
        bridge23 = await ethers.getContractAt('Bridge23', deployment.address);
    });

    it("metadata", async function() {
        expect(await bridge23.nameService()).to.equal(service.address);
        expect(await bridge23.name()).to.equal("Bridge23");
        expect(await bridge23.symbol()).to.equal("B23");
        expect(await bridge23.decimals()).to.equal(18);
    });

    it("mint", async function() {
        const amount = base.mul(1000);

        await expect(
            bridge23.mint(AddressZero, amount)
        ).to.be.revertedWith("ERC20: mint to the zero address");

        // address
        await expect(
            bridge23.mint(hashedAdmin, amount)
        ).to.emit(bridge23, 'TransferV2').withArgs(
            AddressZero, hashedAdmin, amount
        );
        expect(await bridge23.totalSupply()).to.equal(amount);
        expect(await bridge23.totalSupplyV2()).to.equal(amount);

        expect(await bridge23.balanceOf(admin.address)).to.equal(amount);
        expect(await bridge23.balanceOfV2(hashedAdmin)).to.equal(amount);

        // username
        const name = hashString('b23');
        await expect(
            bridge23.mint(name, amount)
        ).to.emit(bridge23, 'TransferV2').withArgs(
            AddressZero, name, amount
        );

        expect(await bridge23.totalSupplyV2()).to.equal(amount.mul(2));
        expect(await bridge23.balanceOfV2(name)).to.equal(amount);

        // capped
        await expect(
            bridge23.mint(name, base.mul(10000000))
        ).to.be.revertedWith("ERC20Capped: cap exceeded");
    });

    it("authentication", async function() {
        const name1 = hashString('b23');
        const name2 = hashString('b32');
        await service.register('b23', hashedAdmin);
        await service.register('b32', name1);

        const amount = base.mul(1000).div(2);
        await expect(
            bridge23.connect(test).transferV2(name1, name2, amount)
        ).to.be.revertedWith('ERC20: unauthorized operator');

        await expect(
            bridge23.connect(test).transferV2(name2, hashedAdmin, amount)
        ).to.be.revertedWith('ERC20: unauthorized operator');

        await expect(
            bridge23.connect(admin).transferV2(hashedTest, name2, amount)
        ).to.be.revertedWith('ERC20: unauthorized operator');

        await expect(
            bridge23.connect(test).transferV2(hashedAdmin, name2, amount)
        ).to.be.revertedWith('ERC20: unauthorized operator');
    });

    it("transfer", async function() {
        // mint
        const amount = base.mul(1000);
        await bridge23.mint(hashedAdmin, amount);
        const name1 = hashString('b23');
        const name2 = hashString('b32');
        await bridge23.mint(name1, amount);

        await service.register('b23', hashedAdmin);
        await service.register('b32', name1);

        // address to address
        const toTransfer = amount.div(2);
        await expect(
            bridge23.connect(admin).transfer(test.address, amount.mul(2))
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

        await expect(
            bridge23.connect(admin).transfer(test.address, toTransfer)
        ).to.emit(bridge23, 'TransferV2').withArgs(
            hashedAdmin, hashedTest, toTransfer
        );
        expect(await bridge23.balanceOf(test.address)).to.equal(toTransfer);
        expect(await bridge23.balanceOfV2(hashedTest)).to.equal(toTransfer);
        expect(await bridge23.balanceOf(admin.address)).to.equal(amount.sub(toTransfer));
        expect(await bridge23.balanceOfV2(hashedAdmin)).to.equal(amount.sub(toTransfer));

        // username to username
        await expect(
            bridge23.connect(admin).transferV2(name1, name2, amount.mul(2))
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

        await expect(
            bridge23.connect(admin).transferV2(name1, name2, toTransfer)
        ).to.emit(bridge23, 'TransferV2').withArgs(
            name1, name2, toTransfer
        );
        expect(await bridge23.balanceOfV2(name2)).to.equal(toTransfer);
        expect(await bridge23.balanceOfV2(name1)).to.equal(amount.sub(toTransfer));

        // username to address
        await expect(
            bridge23.connect(admin).transferV2(name2, hashedAdmin, amount.mul(2))
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

        await expect(
            bridge23.connect(admin).transferV2(name2, hashedAdmin, toTransfer)
        ).to.emit(bridge23, 'TransferV2').withArgs(
            name2, hashedAdmin, toTransfer
        );
        expect(await bridge23.balanceOfV2(name2)).to.equal(0);
        expect(await bridge23.balanceOfV2(hashedAdmin)).to.equal(amount);

        // address to username
        await expect(
            bridge23.connect(test).transferV2(hashedTest, name2, amount.mul(2))
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

        await expect(
            bridge23.connect(test).transferV2(hashedTest, name2, toTransfer)
        ).to.emit(bridge23, 'TransferV2').withArgs(
            hashedTest, name2, toTransfer
        );
        expect(await bridge23.balanceOfV2(name2)).to.equal(toTransfer);
        expect(await bridge23.balanceOfV2(hashedTest)).to.equal(0);
    });

    it("approve and allowance", async function() {
        // mint
        const allowance = base.mul(1000);
        const name1 = hashString('b23');
        const name2 = hashString('b32');
        await service.register('b23', hashedAdmin);
        await service.register('b32', name1);

        // exceptions
        await expect(
            bridge23.connect(admin).approve(ethers.constants.AddressZero, allowance)
        ).to.be.revertedWith("ERC20: approve to the zero address");

        await expect(
            bridge23.connect(admin).approveV2(hashedAdmin, AddressZero, allowance)
        ).to.be.revertedWith("ERC20: approve to the zero address");

        // approve
        expect(
            await bridge23.allowance(admin.address, test.address)
        ).to.equal(0);
        await expect(
            bridge23.connect(admin).approve(test.address, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            hashedAdmin, hashedTest, allowance
        );
        expect(
            await bridge23.allowance(admin.address, test.address)
        ).to.equal(allowance);

        // approveV2: name -> name
        expect(await bridge23.allowanceV2(name1, name2)).to.equal(0);
        await expect(
            bridge23.connect(admin).approveV2(name1, name2, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            name1, name2, allowance
        );
        expect(await bridge23.allowanceV2(name1, name2)).to.equal(allowance);

        // approveV2: name -> address
        expect(await bridge23.allowanceV2(name1, hashedTest)).to.equal(0);
        await expect(
            bridge23.connect(admin).approveV2(name1, hashedTest, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            name1, hashedTest, allowance
        );
        expect(await bridge23.allowanceV2(name1, hashedTest)).to.equal(allowance);

        // approveV2: address -> name
        expect(await bridge23.allowanceV2(hashedAdmin, name2)).to.equal(0);
        await expect(
            bridge23.connect(admin).approveV2(hashedAdmin, name2, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            hashedAdmin, name2, allowance
        );
        expect(await bridge23.allowanceV2(hashedAdmin, name2)).to.equal(allowance);
    });

    it("increase and decrease allowance", async function() {
        // mint
        const allowance = base.mul(1000);
        const name1 = hashString('b23');
        const name2 = hashString('b32');
        await service.register('b23', hashedAdmin);
        await service.register('b32', name1);

        // increase/decrease allowance: address -> address
        expect(
            await bridge23.allowance(admin.address, test.address)
        ).to.equal(0);
        await expect(
            bridge23.connect(admin).increaseAllowance(test.address, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            hashedAdmin, hashedTest, allowance
        );
        expect(
            await bridge23.allowance(admin.address, test.address)
        ).to.equal(allowance);
        await expect(
            bridge23.connect(admin).decreaseAllowance(test.address, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            hashedAdmin, hashedTest, 0
        );
        expect(
            await bridge23.allowance(admin.address, test.address)
        ).to.equal(0);

        await expect(
            bridge23.connect(admin).decreaseAllowance(test.address, allowance)
        ).to.be.revertedWith("ERC20: decreased allowance below zero");

        // increase/decrease allowance: name -> name
        expect(await bridge23.allowanceV2(name1, name2)).to.equal(0);
        await expect(
            bridge23.connect(admin).increaseAllowanceV2(name1, name2, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            name1, name2, allowance
        );
        expect(await bridge23.allowanceV2(name1, name2)).to.equal(allowance);
        await expect(
            bridge23.connect(admin).decreaseAllowanceV2(name1, name2, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            name1, name2, 0
        );
        expect(await bridge23.allowanceV2(name1, name2)).to.equal(0);

        await expect(
            bridge23.connect(admin).decreaseAllowanceV2(name1, name2, allowance)
        ).to.be.revertedWith("ERC20: decreased allowance below zero");

        // increase/decrease allowance: name -> address
        expect(await bridge23.allowanceV2(name1, hashedTest)).to.equal(0);
        await expect(
            bridge23.connect(admin).increaseAllowanceV2(name1, hashedTest, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            name1, hashedTest, allowance
        );
        expect(await bridge23.allowanceV2(name1, hashedTest)).to.equal(allowance);
        await expect(
            bridge23.connect(admin).decreaseAllowanceV2(name1, hashedTest, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            name1, hashedTest, 0
        );
        expect(await bridge23.allowanceV2(name1, hashedTest)).to.equal(0);

        await expect(
            bridge23.connect(admin).decreaseAllowanceV2(name1, hashedTest, allowance)
        ).to.be.revertedWith("ERC20: decreased allowance below zero");

        // increase/decrease allowance: address -> name
        expect(await bridge23.allowanceV2(hashedAdmin, name2)).to.equal(0);
        await expect(
            bridge23.connect(admin).increaseAllowanceV2(hashedAdmin, name2, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            hashedAdmin, name2, allowance
        );
        expect(await bridge23.allowanceV2(hashedAdmin, name2)).to.equal(allowance);
        await expect(
            bridge23.connect(admin).decreaseAllowanceV2(hashedAdmin, name2, allowance)
        ).to.emit(bridge23, 'ApprovalV2').withArgs(
            hashedAdmin, name2, 0
        );
        expect(await bridge23.allowanceV2(hashedAdmin, name2)).to.equal(0);

        await expect(
            bridge23.connect(admin).decreaseAllowanceV2(hashedAdmin, name2, allowance)
        ).to.be.revertedWith("ERC20: decreased allowance below zero");
    });

    it("transferFrom", async function() {
        // mint
        const amount = base.mul(1000);
        const allowance = amount.div(2);

        const name1 = hashString('b23');
        const name2 = hashString('b32');
        await service.register('b23', hashedAdmin);
        await service.register('b32', name1);

        await bridge23.mint(hashedAdmin, amount);
        await bridge23.mint(hashedTest, amount);
        await bridge23.mint(name1, amount);
        await bridge23.mint(name2, amount);

        // increase/decrease allowance: address -> address
        await bridge23.connect(admin).increaseAllowance(test.address, allowance);

        // increase/decrease allowance: name -> name
        await bridge23.connect(admin).increaseAllowanceV2(name1, name2, allowance);

        // transferFromV2: name -> address
        await bridge23.connect(admin).increaseAllowanceV2(name1, hashedTest, allowance);

        // transferFromV2: address -> name
        await bridge23.connect(admin).increaseAllowanceV2(hashedAdmin, name2, allowance);
    });
});
