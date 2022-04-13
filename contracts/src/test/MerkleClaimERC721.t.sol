// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/// ============ Imports ============

import { MerkleClaimERC721Test } from "./utils/MerkleClaimERC721Test.sol"; // Test scaffolding

/// @title Tests
/// @notice MerkleClaimERC721 tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract Tests is MerkleClaimERC721Test {
  /// @notice Allow Alice to claim 100e18 tokens
  function testAliceClaim() public {
    // Setup correct proof for Alice
    bytes32[] memory aliceProof = new bytes32[](5);
    
    aliceProof[0] = 0x0b3da53306c1495659b5cc9f744ea981c2a3f127b250e5c8caedfaa97c0e676b;
    aliceProof[1] = 0x3bf2db328f72a7b881246c777705344a7272736afde1cc2753f0948920f8e123;
    aliceProof[2] = 0xd63c190d9628e0aea5a46c368f46467e98b766ab168992dbe62db8abccad0798;
    aliceProof[3] = 0x82284e869d05827e4670ce9699ee08d165eacccfa53e56ea0214300eab2f009a;
    aliceProof[4] = 0xe2cdd186abccbe4745f410c91aee16804f311a566d45c00273f006d9d21e0b6f;

    // Collect Alice balance of tokens before claim
    uint256 alicePreBalance = ALICE.tokenBalance();

    // Claim tokens
    ALICE.claim(
      // Claiming for Alice
      ALICE.ADDRESS(),
      // 100 tokens
      "ipfs://unknown",
      // With valid proof
      aliceProof
    );

    // Collect Alice balance of tokens after claim
    uint256 alicePostBalance = ALICE.tokenBalance();

    // Assert Alice balance before + 1 token = after balance
    assertEq(alicePostBalance, alicePreBalance + 1);
  }

  // /// @notice Prevent Alice from claiming twice
  // function testFailAliceClaimTwice() public {
  //   // Setup correct proof for Alice
  //   bytes32[] memory aliceProof = new bytes32[](1);
  //   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

  //   // Claim tokens
  //   ALICE.claim(
  //     // Claiming for Alice
  //     address(ALICE),
  //     // 100 tokens
  //     "ipfs://unknown",
  //     // With valid proof
  //     aliceProof
  //   );

  //   // Claim tokens again
  //   ALICE.claim(
  //     // Claiming for Alice
  //     address(ALICE),
  //     // 100 tokens
  //     "ipfs://unknown",
  //     // With valid proof
  //     aliceProof
  //   );
  // }

  // /// @notice Prevent Alice from claiming with invalid proof
  // function testFailAliceClaimInvalidProof() public {
  //   // Setup incorrect proof for Alice
  //   bytes32[] memory aliceProof = new bytes32[](1);
  //   aliceProof[0] = 0xc11ae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

  //   // Claim tokens
  //   ALICE.claim(
  //     // Claiming for Alice
  //     address(ALICE),
  //     // 100 tokens
  //     "ipfs://unknown",
  //     // With valid proof
  //     aliceProof
  //   );
  // }

  // /// @notice Prevent Alice from claiming with invalid amount
  // function testFailAliceClaimInvalidAmount() public {
  //   // Setup correct proof for Alice
  //   bytes32[] memory aliceProof = new bytes32[](1);
  //   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

  //   // Claim tokens
  //   ALICE.claim(
  //     // Claiming for Alice
  //     address(ALICE),
  //     // Incorrect: 1000 tokens
  //     "ipfs://unknown",
  //     // With valid proof (for 100 tokens)
  //     aliceProof
  //   );
  // }

  // /// @notice Prevent Bob from claiming
  // function testFailBobClaim() public {
  //   // Setup correct proof for Alice
  //   bytes32[] memory aliceProof = new bytes32[](1);
  //   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

  //   // Claim tokens
  //   BOB.claim(
  //     // Claiming for Bob
  //     address(BOB),
  //     // 100 tokens
  //     "ipfs://unknown",
  //     // With valid proof (for Alice)
  //     aliceProof
  //   );
  // }

  // /// @notice Let Bob claim on behalf of Alice
  // function testBobClaimForAlice() public {
  //   // Setup correct proof for Alice
  //   bytes32[] memory aliceProof = new bytes32[](1);
  //   aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

  //   // Collect Alice balance of tokens before claim
  //   uint256 alicePreBalance = ALICE.tokenBalance();

  //   // Claim tokens
  //   BOB.claim(
  //     // Claiming for Alice
  //     address(ALICE),
  //     // 100 tokens
  //     "ipfs://unknown",
  //     // With valid proof (for Alice)
  //     aliceProof
  //   );

  //   // Collect Alice balance of tokens after claim
  //   uint256 alicePostBalance = ALICE.tokenBalance();

  //   // Assert Alice balance before + 100 tokens = after balance
  //   assertEq(alicePostBalance, alicePreBalance + 100e18);
  // }
}
