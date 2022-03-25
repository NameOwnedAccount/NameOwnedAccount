// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './LibIdentity.sol';
import './IUniversalNameService.sol';

contract UniversalNameService is Context, IUniversalNameService {
    using LibIdentity for address;

    mapping(bytes32 => Identity) private _identities;

    function register(string memory name_, bytes32 owner_) external {
        bytes32 id = keccak256(abi.encode(name_));
        require(
            owner(id) == bytes32(0),
            'IdentityService: already registered'
        );
        _identities[id] = Identity(name_, owner_);
        emit Register(id, owner_, name_);
    }

    function setOwner(
        bytes32 id,
        bytes32 newOwner
    ) external {
        bytes32 operator = (_msgSender()).encode();
        bytes32 oldOwner = owner(id);
        require(
            authenticate(oldOwner, operator),
            'IdentityService: not authorized'
        );
        _identities[id].owner = newOwner;
        emit SetOwner(id, oldOwner, newOwner);
    }

    function authenticate(
        bytes32 id,
        bytes32 operator
    ) public override view returns(bool) {
        if (id == bytes32(0)) { return false; }
        if (operator == id) { return true; }
        return authenticate(owner(id), operator);
    }

    function name(bytes32 id) public override view returns(string memory) {
        return _identities[id].name;
    }

    function owner(bytes32 id) public override view returns(bytes32) {
        return _identities[id].owner;
    }
}
