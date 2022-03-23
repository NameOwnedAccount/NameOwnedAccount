// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "../IERC20Universal.sol";
import "@openzeppelin/contracts/utils/Address.sol";

library SafeERC20Universal {
    using Address for address;

    function safeTransfer(
        IERC20Universal token,
        bytes32 from,
        bytes32 to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, from, to, value));
    }

    function safeTransferFrom(
        IERC20Universal token,
        bytes32 operator,
        bytes32 from,
        bytes32 to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, operator, from, to, value));
    }

    function safeIncreaseAllowance(
        IERC20Universal token,
        bytes32 owner,
        bytes32 spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(owner, spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, owner, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Universal token,
        bytes32 owner,
        bytes32 spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(owner, spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, owner, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Universal token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20Universal: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20Universal: ERC20 operation did not succeed");
        }
    }
}
