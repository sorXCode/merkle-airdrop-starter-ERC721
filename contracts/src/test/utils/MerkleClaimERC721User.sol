// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { MerkleClaimERC721 } from "../../MerkleClaimERC721.sol"; // MerkleClaimERC721

/// @title MerkleClaimERC721User
/// @notice Mock MerkleClaimERC721 user
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract MerkleClaimERC721User {

  /// ============ Immutable storage ============

  /// @dev MerkleClaimERC721 contract
  MerkleClaimERC721 immutable internal TOKEN;
  address immutable public ADDRESS;

  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC721User
  /// @param _TOKEN MerkleClaimERC721 contract
  constructor(MerkleClaimERC721 _TOKEN, address _ADDRESS) {
    TOKEN = _TOKEN;
    ADDRESS = _ADDRESS;
  }

  /// ============ Helper functions ============

  /// @notice Returns users' token balance
  function tokenBalance() public view returns (uint256) {
    return TOKEN.balanceOf(ADDRESS);
  }

  /// ============ Inherited functionality ============

  /// @notice Allows user to claim tokens from contract
  /// @param to address of claimee
  /// @param _tokenURI of tokens owed to claimee
  /// @param proof merkle proof to prove address and amount are in tree
  function claim(address to, string memory _tokenURI, bytes32[] calldata proof) public {
    TOKEN.claim(to, _tokenURI, proof);
  }
}