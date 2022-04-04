// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import "./token/ERC20/extensions/ERC20Votes.sol";

contract ERC20NOATest is ERC20Capped, ERC20Votes, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supplyCap
    ) ERC20NOA(name, symbol)
      ERC20Capped(supplyCap)
      ERC20Permit(name) { }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _mint(
        address account,
        uint256 amount
    ) internal virtual override(ERC20Capped, ERC20Votes) {
        super._mint(account, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }
}
