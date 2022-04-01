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
    return ethers.utils.keccak256(
        ethers.utils.concat(
            [0xff],
            ethers.utils.arrayify(ethers.constants.AddressZero),
            ethers.utils.arrayify(decoded[1]),
            ethers.utils.arrayify(genNode(decoded[0]))
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
