// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './LibIdentity.sol';

interface IIdentityService {
    event AuthKeyUpdate(
        bytes32 indexed id,
        address indexed authenticator
    );

    function authKey(bytes32 id) external view returns(address);

    function authenticate(
        bytes32 id,
        address operator
    ) external view;
}
