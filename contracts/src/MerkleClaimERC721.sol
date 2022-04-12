// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC721URIStorage } from "openzepellin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // OZ: ERC721URIStorage
import { ERC721 } from "openzepellin/contracts/token/ERC721/ERC721.sol"; // OZ: ERC721
import { MerkleProof } from "openzepellin/contracts/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof

/// @title MerkleClaimERC721
/// @notice ERC721 claimable by members of a merkle tree
/// @author web3bridge CohortVI <contact@web3bridge.com>
/// @dev Solmate ERC721 includes unused _burn logic that can be removed to optimize deployment cost
contract MerkleClaimERC721 is ERC721URIStorage {

  /// ============ Immutable storage ============

  /// @notice ERC721-claimee inclusion root
  bytes32 public immutable merkleRoot;

  /// ============ Mutable storage ============
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

  /// ============ Functions ============

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
// Deployed to: 0x0c3e8c9cfdce18663c735b6e6b619689a2cd1cdd
// Transaction hash: 0x19200209d191ca94b8e8463732709759101694424066f9f7779c07fcb04f295d
// ["0xe9707d0e6171f728f7473c24cc0432a9b07eaaf1efed6a137a4a8c12c79552d9", "0x343750465941b29921f50a28e0e43050e5e1c2611a3ea8d7fe1001090d5e1436"]