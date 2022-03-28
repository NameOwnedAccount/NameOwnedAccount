// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IERC20NDA {
    function addressOf(bytes memory name) external returns(address);

    function ownerOf(bytes memory name) external returns(address);

    function transfer(bytes memory from, address to, uint256 amount) external returns(bool);

    function approve(bytes memory, address spender, uint256 amount) external returns(bool);
}
