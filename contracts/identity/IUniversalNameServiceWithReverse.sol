// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './IUniversalNameService.sol';

interface IUniversalNameServiceWithReverse is IUniversalNameService {
    event UnsetReverse(
        address indexed operator,
        bytes32 indexed id
    );

    event SetReverse(
        address indexed operator,
        bytes32 indexed id
    );

    function reverse(address owner_) external view returns(bytes32);
}
