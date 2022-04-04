// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import '../../identity/INameService.sol';
import '../../identity/NameOwnedAccount.sol';
import './IERC721NOA.sol';

contract ERC721NOA is IERC721NOA, NameOwnedAccount, ERC721 {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) { }

    function safeTransferFromName(
        bytes memory from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        address fromNOA = _authenticate(from);
        _safeTransfer(fromNOA, to, tokenId, data);
    }

    function safeTransferFromName(
        bytes memory from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFromName(from, to, tokenId, '');
    }

    function approveFromName(
        bytes memory from,
        address to,
        uint256 tokenId
    ) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        address fromNOA = _authenticate(from);
        require(
            fromNOA == owner || isApprovedForAll(owner, fromNOA),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenId);
    }

    function setApprovalForAllFromName(
        bytes memory owner,
        address operator,
        bool approved
    ) public virtual override {
        address fromNOA = _authenticate(owner);
        _setApprovalForAll(fromNOA, operator, approved);
    }
}
