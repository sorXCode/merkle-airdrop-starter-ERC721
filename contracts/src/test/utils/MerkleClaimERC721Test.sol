// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { DSTest } from "ds-test/test.sol"; // DSTest
import { MerkleClaimERC721 } from "../../MerkleClaimERC721.sol"; // MerkleClaimERC721
import { MerkleClaimERC721User } from "./MerkleClaimERC721User.sol"; // MerkleClaimERC721 user

/// @title MerkleClaimERC721Test
/// @notice Scaffolding for MerkleClaimERC721 tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract MerkleClaimERC721Test is DSTest {

  /// ============ Storage ============

  /// @dev MerkleClaimERC721 contract
  MerkleClaimERC721 internal TOKEN;
  /// @dev User: Alice (in merkle tree)
  MerkleClaimERC721User internal ALICE;
  /// @dev User: Bob (not in merkle tree)
  MerkleClaimERC721User internal BOB;

  /// ============ Setup test suite ============

  function setUp() public virtual {
    // Create airdrop token
    TOKEN = new MerkleClaimERC721(
      "My Token", 
      "MT", 
      // Merkle root containing ALICE but no BOB
      0xa21be505af5f5455fad4bcb3d54ccc03f269c5e06945f1dbf6c96dfcb99fcbd0
    );

    // Setup airdrop users
    ALICE = new MerkleClaimERC721User(TOKEN, 0xe66904a5318f27880bf1d20D77Ffa8FBdaC5E5E7); // 0xe66904a5318f27880bf1d20D77Ffa8FBdaC5E5E7
    BOB = new MerkleClaimERC721User(TOKEN, 0x71c7E43E96C1e7bBc4D8eB50e165deeE267770D2); // 0x71c7E43E96C1e7bBc4D8eB50e165deeE267770D2
  }
}
