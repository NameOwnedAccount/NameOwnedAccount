# Introduction

B23 is an identity-first crypto wallet. With this wallet, user can manage their identities registered at the UNS(universal name service) and manupilate tokens compatible to the UNS.

# Supported Modes

## B23 Cusotdy

In this mode, user doesn't need to retain a private key since the username is hosted by b23 wallet service. User can login to b23 service and send transactions through the b23 websocket/http API.

## Self-Custody

### EOA

In this mode, user can import a public/privatey keypair, which is the owner of username, to b23 wallet. User can choose to pay gas fee by themselves to send transactions if the public address holds enough gas. Use can also deposit gas to b23 relay service so b23 relay service can pay gas and forward transactions for users.


### Wallet Connect

The username may be owned by account hosted by another dApp(e.g. Gnosis Safe or other custody service). In this case, user can connect the account with b23 wallet via Wallet Connect protocol. All transactions triggered by b23 wallet will be directed to the dApp to sign.
