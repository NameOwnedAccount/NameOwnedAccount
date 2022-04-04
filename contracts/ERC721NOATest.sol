// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./token/ERC721/ERC721NOA.sol";

contract ERC721NOATest is ERC721NOA, Ownable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721NOA(name, symbol) { }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }
}
