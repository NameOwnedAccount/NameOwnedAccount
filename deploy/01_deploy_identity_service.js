const { admin } = require('../lib/utils.js');

module.exports = async ({ ethers, upgrades, localConfig } = hre) => {
    const owner = await admin(hre);
    await deployments.deploy('UniversalNameService', {
        from: owner.signer.address,
        args: [],
        log: true
    });

    await deployments.deploy('CustodialNameService', {
        from: owner.signer.address,
        args: [owner.address],
        log: true
    });
};

module.exports.tags = ['NameService'];
