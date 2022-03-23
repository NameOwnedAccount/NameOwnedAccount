// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './IIdentityService.sol';

contract IdentityService is Context, IIdentityService {
    using LibIdentity for address;

    struct Identity {
        string username;
        address authKey;
    }

    mapping(bytes32 => Identity) private _identities;

    function register(
        string memory username_,
        address authKey_
    ) external {
        bytes32 id = keccak256(abi.encode(username_));
        require(
            authKey(id) == address(0),
            'IdentityService: already registered'
        );
        _identities[id] = Identity(username_, authKey_);
        emit Register(id, authKey_, username_);
    }

    function updateAuthKey(bytes32 id, address newAuthKey) external {
        require(
            authKey(id) == _msgSender(),
            'IdentityService: not authorized'
        );
        _identities[id].authKey = newAuthKey;
        emit AuthKeyUpdate(id, newAuthKey);
    }

    function authenticate(
        bytes32 id,
        address operator
    ) external override view returns(bool) {
        return operator.encode() == id || authKey(id) == operator;
    }

    function username(bytes32 id) public override view returns(string memory) {
        return _identities[id].username;
    }

    function authKey(bytes32 id) public override view returns(address) {
        return _identities[id].authKey;
    }
}
