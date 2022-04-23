import config from "config"; // Airdrop config
import { eth } from "state/eth"; // ETH state provider
import { ethers } from "ethers"; // Ethers
import keccak256 from "keccak256"; // Keccak256 hashing
import MerkleTree from "merkletreejs"; // MerkleTree.js
import { useEffect, useState } from "react"; // React
import { createContainer } from "unstated-next"; // State management
import { networkId } from "./eth";
/**
 * Generate Merkle Tree leaf from address and value
 * @param {string} address of airdrop claimee
 * @param {string} value of airdrop tokens to claimee
 * @returns {Buffer} Merkle Tree node
 */
function generateLeaf(address: string): Buffer {
  return Buffer.from(
    // Hash in appropriate Merkle format
    ethers.utils.solidityKeccak256(["address"], [address]).slice(2),
    "hex"
  );
}

// Setup merkle tree
const merkleTree = new MerkleTree(
  // Generate leafs
  config.airdrop.map((address) =>
    generateLeaf(ethers.utils.getAddress(address))
  ),
  // Hashing function
  keccak256,
  { sortPairs: true }
);

function useToken() {
  // Collect global ETH state
  const {
    address,
    provider,
  }: {
    address: string | null;
    provider: ethers.providers.Web3Provider | null;
  } = eth.useContainer();

  // Local state
  const [dataLoading, setDataLoading] = useState<boolean>(true); // Data retrieval status
  const [numTokens, setNumTokens] = useState<number>(0); // Number of claimable tokens
  const [alreadyClaimed, setAlreadyClaimed] = useState<boolean>(false); // Claim status
  const [isValidNetwork, setisValidNetwork] = useState<boolean>(false);

  useEffect(() => {
    // @ts-ignore
    window.ethereum.on("chainChanged", (chainId: string) => {
      setisValidNetwork(parseInt(chainId) === networkId);
    });
  }, []);
  /**
   * Get contract
   * @returns {ethers.Contract} signer-initialized contract
   */
  const getContract = (): ethers.Contract => {
    return new ethers.Contract(
      // Contract address
      process.env.NEXT_PUBLIC_CONTRACT_ADDRESS ?? "",
      [
        // hasClaimed mapping
        "function hasClaimed(address) public view returns (bool)",
        // Claim function
        "function claim(address to, string memory _tokenURI, bytes32[] calldata proof) external",
      ],
      // Get signer from authed provider
      provider?.getSigner()
    );
  };

  /**
   * Collects number of tokens claimable by a user from Merkle tree
   * @param {string} address to check
   */
  const getAirdropAmount = (address: string): number => {
    // If address is in airdrop. convert address to correct checksum
    address = ethers.utils.getAddress(address);

    if (config.airdrop.includes(address)) {
      // Return number of tokens available
      return 1;
    }

    // Else, return 0 tokens
    return 0;
  };

  /**
   * Collects claim status for an address
   * @param {string} address to check
   * @returns {Promise<boolean>} true if already claimed, false if available
   */
  const getClaimedStatus = async (address: string): Promise<boolean | void> => {
    if (isValidNetwork) {
      // Collect token contract
      const token: ethers.Contract = getContract();
      // Return claimed status
      return await token.hasClaimed(address);
    }
    showNetworkErrorAlert();
  };

  const claimAirdrop = async (): Promise<void> => {
    if (isValidNetwork) {
      // If not authenticated throw
      if (!address) {
        throw new Error("Not Authenticated");
      }

      // Collect token contract
      const token: ethers.Contract = getContract();
      // Get properly formatted address
      const formattedAddress: string = ethers.utils.getAddress(address);
      // Get tokens for address
      const _tokenURI: string =
        "ipfs://QmQjC6am2aGgC83Xy7nAXVYeQSr6JG3REECLp6AUZHAJDc";

      // Generate hashed leaf from address
      const leaf: Buffer = generateLeaf(formattedAddress);
      // Generate airdrop proof
      const proof: string[] = merkleTree.getHexProof(leaf);

      // Try to claim airdrop and refresh sync status
      try {
        const tx = await token.claim(formattedAddress, _tokenURI, proof);
        await tx.wait(1);
        await syncStatus();
      } catch (e) {
        console.error(`Error when claiming certificate: ${e}`);
      }
    } else {
      showNetworkErrorAlert();
    }
  };

  /**
   * After authentication, update number of tokens to claim + claim status
   */
  const syncStatus = async (): Promise<void> => {
    // Toggle loading
    setDataLoading(true);

    // Force authentication
    if (address) {
      // Collect number of tokens for address
      const tokens = getAirdropAmount(address);
      setNumTokens(tokens);

      // Collect claimed status for address, if part of airdrop (tokens > 0)
      if (tokens > 0) {
        const claimed = await getClaimedStatus(address);
        setAlreadyClaimed(true);
      }
    }

    // Toggle loading
    setDataLoading(false);
  };

  // On load:
  useEffect(() => {
    syncStatus();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [address]);

  return {
    dataLoading,
    numTokens,
    alreadyClaimed,
    claimAirdrop,
  };
}

// Create unstated-next container
export const token = createContainer(useToken);
function showNetworkErrorAlert() {
  alert(
    `Invalid Network, please connect to ${process.env.NEXT_PUBLIC_RPC_NETWORK_NAME}`
  );
}
