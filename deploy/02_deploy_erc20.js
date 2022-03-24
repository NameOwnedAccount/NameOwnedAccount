const { admin } = require('../lib/utils.js');
const assert = require('assert');

module.exports = async ({ ethers, deployments, localConfig } = hre) => {
    const owner = await admin(hre);
    const identityService = await hre.deployments.getOrNull(
        'UniversalNameService'
    );
    assert(identityService !== undefined);

    const deployment = await deployments.deploy('Bridge23', {
        from: owner.signer.address,
        args: [
            'Bridge23',
            'B23',
            identityService.address,
            ethers.BigNumber.from(10).pow(18).mul(10000000)
        ],
        log: true
    });

    if (owner.address != owner.signer.address) {
        const bridge23 = await ethers.getContractAt(
            'Bridge23',
            deployment.address
        );
        await bridge23.transferOwnership(owner.address);
    }
};

module.exports.tags = ['Bridge23'];
