// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";
import './INameService.sol';
import './INOA.sol';

contract NOA is INOA, Context {
    bytes32 constant private ADDRESS_OF_HASH = keccak256("addressOfName(bytes name)");

    function addressOfName(bytes memory name) public pure virtual override returns(address) {
        (bytes32 node, address ns) = _parseName(name);
        return _addressOf(node, ns);
    }

    function isNameOwner(bytes memory name, address operator) public view virtual override returns(bool) {
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
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), ns, node, ADDRESS_OF_HASH)
        );
        return address(uint160(uint(hash)));
    }

    function _isOwner(bytes32 node, address ns, address operator) internal view returns(bool) {
        return INameService(ns).owner(node) == operator;
    }

    function _parseName(bytes memory name) internal pure returns(bytes32, address) {
        (string memory username, address ns) = abi.decode(name, (string, address));
        return (keccak256(bytes(username)), ns);
    }
}
