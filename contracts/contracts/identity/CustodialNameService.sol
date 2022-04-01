// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";

import './INameService.sol';

contract CustodialNameService is INameService, Context {
    address immutable private _defaultOwner;
    mapping(bytes32 => address) private _overrides;

    constructor(address defaultOwner) {
        _defaultOwner = defaultOwner;
    }

    function setOwner(bytes32 node, address newOwner) external override {
        require(
            newOwner != address(0),
            'CustodialNameService: new owner is zero address'
        );

        address oldOwner = owner(node);
        require(
            _msgSender() == oldOwner,
            'CustodialNameService: not name owner'
        );
        _overrides[node] = newOwner;
        emit OwnershipTransfer(node, oldOwner, newOwner);
    }

    function owner(bytes32 node) public override view returns(address) {
        address owner_ = _overrides[node];
        return owner_ == address(0) ? _defaultOwner : owner_;
    }
}
