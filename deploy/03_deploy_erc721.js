module.exports = async ({ ethers, deployments, localConfig } = hre) => {
    const admin = await ethers.getNamedSigner('admin');
    const deployment = await deployments.deploy('ERC721NOATest', {
        from: admin.address,
        args: ['ERC721NOATest', 'ENT721'],
        log: true
    });
};

module.exports.tags = ['ERC721'];
