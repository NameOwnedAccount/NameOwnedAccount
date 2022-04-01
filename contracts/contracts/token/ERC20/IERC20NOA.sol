// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '../../identity/INOA.sol';

interface IERC20NOA is INOA, IERC20 {
    function transferFrom(
        bytes memory from,
        address to,
        uint256 amount
    ) external returns(bool);

    function approve(
        bytes memory _owner,
        address _spender,
        uint256 _value
    ) external returns(bool);

    function increaseAllowance(
        bytes memory owner,
        address spender,
        uint256 addedValue
    ) external returns(bool);

    function decreaseAllowance(
        bytes memory owner,
        address spender,
        uint256 subtractedValue
    ) external returns(bool);
}
