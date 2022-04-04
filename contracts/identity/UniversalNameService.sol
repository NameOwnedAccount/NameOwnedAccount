// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";
import './INameService.sol';

contract UniversalNameService is INameService, Context {
    mapping(bytes32 => address) private _owners;

    function setOwner(
        bytes32 node,
        address newOwner
    ) external override {
        require(
            newOwner != address(0),
            'UniversalNameService: new owner is zero address'
        );

        address oldOwner = owner(node);
        require(
            oldOwner == address(0) || _msgSender() == oldOwner,
            'UniversalNameService: not name owner'
        );
        _owners[node] = newOwner;
        emit OwnershipTransfer(node, oldOwner, newOwner);
    }

    function owner(bytes32 node) public override view returns(address) {
        return _owners[node];
    }
}
