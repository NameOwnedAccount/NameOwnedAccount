// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './LibIdentity.sol';
import './IAuthenticator.sol';
import './IUniversalNameService.sol';

contract Authenticator is Context, IAuthenticator {
    using LibIdentity for address;

    address immutable private _nameService;

    modifier onlyAuthenticated(bytes32 id) {
        address operator = _msgSender();
        require(
            authenticate(id, operator.encode()),
            'Authenticator: unauthorized operator'
        );
        _;
    }

    constructor(address nameService_) {
        _nameService = nameService_;
    }

    function nameService() public view override returns(address) {
        return _nameService;
    }

    function authenticate(bytes32 id, bytes32 operator) public view override returns(bool) {
        return LibIdentity.authenticate(
            IUniversalNameService(_nameService), id, operator
        );
    }
}
