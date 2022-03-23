// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './LibIdentity.sol';

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

    event UnsetReverse(
        address indexed operator,
        bytes32 indexed id
    );

    event SetReverse(
        address indexed operator,
        bytes32 indexed id
    );

    function authenticate(
        bytes32 id,
        address operator
    ) external view returns(bool);

    function name(bytes32 id) external view returns(string memory);

    function owner(bytes32 id) external view returns(address);

    function reverse(address owner_) external view returns(bytes32);
}
