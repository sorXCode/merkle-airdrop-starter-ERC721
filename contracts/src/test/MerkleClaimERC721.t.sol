// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/// ============ Imports ============

import { MerkleClaimERC721Test } from "./utils/MerkleClaimERC721Test.sol"; // Test scaffolding

/// @title Tests
/// @notice MerkleClaimERC721 tests
/// @author Anish Agnihotri <contact@anishagnihotri.com>
contract Tests is MerkleClaimERC721Test {
    // Setup correct proof for Alice
    bytes32[5] aliceProof = [
      bytes32(0x0b3da53306c1495659b5cc9f744ea981c2a3f127b250e5c8caedfaa97c0e676b),
      bytes32(0x3bf2db328f72a7b881246c777705344a7272736afde1cc2753f0948920f8e123),
      bytes32(0xd63c190d9628e0aea5a46c368f46467e98b766ab168992dbe62db8abccad0798),
      bytes32(0x82284e869d05827e4670ce9699ee08d165eacccfa53e56ea0214300eab2f009a),
      bytes32(0xe2cdd186abccbe4745f410c91aee16804f311a566d45c00273f006d9d21e0b6f)
    ];

  function getAliceProof() internal view returns (bytes32[] memory _aliceProof){
    _aliceProof = new bytes32[](5);
    for (uint8 i = 0; i < aliceProof.length; i++) {
      _aliceProof[i] = aliceProof[i];
    }
  }
    

  /// @notice Allow Alice to claim 1 tokens
  function testAliceClaim() public {
    // Collect Alice balance of tokens before claim
    uint256 alicePreBalance = ALICE.tokenBalance();

    // Claim tokens
    ALICE.claim(
      // Claiming for Alice
      ALICE.ADDRESS(),
      // 1 tokens
      "ipfs://unknown",
      // With valid proof
      getAliceProof()
    );

    // Collect Alice balance of tokens after claim
    uint256 alicePostBalance = ALICE.tokenBalance();

    // Assert Alice balance before + 1 token = after balance
    assertEq(alicePostBalance, alicePreBalance + 1);
  }

  /// @notice Prevent Alice from claiming twice
  function testFailAliceClaimTwice() public {
    // Claim tokens
    ALICE.claim(
      // Claiming for Alice
      ALICE.ADDRESS(),
      // 1 token
      "ipfs://unknown",
      // With valid proof
      getAliceProof()
    );

    // Claim tokens again
    ALICE.claim(
      // Claiming for Alice
      ALICE.ADDRESS(),
      // 1 token
      "ipfs://unknown",
      // With valid proof
      getAliceProof()
    );
  }

  /// @notice Prevent Alice from claiming with invalid proof
  function testFailAliceClaimInvalidProof() public {
    // Setup incorrect proof for Alice
    bytes32[] memory _aliceProof = new bytes32[](1);
    _aliceProof[0] = 0xc11ae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

    // Claim tokens
    ALICE.claim(
      // Claiming for Alice
      address(ALICE),
      // 100 tokens
      "ipfs://unknown",
      // With valid proof
      _aliceProof
    );
  }

  /// @notice Prevent Bob from claiming
  function testFailBobClaim() public {
    // Setup correct proof for Alice
    bytes32[] memory _aliceProof = new bytes32[](1);
    _aliceProof[0] = 0xceeae64152a2deaf8c661fccd5645458ba20261b16d2f6e090fe908b0ac9ca88;

    // Claim tokens
    BOB.claim(
      // Claiming for Bob
      BOB.ADDRESS(),
      // 1 token
      "ipfs://unknown",
      // With valid proof (for Alice)
      _aliceProof
    );
  }

  /// @notice Let Bob claim on behalf of Alice
  function testBobClaimForAlice() public {
    // Collect Alice balance of tokens before claim
    uint256 alicePreBalance = ALICE.tokenBalance();

    // Claim tokens
    BOB.claim(
      // Claiming for Alice
      ALICE.ADDRESS(),
      // 1 token
      "ipfs://unknown",
      // With valid proof (for Alice)
      getAliceProof()
    );

    // Collect Alice balance of tokens after claim
    uint256 alicePostBalance = ALICE.tokenBalance();

    // Assert Alice balance before + 100 tokens = after balance
    assertEq(alicePostBalance, alicePreBalance + 1);
  }
}
