// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import '../../identity/INOA.sol';

interface IERC721NOA is INOA, IERC721 {
    function safeTransferFrom(
        bytes memory _from,
        address _to,
        uint256 _amount,
        bytes memory data
    ) external;

    function safeTransferFrom(
        bytes memory _from,
        address _to,
        uint256 _amount
    ) external;

    function approve(
        bytes memory _owner,
        address _operator,
        uint256 _tokenId
    ) external;

    function setApprovalForAll(
        bytes memory _owner,
        address _operator,
        bool _approved
    ) external;
}
