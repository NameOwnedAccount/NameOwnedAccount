// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IERC20NOA {
    function addressOf(bytes memory name) external returns(address);

    function isOwner(bytes memory name, address owner) external returns(bool);

    function transferFrom(bytes memory from, address to, uint256 amount) external returns(bool);

    function increaseAllowanceFrom(
        bytes memory owner,
        address spender,
        uint256 addedValue
    ) external returns(bool);

    function decreaseAllowanceFrom(
        bytes memory owner,
        address spender,
        uint256 subtractedValue
    ) external returns(bool);
}
