// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import '../../identity/INameOwnedAccount.sol';

interface IERC20NOA is INameOwnedAccount, IERC20, IERC165 {
    function transferFromName(
        bytes memory operator,
        address from,
        address to,
        uint256 amount
    ) external returns(bool);

    function approveFromName(
        bytes memory owner,
        address spender,
        uint256 amount
    ) external returns(bool);

    function increaseAllowanceFromName(
        bytes memory owner,
        address spender,
        uint256 addedValue
    ) external returns(bool);

    function decreaseAllowanceFromName(
        bytes memory owner,
        address spender,
        uint256 subtractedValue
    ) external returns(bool);
}
