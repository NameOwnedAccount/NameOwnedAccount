// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface INOA {
    function addressOf(bytes memory name) external returns(address);

    function isOwner(bytes memory name, address owner) external returns(bool);
}
