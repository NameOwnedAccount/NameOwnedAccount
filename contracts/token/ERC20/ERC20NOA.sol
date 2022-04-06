// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import '../../identity/INameService.sol';
import '../../identity/NameOwnedAccount.sol';
import './IERC20NOA.sol';

contract ERC20NOA is IERC20NOA, NameOwnedAccount, ERC165, ERC20 {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) { }

    function transferFromName(
        bytes memory spender,
        address from,
        address to,
        uint256 amount
    ) public virtual override returns(bool) {
        address spenderNOA = _authenticate(spender);
        if (from != spenderNOA) {
            _spendAllowance(from, spenderNOA, amount);
        }
        _transfer(from, to, amount);
        return true;
    }

    function approveFromName(
        bytes memory owner,
        address spender,
        uint256 amount
    ) public virtual override returns(bool) {
        address ownerNOA = _authenticate(owner);
        _approve(ownerNOA, spender, amount);
        return true;
    }

    function increaseAllowanceFromName(
        bytes memory owner,
        address spender,
        uint256 addedValue
    ) public virtual override returns(bool) {
        address ownerNOA = _authenticate(owner);
        _approve(ownerNOA, spender, allowance(ownerNOA, spender) + addedValue);
        return true;
    }

    function decreaseAllowanceFromName(
        bytes memory owner,
        address spender,
        uint256 subtractedValue
    ) public virtual override returns(bool) {
        address ownerNOA = _authenticate(owner);
        uint256 currentAllowance = allowance(ownerNOA, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(ownerNOA, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns(bool) {
        return
            interfaceId == type(IERC20NOA).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
