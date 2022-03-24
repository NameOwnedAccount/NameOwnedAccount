// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IVotesV2 {
    event DelegateChanged(bytes32 indexed delegator, bytes32 indexed fromDelegate, bytes32 indexed toDelegate);

    event DelegateVotesChanged(bytes32 indexed delegate, uint256 previousBalance, uint256 newBalance);

    function getVotes(bytes32 account) external view returns (uint256);

    function getPastVotes(bytes32 account, uint256 blockNumber) external view returns (uint256);

    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    function delegates(bytes32 account) external view returns (bytes32);

    function delegate(bytes32 delegator, bytes32 delegatee) external;

    function delegateBySig(
        bytes32 delegator,
        bytes32 delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
