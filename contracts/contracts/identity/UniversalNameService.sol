// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './LibIdentity.sol';
import './IUniversalNameService.sol';

contract UniversalNameService is Context, IUniversalNameService {
    using LibIdentity for address;

    mapping(bytes32 => Identity) private _identities;

    function register(string memory name_, address owner_) external {
        bytes32 id = keccak256(abi.encode(name_));
        require(
            owner(id) == address(0),
            'IdentityService: already registered'
        );
        _identities[id] = Identity(name_, owner_);
        emit Register(id, owner_, name_);
    }

    function setOwner(
        bytes32 id,
        address newOwner
    ) external {
        address operator = _msgSender();
        require(
            owner(id) == operator,
            'IdentityService: not authorized'
        );
        _identities[id].owner = newOwner;
        emit SetOwner(id, operator, newOwner);
    }

    function authenticate(
        bytes32 id,
        address operator
    ) external override view returns(bool) {
        return operator.encode() == id || owner(id) == operator;
    }

    function name(bytes32 id) public override view returns(string memory) {
        return _identities[id].name;
    }

    function owner(bytes32 id) public override view returns(address) {
        return _identities[id].owner;
    }
}
