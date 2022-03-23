// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IUniversalNameService {
    struct Identity {
        string name;
        address owner;
    }

    event Register(
        bytes32 indexed id,
        address indexed owner,
        string name
    );

    event SetOwner(
        bytes32 indexed id,
        address indexed authenticator
    );

    function authenticate(
        bytes32 id,
        address operator
    ) external view returns(bool);

    function name(bytes32 id) external view returns(string memory);

    function owner(bytes32 id) external view returns(address);
}
