// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IERC20V2 {
    function totalSupplyV2() external view returns (uint256);

    function balanceOfV2(bytes32 account) external view returns (uint256);

    function transferV2(bytes32 from, bytes32 to, uint256 amount) external returns (bool);

    function allowanceV2(bytes32 owner, bytes32 spender) external view returns (uint256);

    function approveV2(bytes32 owner, bytes32 spender, uint256 amount) external returns (bool);

    function transferFromV2(
        bytes32 operator,
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) external returns (bool);

    event TransferV2(bytes32 indexed from, bytes32 indexed to, uint256 value);

    event ApprovalV2(bytes32 indexed owner, bytes32 indexed spender, uint256 value);
}
