// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC721URIStorage } from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol"; // OZ: ERC721URIStorage
import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol"; // OZ: ERC721
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof
import { Ownable } from "@openzeppelin/access/Ownable.sol"; // OZ: MerkleProof

/// @title MerkleClaimERC721
/// @notice ERC721 claimable by members of a merkle tree
/// @author web3bridge CohortVI <contact@web3bridge.com>
/// @dev Solmate ERC721 includes unused _burn logic that can be removed to optimize deployment cost
contract MerkleClaimERC721 is ERC721URIStorage, Ownable {

  /// ============ Mutable storage ============

  /// @notice ERC721-claimee inclusion root
  bytes32 public  merkleRoot;

  /// token id tracker
  uint48 id;
  /// @notice Mapping of addresses who have claimed tokens
  mapping(address => bool) public hasClaimed;

  /// ============ Errors ============

  /// @notice Thrown if address has already claimed
  error AlreadyClaimed();
  /// @notice Thrown if address are not part of Merkle tree
  error NotInMerkle();

  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC721 contract
  /// @param _name of token
  /// @param _symbol of token
  /// @param _merkleRoot of claimees
  constructor(
    string memory _name,
    string memory _symbol,
    bytes32 _merkleRoot
  ) ERC721(_name, _symbol) {
    // _name = _name;
    // _symbol = _symbol;
    merkleRoot = _merkleRoot; // Update root
  }

  /// ============ Events ============

  /// @notice Emitted after a successful token claim
  /// @param to recipient of claim
  /// @param id of token claimed
  event Claim(address indexed to, uint256 id);

  /// @notice emiited after successful merkleRoot change
  /// @param _newRoot new merkleRoot
  event UpdatedRoot(bytes32 _newRoot);

  /// ============ Functions ============

  /// @notice Updates the merkleRoot with the given new root
  /// @param _newRoot new merkleRoot to work with
  function updateMerkleRoot(bytes32 _newRoot) external onlyOwner {
    merkleRoot = _newRoot;
    emit UpdatedRoot(_newRoot);
  }

  /// @notice Allows claiming tokens if address is part of merkle tree
  /// @param to address of claimee
  /// @param _tokenURI of token owed to claimee
  /// @param proof merkle proof to prove address
  function claim(address to, string memory _tokenURI, bytes32[] calldata proof) external {
    // Throw if address has already claimed tokens
    if (hasClaimed[to]) revert AlreadyClaimed();

    // Verify merkle proof, or revert if not in tree
    bytes32 leaf = keccak256(abi.encodePacked(to));
    bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
    if (!isValidLeaf) revert NotInMerkle();

    // Set address to claimed
    hasClaimed[to] = true;

    id++;
    // Mint tokens to address
    _mint(to, id);
    _setTokenURI(id, _tokenURI);

    // Emit claim event
    emit Claim(to, id);
  }
}
// Deployer: 0x4ce64d91e25359443f6d10fe2b7c5e4118114e7a
// Deployed to: 0x67eab3b2be77d8a071ac3e758049ca74106036be
// Transaction hash: 0xa128e47c9864995b4ce0e7d87b0326763b2165c9071da4d8d40279fa597bb86a