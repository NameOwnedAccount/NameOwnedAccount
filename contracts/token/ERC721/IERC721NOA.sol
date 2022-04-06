// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import '../../identity/INameOwnedAccount.sol';

interface IERC721NOA is INameOwnedAccount, IERC721 {
    function safeTransferFromName(
        bytes memory _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes memory data
    ) external;

    function safeTransferFromName(
        bytes memory _operator,
        address _from,
        address _to,
        uint256 _amount
    ) external;

    function approveFromName(
        bytes memory _owner,
        address _operator,
        uint256 _tokenId
    ) external;

    function setApprovalForAllFromName(
        bytes memory _owner,
        address _operator,
        bool _approved
    ) external;
}
