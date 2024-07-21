// SPDX-License-Identifier MIT

pragma solidity 0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {console} from "forge-std/Test.sol";

contract MerkleAirdrop {
    // some list of addresses
    // allow someone in the list to claim tokens
    using SafeERC20 for IERC20;

    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidProof();

    event Claim(address account, uint256 amount);

    address[] claimers;
    bytes32 internal immutable i_merkleRoot;
    IERC20 internal immutable i_airdropToken;
    mapping(address claimer => bool claimed) internal s_hasClaimed;

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
        if (s_hasClaimed[_account]) revert MerkleAirdrop__AlreadyClaimed();
        // calculate using the account and amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(abi.encodePacked(_account, _amount)));
        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) revert MerkleAirdrop__InvalidProof();
        s_hasClaimed[_account] = true;
        emit Claim(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
