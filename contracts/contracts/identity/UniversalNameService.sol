// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './LibIdentity.sol';
import './IUniversalNameService.sol';

contract UniversalNameService is Context, IUniversalNameService {
    using LibIdentity for address;

    mapping(bytes32 => bytes32) private _owners;

    function setOwner(string memory name_, bytes32 newOwner) external {
        bytes32 id = keccak256(abi.encode(name_));
        address operator = _msgSender();
        bytes32 oldOwner = owner(id);
        require(
            oldOwner == bytes32(0) || LibIdentity.authenticate(
                IUniversalNameService(address(this)),
                oldOwner,
                operator.encode()
            ),
            'IdentityService: not authorized'
        );
        _owners[id] = newOwner;
        _checkCircularDependency(newOwner, id);
        emit OwnerUpdated(id, oldOwner, newOwner);
    }

    function owner(bytes32 id) public override view returns(bytes32) {
        return _owners[id];
    }

    function _checkCircularDependency(
        bytes32 node,
        bytes32 origin
    ) private view {
        require(node != origin, 'IdentityService: circular dependency');
        if (node == bytes32(0)) { return; }
        return _checkCircularDependency(owner(node), origin);
    }
}
