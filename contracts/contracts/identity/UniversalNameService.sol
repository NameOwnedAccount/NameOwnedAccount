// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './INameService.sol';

contract UniversalNameService is INameService {
    event NameSet(bytes32 indexed node, string name);
    event OwnerSet(bytes32 indexed node, address indexed owner);

    struct Name {
        address owner;
        string name;
    }

    mapping(bytes32 => Name) private _names;

    function setName(string memory name_) external {
        bytes32 node = keccak256(bytes(name_));
        _names[node].name = name_;
        emit NameSet(node, name_);
    }

    function setOwner(bytes32 node, address newOwner) external {
        _names[node].owner = newOwner;
        emit OwnerSet(node, newOwner);
    }

    function owner(bytes32 node) public override view returns(address) {
        return _names[node].owner;
    }

    function name(bytes32 node) public view returns(string memory) {
        return _names[node].name;
    }
}
