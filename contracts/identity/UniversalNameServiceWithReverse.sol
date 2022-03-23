// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './IUniversalNameServiceWithReverse.sol';
import './UniversalNameService.sol';

contract UniversalNameServiceWithReverse is Context, IUniversalNameServiceWithReverse {
    UniversalNameService private immutable _service;
    mapping(address => bytes32) private _reverse;

    constructor(address service_) {
        _service = UniversalNameService(service_);
    }

    function register(string memory name_, address owner_) external {
        _service.register(name_, owner_);
    }

    function setOwner(bytes32 id, address newOwner) external {
        address operator = _msgSender();
        if (_reverse[operator] == id) {
            delete _reverse[operator];
            emit UnsetReverse(operator, id);
        }
        _service.setOwner(id, newOwner);
    }

    function setReverse(bytes32 id) external {
        address operator = _msgSender();
        require(
            owner(id) == operator,
            'IdentityService: not authorized'
        );
        _reverse[operator] = id;
        emit SetReverse(operator, id);
    }

    function authenticate(
        bytes32 id,
        address operator
    ) external override view returns(bool) {
        return _service.authenticate(id, operator);
    }

    function name(bytes32 id) public override view returns(string memory) {
        return _service.name(id);
    }

    function owner(bytes32 id) public override view returns(address) {
        return _service.owner(id);
    }

    function reverse(address owner_) public override view returns(bytes32) {
        return _reverse[owner_];
    }
}
