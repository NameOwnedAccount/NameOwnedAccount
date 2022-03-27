const { ethers } = hre = require("hardhat");

async function main() {
    console.log(await ethers.utils.defaultAbiCoder.encode(['string'], ['1']));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
