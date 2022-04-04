module.exports = async ({ ethers, upgrades, localConfig } = hre) => {
    const admin = await ethers.getNamedSigner('admin');
    await deployments.deploy('UniversalNameService', {
        from: admin.address,
        args: [],
        log: true
    });

    await deployments.deploy('CustodialNameService', {
        from: admin.address,
        args: [admin.address],
        log: true
    });
};

module.exports.tags = ['NameService'];
