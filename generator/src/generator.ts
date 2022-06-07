import fs from "fs"; // Filesystem
import path from "path"; // Path
import keccak256 from "keccak256"; // Keccak256 hashing
import MerkleTree from "merkletreejs"; // MerkleTree.js
import { logger } from "./utils/logger"; // Logging
import { getAddress, parseUnits, solidityKeccak256 } from "ethers/lib/utils"; // Ethers utils

// Output file path
const outputPath: string = path.join(__dirname, "../merkle.json");

// Airdrop recipient addresses and scaled token values
type AirdropRecipient = {
  // Recipient address
  address: string;
  // Scaled-to-decimals token value
  value: string;
};

export default class Generator {
  airdrop: Record<string, string> = {};
  // Airdrop recipients
  recipients: AirdropRecipient[] = [];

  // Generate merkle tree
  merkleTree: MerkleTree;

  /**
   * Setup generator
   * @param {number} decimals of token
   * @param {Record<string, number>} airdrop address to token claim mapping
   */
  constructor(decimals: number, airdrop: Record<string, number>) {
    // For each airdrop entry
    for (const [address, tokens] of Object.entries(airdrop)) {
      // entry
      const entry = {
        // Checksum address
        address: address,
        // Scaled number of tokens claimable by recipient
        value: parseUnits(tokens.toString(), decimals).toString()
      }
      // Push:
      this.recipients.push(entry);
      this.airdrop[entry.address] = entry.value;
    }

    this.merkleTree =  new MerkleTree(
      // Generate leafs
      this.recipients.map(({ address, value }) =>
        this.generateLeaf(address, value)
      ),
      // Hashing function
      keccak256,
      { sortPairs: true }
    );
  }

  /**
   * Generate Merkle Tree leaf from address and value
   * @param {string} address of airdrop claimee
   * @param {string} value of airdrop tokens to claimee
   * @returns {Buffer} Merkle Tree node
   */
  generateLeaf(address: string, value: string): Buffer {
    return Buffer.from(
      // Hash in appropriate Merkle format
      solidityKeccak256(["address", "string"], [address, value]).slice(2),
      "hex"
    );
  }


  async process(): Promise<void> {
    logger.info("Generating Merkle tree.");


    // Collect and log merkle root
    const merkleRoot: string = this.merkleTree.getHexRoot();
    logger.info(`Generated Merkle root: ${merkleRoot}`);
    
    // Collect and save merkle tree + root
    await fs.writeFileSync(
      // Output to merkle.json
      outputPath,
      // Root + full tree
      JSON.stringify({
        root: merkleRoot,
        tree: this.merkleTree
      })
    );
    logger.info("Generated merkle tree and root saved to Merkle.json.");
  }

  getProof(address: string): string[] {
    const value = this.airdrop[address];
    const leaf = this.generateLeaf(address, value);
    const proof = this.merkleTree.getHexProof(leaf);
    console.log("Proof for ", address);
    console.log(proof);
    // console.log(this.merkleTree.verify(proof, leaf, "0x47e9b69fae42cb82b4cbb7d96c3c47f8714c7f47bd3d40ce0dd87456270abad2"))
    return proof;
  }
}