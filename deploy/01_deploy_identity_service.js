const { admin } = require('../lib/utils.js');

module.exports = async ({ ethers, upgrades, localConfig } = hre) => {
    const owner = await admin(hre);
    await deployments.deploy('IdentityService', {
        from: owner.signer.address,
        args: [],
        log: true
    });
};

module.exports.tags = ['IdentityService'];
