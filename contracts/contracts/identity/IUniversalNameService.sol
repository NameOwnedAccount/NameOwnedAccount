// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IUniversalNameService {
    struct Identity {
        string name;
        bytes32 owner;
    }

    event Register(
        bytes32 indexed id,
        bytes32 indexed owner,
        string name
    );

    event SetOwner(
        bytes32 indexed id,
        bytes32 indexed oldOwner,
        bytes32 indexed newOwner
    );

    function authenticate(
        bytes32 id,
        bytes32 operator
    ) external view returns(bool);

    function name(bytes32 id) external view returns(string memory);

    function owner(bytes32 id) external view returns(bytes32);
}
