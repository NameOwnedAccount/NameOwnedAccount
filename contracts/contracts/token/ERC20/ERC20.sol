// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "../../identity/LibIdentity.sol";
import "../../identity/IUniversalNameService.sol";

import "./IERC20V2.sol";

contract ERC20 is Context, IERC20, IERC20V2, IERC20Metadata {
    using LibIdentity for address;

    bytes32 constant public ADDRESS_ZERO = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    address immutable private _nameService;
    mapping(bytes32 => uint256) private _balances;
    mapping(bytes32 => mapping(bytes32 => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    modifier onlyAuthenticated(bytes32 id) {
        require(
            IUniversalNameService(nameService()).authenticate(id, _msgSender()),
            'ERC20: unauthorized operator'
        );
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address nameService_
    ) {
        _name = name_;
        _symbol = symbol_;
        _nameService = nameService_;
    }

    function nameService() public view virtual override returns(address) {
        return _nameService;
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

    function totalSupply()
        public
        view
        virtual
        override(IERC20, IERC20V2)
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(bytes32 account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account.encode()];
    }

    function allowance(bytes32 owner, bytes32 spender) public view virtual override returns (uint256) {
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

    function transfer(
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

    function transferFrom(
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

    function approve(
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
        uint256 amount = allowance(ownerId, spenderId) + addedValue;
        _approve(ownerId, spenderId, amount);
        return true;
    }

    function increaseAllowance(
        bytes32 owner,
        bytes32 spender,
        uint256 addedValue
    ) public virtual onlyAuthenticated(owner) returns (bool) {
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        bytes32 ownerId = owner.encode();
        bytes32 spenderId = spender.encode();
        uint256 currentAllowance = allowance(ownerId, spenderId);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(ownerId, spenderId, currentAllowance - subtractedValue);
        }
        return true;
    }

    function decreaseAllowance(
        bytes32 owner,
        bytes32 spender,
        uint256 subtractedValue
    ) public virtual onlyAuthenticated(owner) returns (bool) {
        uint256 currentAllowance = allowance(owner, spender);
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
        uint256 currentAllowance = allowance(owner, spender);
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
        emit Approval(owner, spender, amount);
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

        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(bytes32 account, uint256 amount) internal virtual {
        require(account != ADDRESS_ZERO, "ERC20: mint to the zero address");
        _beforeTokenTransfer(ADDRESS_ZERO, account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(ADDRESS_ZERO, account, amount);

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

        emit Transfer(account, ADDRESS_ZERO, amount);

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
