// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./LibIdentity.sol";
import "./ERC20/ERC20Capped.sol";

contract Bridge23 is ERC20Capped, Ownable {
    using LibIdentity for address;

    constructor(
        string memory name,
        string memory symbol,
        address identityService,
        uint256 supplyCap
    ) ERC20(name, symbol, identityService) ERC20Capped(supplyCap) { }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to.encode(), amount);
    }

    function mint(bytes32 to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
