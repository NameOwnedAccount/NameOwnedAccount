// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface INameService {
    event OwnershipTransfer(
        bytes32 indexed node,
        address indexed oldOwner,
        address indexed newOwner
    );

    function setOwner(bytes32 node, address newOwner) external;

    function owner(bytes32 node) external view returns(address);
}
