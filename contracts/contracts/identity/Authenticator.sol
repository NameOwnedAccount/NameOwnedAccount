// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './INameService.sol';
import './INDA.sol';

contract Authenticator is Context {
    INDA constant public _nda = INDA(address(0));

    modifier onlyAuthenticated(address nameOwnedAddr) {
        require(
            authenticate(nameOwnedAddr, _msgSender()),
            'Authenticator: not authorized'
        );
        _;
    }

    function authenticate(
        address nameOwnedAddr,
        address operator
    ) public virtual view returns(bool) {
        if (nameOwnedAddr == operator) {
            return true;
        }
        (bytes32 node, address nameService) = _nda.name(nameOwnedAddr);
        return INameService(nameService).owner(node) == operator;
    }
}
