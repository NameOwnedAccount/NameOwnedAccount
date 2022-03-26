// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../identity/LibIdentity.sol";
import "../../identity/IUniversalNameService.sol";
import "../../identity/Authenticator.sol";

import "./IERC20V2.sol";

contract ERC20 is Authenticator, IERC20, IERC20V2, IERC20Metadata {
    using LibIdentity for address;

    bytes32 constant public ADDRESS_ZERO = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    mapping(bytes32 => uint256) private _balances;
    mapping(bytes32 => mapping(bytes32 => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(
        string memory name_,
        string memory symbol_,
        address nameService_
    ) Authenticator(nameService_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupplyV2()
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _totalSupply;
    }

    function totalSupply()
        public
        view
        virtual
        override
        returns (uint256)
    {
        return totalSupplyV2();
    }

    function balanceOfV2(bytes32 account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return balanceOfV2(account.encode());
    }

    function allowanceV2(bytes32 owner, bytes32 spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner.encode()][spender.encode()];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner.encode(), to.encode(), amount);
        return true;
    }

    function transferV2(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) public virtual override onlyAuthenticated(from) returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address operator = _msgSender();
        _spendAllowance(from.encode(), operator.encode(), amount);
        _transfer(from.encode(), to.encode(), amount);
        return true;
    }

    function transferFromV2(
        bytes32 operator,
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) public virtual override onlyAuthenticated(operator) returns (bool) {
        _spendAllowance(from, operator, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address operator = _msgSender();
        _approve(operator.encode(), spender.encode(), amount);
        return true;
    }

    function approveV2(
        bytes32 owner,
        bytes32 spender,
        uint256 amount
    ) public virtual override onlyAuthenticated(owner) returns (bool) {
        _approve(owner, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        bytes32 ownerId = owner.encode();
        bytes32 spenderId = spender.encode();
        uint256 amount = allowanceV2(ownerId, spenderId) + addedValue;
        _approve(ownerId, spenderId, amount);
        return true;
    }

    function increaseAllowanceV2(
        bytes32 owner,
        bytes32 spender,
        uint256 addedValue
    ) public virtual onlyAuthenticated(owner) returns (bool) {
        _approve(owner, spender, allowanceV2(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        bytes32 ownerId = owner.encode();
        bytes32 spenderId = spender.encode();
        uint256 currentAllowance = allowanceV2(ownerId, spenderId);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(ownerId, spenderId, currentAllowance - subtractedValue);
        }
        return true;
    }

    function decreaseAllowanceV2(
        bytes32 owner,
        bytes32 spender,
        uint256 subtractedValue
    ) public virtual onlyAuthenticated(owner) returns (bool) {
        uint256 currentAllowance = allowanceV2(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _spendAllowance(
        bytes32 owner,
        bytes32 spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowanceV2(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _approve(
        bytes32 owner,
        bytes32 spender,
        uint256 amount
    ) internal virtual {
        require(owner != ADDRESS_ZERO, "ERC20: approve from the zero address");
        require(spender != ADDRESS_ZERO, "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit ApprovalV2(owner, spender, amount);
    }

    function _transfer(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) internal virtual {
        require(from != ADDRESS_ZERO, "ERC20: transfer from the zero address");
        require(to != ADDRESS_ZERO, "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit TransferV2(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(bytes32 account, uint256 amount) internal virtual {
        require(account != ADDRESS_ZERO, "ERC20: mint to the zero address");
        _beforeTokenTransfer(ADDRESS_ZERO, account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit TransferV2(ADDRESS_ZERO, account, amount);

        _afterTokenTransfer(ADDRESS_ZERO, account, amount);
    }

    function _burn(bytes32 account, uint256 amount) internal virtual {
        require(account != ADDRESS_ZERO, "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, ADDRESS_ZERO, amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit TransferV2(account, ADDRESS_ZERO, amount);

        _afterTokenTransfer(account, ADDRESS_ZERO, amount);
    }

    function _beforeTokenTransfer(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) internal virtual {}
}
