// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

library LibIdentity {
    function encode(address account) internal pure returns(bytes32) {
        return keccak256(abi.encode(account));
    }
}
