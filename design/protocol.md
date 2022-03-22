# Problem Statement

In current blockchain word, we are using public key as global identity, which brings follow disadvantages:

- User need to maintain a private key to authenticate himself. Private key is the only way to authenticate.
- If the private key is lost, there is no way to recover the account
- If the private key is leaked, there is no way to lock the account
- There is no way to migrate history if user want to migrate to a different public key(because private key is leaked).


# Goal

 - Decouple public key and identity, using public/private keypair as authenticator, not identity
 - Enable multiple authentication methods instead of simple public/private keypair for users

 
# Solution

We use bytes32 instead of address as user identifier. The bytes32 is the hash of the human readable id used by user.

### Backward compatibility

To be backward compatible with current address system, if the bytes32 id is the hash of EOA or contract address, we assume the owner of the contract/public key is the owner of the id, so do not use hash of public key you don't own as your id.

### Authentication Strategy
Authentication is the process to ensure the action is triggered by user.

The input of authentications is __(byte32 userid, address operator, bytes memory authData)__

Currently we support three authentication strategies:

- If the id is the hash of operator, pass
- Otherwise, find the authenticator of id from identityService
  - If the authenticator is address(0), the id is not registered, pass
  - If the authenticator is operator, pass

### Library

```
library LibIdentity {
    struct Identity {
        bytes32 id,
        bytes memory authData
    }
}
```
  

### Interface

```
interface IIdentityService {
    event AuthKeyUpdate(
        bytes32 indexed id,
        address indexed authenticator
    );
    
    function authKey(bytes32 id) external view returns(address);
    
    function authenticate(
        bytes32 id,
        address operator
    ) external view;
}

contract IdentityService is IIdentityService {
 	function authenticate(
        Identity memory id,
        address operator
    ) external view returns(address) {
    	 if (keccak256(operator) == id.id) {
            return operator;
        }

        address authenticator = authenticator(id.id);
        if (AddressUpgradeable.isContract(authenticator)) {
            IAuthenticator(authenticator).authenticate(
                id.id,
                id.authData
            );
        } else {
            require(
                authenticator == operator,
                'Authenticator: authenticator should be operator'
            );
        }
        return authenticator;
    }
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
