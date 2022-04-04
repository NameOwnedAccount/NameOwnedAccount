const { ethers } = hre = require("hardhat");

const deploy = async (admin, name, args) => {
    const deployment = await hre.deployments.deploy(
        name,
        {
            from: admin.address,
            args: args,
            log: true
        }
    );
    return await ethers.getContractAt(name, deployment.address);
};

const genName = (name, nameService) => {
    return ethers.utils.defaultAbiCoder.encode(
        ['string', 'address'],
        [name, nameService]
    );
};

const genAddress = (encoded) => {
    const decoded = ethers.utils.defaultAbiCoder.decode(
        ['string', 'address'],
        encoded
    );
    const addressOfNameHash = ethers.utils.keccak256(
        ethers.utils.toUtf8Bytes("eip4972.addressOfName")
    );
    const raw = ethers.utils.concat([
        0xff,
        addressOfNameHash,
        decoded[1],
        genNode(decoded[0])
    ]);
    const hash = ethers.utils.keccak256(raw);
    return ethers.utils.getAddress(
        ethers.utils.hexlify(
            ethers.utils.arrayify(hash).slice(12)
        )
    );
};

const genNode = (name) => {
    return ethers.utils.keccak256(ethers.utils.toUtf8Bytes(name));
};

async function getDeployment(name) {
    var deployment = await hre.deployments.get(name);
    return await hre.ethers.getContractAt(name, deployment.address);
}

module.exports = {
    deploy,
    genName,
    genAddress,
    genNode,
    getDeployment,
}
