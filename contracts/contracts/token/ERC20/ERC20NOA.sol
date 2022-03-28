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

    function transfer(bytes memory from, address to, uint256 amount) public virtual override returns (bool) {
        (bytes32 node, address ns) = _parseName(from);
        require(_isOwner(node, ns, _msgSender()), 'ERC20NDA: not authorized');
        _transfer(_addressOf(node, ns), to, amount);
        return true;
    }

    function approve(bytes memory owner, address spender, uint256 amount) public virtual override returns (bool) {
        (bytes32 node, address ns) = _parseName(owner);
        require(_isOwner(node, ns, _msgSender()), 'ERC20NDA: not authorized');
        _approve(_addressOf(node, ns), spender, amount);
        return true;
    }

    function increaseAllowance(
        bytes memory owner,
        address spender,
        uint256 addedValue
    ) public virtual returns(bool) {
        (bytes32 node, address ns) = _parseName(owner);
        require(_isOwner(node, ns, _msgSender()), 'ERC20NDA: not authorized');
        address ownerNDA = _addressOf(node, ns);
        _approve(ownerNDA, spender, allowance(ownerNDA, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        bytes memory owner,
        address spender,
        uint256 subtractedValue
    ) public virtual returns(bool) {
        (bytes32 node, address ns) = _parseName(owner);
        require(_isOwner(node, ns, _msgSender()), 'ERC20NDA: not authorized');
        address ownerNDA = _addressOf(node, ns);
        uint256 currentAllowance = allowance(ownerNDA, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(ownerNDA, spender, currentAllowance - subtractedValue);
        }
        return true;
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
