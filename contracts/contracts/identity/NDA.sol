// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import './INDA.sol';

contract NDA is INDA {
    struct Name {
        bytes32 node;
        address nameService;
    }

    mapping(address => Name) private _nodes;

    function setNDA(bytes32 node, address nameService) external {
        address derived = _nameOwnedAddr(nameService, node);
        _nodes[derived] = Name(node, nameService);
    }

    function name(address nameOwnedAddr) public override view returns(bytes32, address) {
        Name storage n = _nodes[nameOwnedAddr];
        return (n.node, n.nameService);
    }

    /* @dev compute name owned address from ens bytes32 node
     *
     * The way we compute the name owned account is the same with CREATE2 without
     * the bytecode. The deployer address is this smart contract address to avoid
     * collision with other smart contract addresses:
     *
     *    hash(0xff, address(0), nameService, node)
     *
     */
    function _nameOwnedAddr(
        address nameService,
        bytes32 node
    ) internal pure returns(address account) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0xff)
            mstore(add(ptr, 0x01), shl(0x60, 0x0000000000000000000000000000000000000000))
            mstore(add(ptr, 0x15), shl(0x60, nameService))
            mstore(add(ptr, 0x35), node)
            account := keccak256(ptr, 0x55)
        }
    }
}
