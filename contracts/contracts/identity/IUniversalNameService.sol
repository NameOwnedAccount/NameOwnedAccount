// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IUniversalNameService {
    event OwnerUpdated(
        bytes32 indexed id,
        bytes32 indexed oldOwner,
        bytes32 indexed newOwner
    );

    function owner(bytes32 id) external view returns(bytes32);
}
