// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.6;
interface IMerkleClaimERC721 {
  function updateMerkleRoot(bytes32 _newRoot) external;
  function claim(address _to, uint256 _id, bytes32[] calldata _proof) external;
}
