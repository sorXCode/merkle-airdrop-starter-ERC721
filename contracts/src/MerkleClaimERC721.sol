// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC721URIStorage } from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol"; // OZ: ERC721URIStorage
import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol"; // OZ: ERC721
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof
import { Ownable } from "@openzeppelin/access/Ownable.sol"; // OZ: MerkleProof

import "@openzeppelin/utils/Strings.sol"; // OZ: Convert uint to string

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

  // token baseURI
  string baseURI = "ipfs://bafybeigceihbii6flqhdtnvleu4wiwbsekbju2hzbsjjw2nmv5u752fywq/";

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

  /// @notice emiited after successful baseURI change
  /// @param _newBaseURI new baseURI
  event UpdatedBaseURI(string _newBaseURI);
  

  /// ============ Functions ============

  /// @notice Updates the merkleRoot with the given new root
  /// @param _newRoot new merkleRoot to work with
  function updateMerkleRoot(bytes32 _newRoot) external onlyOwner {
    merkleRoot = _newRoot;
    emit UpdatedRoot(_newRoot);
  }

  function updateBaseURI(string memory _newURI) external onlyOwner {
    baseURI = _newURI;
    emit UpdatedBaseURI(_newURI);
  }

  function convertUintToString(uint256 x) pure internal returns(string memory){
        return Strings.toString(x);
    }

  /// @notice Allows claiming tokens if address is part of merkle tree
  /// @param _to address of claimee
  /// @param _id id of the token to claim
  /// @param _proof merkle proof to prove address
  function claim(address _to, uint256 _id, bytes32[] calldata _proof) external {
    // Converts _id from uint256 to string 
    string memory _tokenId = convertUintToString(_id);
    
    // Throw if address has already claimed tokens
    if (hasClaimed[_to]) revert AlreadyClaimed();

    // Verify merkle proof, or revert if not in tree
    bytes32 leaf = keccak256(abi.encodePacked(_to, _tokenId));
    bool isValidLeaf = MerkleProof.verify(_proof, merkleRoot, leaf);
    if (!isValidLeaf) revert NotInMerkle();

    // Set address to claimed
    hasClaimed[_to] = true;

    id++;
    // Mint token to address
    _mint(_to, id);
    _setTokenURI(id, string(abi.encodePacked(baseURI, _tokenId, ".jpeg")));

    // Emit claim event
    emit Claim(_to, id);
  }
}

