// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './IIdentityService.sol';

contract IdentityService is Context, IIdentityService {
    using LibIdentity for address;

    mapping(bytes32 => Identity) private _identities;

    function register(
        string memory name_,
        address owner_
    ) external {
        bytes32 id = keccak256(abi.encode(name_));
        require(
            owner(id) == address(0),
            'IdentityService: already registered'
        );
        _identities[id] = Identity(name_, owner_);
        emit Register(id, owner_, name_);
    }

    function updateAuthKey(bytes32 id, address newAuthKey) external {
        require(
            owner(id) == _msgSender(),
            'IdentityService: not authorized'
        );
        _identities[id].owner = newAuthKey;
        emit AuthKeyUpdate(id, newAuthKey);
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
