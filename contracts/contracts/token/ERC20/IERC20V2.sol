// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IERC20V2 {
    function nameService() external view returns (address);

    function totalSupply() external view returns (uint256);

    function balanceOf(bytes32 account) external view returns (uint256);

    function transfer(bytes32 from, bytes32 to, uint256 amount) external returns (bool);

    function allowance(bytes32 owner, bytes32 spender) external view returns (uint256);

    function approve(bytes32 owner, bytes32 spender, uint256 amount) external returns (bool);

    function transferFrom(
        bytes32 operator,
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) external returns (bool);

    event Transfer(bytes32 indexed from, bytes32 indexed to, uint256 value);

    event Approval(bytes32 indexed owner, bytes32 indexed spender, uint256 value);
}
