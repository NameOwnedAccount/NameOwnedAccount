const { admin } = require('../lib/utils.js');
const assert = require('assert');

module.exports = async ({ ethers, deployments, localConfig } = hre) => {
    const owner = await admin(hre);
    const deployment = await deployments.deploy('Bridge23NFT', {
        from: owner.signer.address,
        args: ['Bridge23NFT', 'B23NFT'],
        log: true
    });

    if (owner.address != owner.signer.address) {
        const bridge23 = await ethers.getContractAt(
            'Bridge23NFT',
            deployment.address
        );
        await bridge23.transferOwnership(owner.address);
    }
};

module.exports.tags = ['Bridge23NFT'];
