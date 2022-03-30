// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import '../../identity/INameService.sol';
import './IERC20NOA.sol';

abstract contract ERC20NOA is IERC20NOA, ERC20 {
    function addressOf(bytes memory name) public pure virtual override returns(address) {
        (bytes32 node, address ns) = _parseName(name);
        return _addressOf(node, ns);
    }

    function isOwner(bytes memory name, address operator) public view virtual override returns(bool) {
        (bytes32 node, address ns) = _parseName(name);
        return _isOwner(node, ns, operator);
    }

    function transferFrom(bytes memory from, address to, uint256 amount) public virtual override returns(bool) {
        (bytes32 node, address ns) = _parseName(from);
        address fromNOA = _addressOf(node, ns);
        address spender = _msgSender();
        if (!_isOwner(node, ns, spender)) {
            _spendAllowance(fromNOA, spender, amount);
        }
        _transfer(fromNOA, to, amount);
        return true;
    }

    function increaseAllowanceFrom(
        bytes memory owner,
        address spender,
        uint256 addedValue
    ) public virtual override returns(bool) {
        address ownerNOA = _authenticate(owner);
        _approve(ownerNOA, spender, allowance(ownerNOA, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        bytes memory owner,
        address spender,
        uint256 subtractedValue
    ) public virtual override returns(bool) {
        address ownerNOA = _authenticate(owner);
        uint256 currentAllowance = allowance(ownerNOA, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(ownerNOA, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _authenticate(bytes memory name) internal view returns(address) {
        (bytes32 node, address ns) = _parseName(name);
        require(_isOwner(node, ns, _msgSender()), 'ERC20NOA: not authorized');
        return _addressOf(node, ns);
    }

    function _addressOf(bytes32 node, address ns) internal pure returns(address account) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0xff)
            mstore(add(ptr, 0x01), shl(0x60, 0x0000000000000000000000000000000000000000))
            mstore(add(ptr, 0x15), shl(0x60, ns))
            mstore(add(ptr, 0x35), node)
            account := keccak256(ptr, 0x55)
        }
    }

    function _isOwner(bytes32 node, address ns, address operator) internal view returns(bool) {
        return INameService(ns).owner(node) == operator;
    }

    function _parseName(bytes memory name) internal pure returns(bytes32, address) {
        (string memory username, address ns) = abi.decode(name, (string, address));
        return (keccak256(bytes(username)), ns);
    }
}
