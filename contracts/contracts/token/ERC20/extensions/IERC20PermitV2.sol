// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IERC20PermitV2 {
    function permit(
        bytes32 owner,
        bytes32 spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(bytes32 owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
