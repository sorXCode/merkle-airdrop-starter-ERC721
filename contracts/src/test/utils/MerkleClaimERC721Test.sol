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
      // Merkle root containing ALICE with 100e18 tokens but no BOB
      0x5c3367e95591e7841be6b927bc0bd8a05ea58107336f32be0da1143b45506198
    );

    // Setup airdrop users
    ALICE = new MerkleClaimERC721User(TOKEN); // 0x185a4dc360ce69bdccee33b3784b0282f7961aea
    BOB = new MerkleClaimERC721User(TOKEN); // 0xefc56627233b02ea95bae7e19f648d7dcd5bb132
  }
}
