// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './IUniversalNameService.sol';

library LibIdentity {
    function encode(address account) internal pure returns(bytes32) {
        return keccak256(abi.encode(account));
    }

    function authenticate(
        IUniversalNameService service,
        bytes32 id,
        bytes32 operator
    ) internal view returns(bool) {
        if (id == bytes32(0)) { return false; }
        if (operator == id) { return true; }
        return authenticate(service, service.owner(id), operator);
    }
}
