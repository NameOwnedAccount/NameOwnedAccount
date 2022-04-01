// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";
import './INameService.sol';
import './INOA.sol';

abstract contract NOA is INOA, Context {
    function addressOf(bytes memory name) public pure virtual override returns(address) {
        (bytes32 node, address ns) = _parseName(name);
        return _addressOf(node, ns);
    }

    function isOwner(bytes memory name, address operator) public view virtual override returns(bool) {
        (bytes32 node, address ns) = _parseName(name);
        return _isOwner(node, ns, operator);
    }

    function _authenticate(bytes memory name) internal view returns(address) {
        (bytes32 node, address ns) = _parseName(name);
        require(
            _isOwner(node, ns, _msgSender()),
            'ERC20NOA: not authorized'
        );
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
