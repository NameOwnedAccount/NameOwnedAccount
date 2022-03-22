// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './IIdentityService.sol';

contract IdentityService is Context, IIdentityService {
    using LibIdentity for address;

    mapping(bytes32 => address) private _authKeys;

    function authKey(bytes32 id) public override view returns(address) {
        return _authKeys[id];
    }

    function authenticate(
        bytes32 id,
        address operator
    ) public override view {
        if (operator.encode() == id) {
            return;
        }
        address key = authKey(id);
        require(
            key == address(0) || key == operator,
            'IdentityService: operator not authorized'
        );
    }

    function setAuthKey(bytes32 id, address newAuthKey) external {
        authenticate(id, _msgSender());
        _authKeys[id] = newAuthKey;
        emit AuthKeyUpdate(id, newAuthKey);
    }
}
