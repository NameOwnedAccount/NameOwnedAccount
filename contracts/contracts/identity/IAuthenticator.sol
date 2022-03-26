// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IAuthenticator {
    function nameService() external view returns(address);

    function authenticate(bytes32 id, bytes32 operator) external view returns(bool);
}
