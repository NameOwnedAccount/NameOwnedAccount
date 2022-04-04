module.exports = async ({ ethers, deployments, localConfig } = hre) => {
    const admin = await ethers.getNamedSigner('admin');
    const deployment = await deployments.deploy('ERC20NOATest', {
        from: admin.address,
        args: [
            'ERC20NOATest',
            'ENT20',
            ethers.BigNumber.from(10).pow(18).mul(10000000)
        ],
        log: true
    });
};

module.exports.tags = ['ERC20'];
