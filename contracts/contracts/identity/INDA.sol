// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface INDA {
    /**
        @notice return the bytes32 node registered from the address
        @param nameOwnedAddress  The bytes32 node, which can be used to look up name
    */
    function name(
        address nameOwnedAddress
    ) external view returns(bytes32 node, address nameService);
}
