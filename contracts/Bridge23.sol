// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import 'hardhat/console.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

import "./identity/LibIdentity.sol";
import "./token/ERC20/extensions/ERC20Capped.sol";
import "./token/ERC20/extensions/ERC20Votes.sol";

contract Bridge23 is ERC20Capped, ERC20Votes, Ownable {
    using LibIdentity for address;

    constructor(
        string memory name,
        string memory symbol,
        address identityService,
        uint256 supplyCap
    ) ERC20(name, symbol, identityService)
      ERC20Capped(supplyCap)
      ERC20Permit(name) { }

    function mint(bytes32 to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _mint(
        bytes32 account,
        uint256 amount
    ) internal virtual override(ERC20Capped, ERC20Votes) {
        super._mint(account, amount);
    }

    function _burn(
        bytes32 account,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }
}
