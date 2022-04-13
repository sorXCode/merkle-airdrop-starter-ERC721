import { ethers } from "ethers";
import keccak256 from "keccak256";
import MerkleTree from "merkletreejs";

const config = require("../config-nft.json");
// Get properly formatted address
// @ts-ignore
const formattedAddress: string = ethers.utils.getAddress(process.argv.slice(-1)[0]);
// Setup merkle tree
const merkleTree = new MerkleTree(
    // Generate leafs
    // @ts-ignore
    config.airdrop.map((address) =>
      generateLeaf(
        ethers.utils.getAddress(address),
      )
    ),
    // Hashing function
    keccak256,
    { sortPairs: true }
  );
  

function generateLeaf(address: string): Buffer {
    return Buffer.from(
      // Hash in appropriate Merkle format
      ethers.utils
        .solidityKeccak256(["address"], [address])
        .slice(2),
      "hex"
    );
  }

// Generate hashed leaf from address
const leaf: Buffer = generateLeaf(formattedAddress);
// Generate airdrop proof
const proof: string[] = merkleTree.getHexProof(leaf);
console.log(proof)