async function admin(hre) {
    const signers = await hre.ethers.getNamedSigners();
    const admin = hre.localConfig.gnosisSafe.admin[hre.network.name];
    if (admin) {
        return {
            address: admin,
            signer: signers.admin,
            type: 'GNOSIS'
        };
    }
    return {
        address: signers.admin.address,
        signer: signers.admin,
        type: 'EOA'
    };
}

module.exports = { admin }
