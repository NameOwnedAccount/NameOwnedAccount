// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import '../../identity/INameOwnedAccount.sol';

interface IERC721NOA is INameOwnedAccount, IERC721 {
    function safeTransferFromName(
        bytes memory operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    function safeTransferFromName(
        bytes memory operator,
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approveFromName(
        bytes memory from,
        address to,
        uint256 tokenId
    ) external;

    function setApprovalForAllFromName(
        bytes memory from,
        address to,
        bool approved
    ) external;
}
