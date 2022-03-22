require('dotenv').config();
const fs = require('fs');
const path = require('path');
const BigNumber = require('bignumber.js');

const config = {
    accounts: [
        process.env.ADMIN,
        process.env.DEPLOYER,
        process.env.TEST,
    ],
    alchemy: {
        matic: process.env.ALCHEMY_MATIC,
        mumbai: process.env.ALCHEMY_MUMBAI,
    },
    scan: {
        matic: {
            api: "https://api.polygonscan.com/api",
            key: process.env.POLY_SCAN_KEY,
        },
        mumbai: {
            api: "https://api-testnet.polygonscan.com/api",
            key: process.env.POLY_SCAN_KEY,
        },
    },
    enableGasReporter: true
};

module.exports = config;
