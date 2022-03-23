// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './LibIdentity.sol';

interface IIdentityService {
    event Register(
        bytes32 indexed id,
        address indexed authKey,
        string username
    );

    event AuthKeyUpdate(
        bytes32 indexed id,
        address indexed authenticator
    );

    function authenticate(bytes32 id, address operator) external view;

    function username(bytes32 id) external view returns(string memory);

    function authKey(bytes32 id) external view returns(address);
}
