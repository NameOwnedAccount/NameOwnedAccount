require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-contract-sizer');
require('hardhat-gas-reporter');
require('hardhat-deploy');
require('hardhat-deploy-ethers');
require('@openzeppelin/hardhat-upgrades');

task('accounts', 'Prints the list of accounts')
    .setAction(async (_args, { ethers }) => {
        const signers = await ethers.getNamedSigners();
        for (const name of Object.keys(signers)) {
          formatted = (name + ": ").padEnd(15, " ");
          console.log(formatted + signers[name].address);
        }
    });

task('abi', 'Prints abi of contract')
    .addParam('contract', 'contract name')
    .addFlag('print', 'print abi')
    .setAction(async (args, { artifacts }) => {
        let artifact = await artifacts.readArtifact(args.contract);
        if (args.print) {
            console.log(JSON.stringify(artifact.abi));
        }
        return artifact.abi;
    });

task('id', 'get bytes32 id of abitrary string')
    .addParam('id', 'user id to encode')
    .addFlag('print', 'print abi')
    .setAction(async (args, { ethers }) => {
        const id = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(["string"], [args.id])
        )
        if (args.print) {
            console.log(JSON.stringify({source: args.id, encoded: id}));
        }
        return id;
    });

const config = require('./config');
extendEnvironment((hre) => {
    hre.localConfig = config;
    hre.shared = {};
});

module.exports = {
    solidity: {
      version: "0.8.4",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1,
        }
      }
    },
    networks: {
        matic: {
            live: true,
            url: config.alchemy.matic,
            chainId: 137,
            accounts: config.accounts
        },
        mumbai: {
            live: true,
            url: config.alchemy.mumbai,
            chainId: 80001,
            accounts: config.accounts
        },
    },
    etherscan: {
        apiKey: {
            polygon: config.scan.matic.key,
            polygonMumbai: config.scan.mumbai.key,
        }
    },
    namedAccounts: {
        admin: {
            default: 0
        },
        deployer: {
            default: 1
        },
        test: {
            default: 2
        }
    },
    gasReporter: {
        enabled: config.enableGasReporter,
        currency: 'USD',
        coinmarketcap: '1c5db8be-2272-42c9-8d48-51a072cdc5a1',
        gasPrice: 90
    },
    path: {
        deploy: 'deploy',
        deployments: 'deployments'
    }
};
