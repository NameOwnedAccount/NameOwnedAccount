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
    gnosisSafe: {
        api: {
            matic: 'https://safe-transaction.polygon.gnosis.io/',
        },
        admin: {
            matic: '0x75EbA51F874a186E1800Fe24eC0E824E2bb44bB9',
        }
    },
    enableGasReporter: true
};

module.exports = config;
