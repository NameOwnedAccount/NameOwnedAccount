// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface INOA {
    function addressOfName(bytes memory name) external returns(address);

    function isNameOwner(bytes memory name, address owner) external returns(bool);
}
