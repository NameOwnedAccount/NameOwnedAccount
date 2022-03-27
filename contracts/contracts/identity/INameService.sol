// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface INameService {
    function owner(bytes32 node) external view returns(address);
}
