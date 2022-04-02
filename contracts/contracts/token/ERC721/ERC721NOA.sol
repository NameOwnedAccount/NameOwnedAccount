// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import '../../identity/INameService.sol';
import '../../identity/NOA.sol';
import './IERC721NOA.sol';

contract ERC721NOA is IERC721NOA, NOA, ERC721 {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) { }

    function safeTransferFrom(
        bytes memory from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        (bytes32 node, address ns) = _parseName(from);
        address fromNOA = _addressOf(node, ns);
        address operator = _msgSender();
        require(
            _isOwner(node, ns, operator) || _isApprovedOrOwner(operator, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(fromNOA, to, tokenId, data);
    }

    function safeTransferFrom(
        bytes memory from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    function approve(
        bytes memory from,
        address to,
        uint256 tokenId
    ) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        address operator = _msgSender();
        require(
            _isFromTokenOwner(from, owner, operator) || isApprovedForAll(owner, operator),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenId);
    }

    function setApprovalForAll(
        bytes memory owner,
        address operator,
        bool approved
    ) public virtual override {
        (bytes32 node, address ns) = _parseName(owner);
        require(
            _isOwner(node, ns, _msgSender()),
            'ERC721: caller is not owner'
        );
        _setApprovalForAll(_addressOf(node, ns), operator, approved);
    }

    function _isFromTokenOwner(
        bytes memory from,
        address owner,
        address operator
    ) internal view returns(bool) {
        (bytes32 node, address ns) = _parseName(from);
        address fromNOA = _addressOf(node, ns);
        return fromNOA == owner && _isOwner(node, ns, operator);
    }
}
