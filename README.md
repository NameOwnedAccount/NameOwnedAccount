# Problem Statement

In current blockchain word, we are using public key as global identity, which brings follow disadvantages:

 - User need to maintain a private key to authenticate himself. Private key is the only way to authenticate.
 - If the private key is lost, there is no way to recover the account
 - If the private key is leaked, there is no way to lock the account
 - There is no way to migrate history if user want to migrate to a different public key(because private key is leaked).

ENS already solves part of these problems by mapping a human readable identity to blockchain address. However, most of ERC20/ERC721/ERC1155 tokens are bound to address instead of ENS name. If user changed the owner address of ENS, the token will gone with the old owner address, which means all onchain activity with the ENS record will be gone with the old owner address, which is not ideal. In the future, if ENS is the universal username for Web3, it should be able to hold tokens and retain all onchain activities.

# Solution
In this project, We aims to improve the ENS service and ERC20/ERC721/ERC1155 token in multiple aspects:

 - promote bytes32 as first class citizen instead of address for ERC standard, where bytes32 is the hash of username
 - provide a universal name service without renewal fee and domain constraint, since the service is for username not domain
 - be compatiable with existing ERC standards

By decoupling the token standard with address, it's possible to generalize the full-custody model with self-custody model. A custodian party can hold millions of usernames controlled by one account address. The custodian party can serve as relayer for user to send transactions. If user want to migrate their account out of the custody party, they can change the owner of the domain name without losing any onchain history. For entry level users, we don't need to generate an public key for them but still keep everything onchain.

# Account registration

Users will have to provide a string username and a public key to register an onchain account. The string could be arbitrary. We store it onchain with a mapping from bytes32 -> (username, owner). Only owner will be able to update the owner and get access to the username. The bytes32 key is the hash of the username, by `keccak256(abi.encode(username))`. Since username is a string, `abi.encode(username)` is guaranteed to be larger than 32 bytes.

### Authentication Strategy
Authentication is the process to ensure the action is triggered by user.

The input of authentications is __(byte32 userid, address operator)__

Currently we support three authentication strategies:

- If the id is the hash of operator, returns true
- Otherwise, find the authenticator of id from identityService
  - If the authenticator is address(0), the id is not registered, returns true
  - If the authenticator is operator, returns false

### ERC Backward compatibility

To be backward compatible with current address system, if the bytes32 id is the hash of EOA or contract address, we assume the owner of the contract/public key is the owner of the id and always returns true. These is no way to override the hash of address since user can only register string usernames, not address.

### Interface

```
interface IIdentityService {
    struct Identity {
        string name;
        address owner;
    }

    event Register(
        bytes32 indexed id,
        address indexed owner,
        string name
    );

    event AuthKeyUpdate(
        bytes32 indexed id,
        address indexed authenticator
    );

    function authenticate(
        bytes32 id,
        address operator
    ) external view returns(bool);

    function name(bytes32 id) external view returns(string memory);

    function owner(bytes32 id) external view returns(address);
}
```

### ERC20 Example

```
pragma solidity ^0.8.0;

contract ERC20 is IERC20 {
    mapping(bytes32 => uint256) private _balances;
    mapping(bytes32 => mapping(bytes32 => uint256)) private _allowances;

    // Legacy
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    // New
    function transfer(
        bytes32 from,
        bytes32 to,
        uint256 amount
    ) public virtual override returns (bool) {
        IIdentityService(identityService).authenticate(from, _msgSender());
        _transfer(from, to, amount);
        return true;
    }
}
```
