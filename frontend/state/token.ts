import {config} from "../config"; // Airdrop config
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
function generateLeaf(address: string, value: string): Buffer {
  return Buffer.from(
    // Hash in appropriate Merkle format
    ethers.utils
      .solidityKeccak256(["address", "uint256"], [address, value])
      .slice(2),
    "hex"
  );
}

// Setup merkle tree
const merkleTree = new MerkleTree(
  // Generate leafs
  Object.entries(config.airdrop).map(([address, tokenId]) =>
    generateLeaf(
      ethers.utils.getAddress(address),
      ethers.utils.parseUnits(tokenId.toString(), config.decimals).toString()
    )
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
  const [tokenId, setTokenId] = useState<string | null>(null); // Id of claimable token
  const [alreadyClaimed, setAlreadyClaimed] = useState<boolean>(false); // Claim status
  const [isValidNetwork, setisValidNetwork] = useState<boolean>(false);
  // const [connected, setConnected] = useState<boolean>(false); // Wallet connection

  useEffect(() => {
    // @ts-ignore
    window.ethereum.on("chainChanged", (chainId: string) => {
      setisValidNetwork(parseInt(chainId) === networkId);
    });
  }, [setisValidNetwork]);
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
        "function claim(address _to, uint256 _id, bytes32[] calldata _proof) external",
      ],
      // Get signer from authed provider
      provider?.getSigner()
    );
  };

  /**
   * Collects number of tokens claimable by a user from Merkle tree
   * @param {string} address to check
   */
  const getAirdropId = (address: string): string | null => {
    // If address is in airdrop. convert address to correct checksum
    address = ethers.utils.getAddress(address)

    if (address in config.airdrop) {
      // Return tokenId of address
      return ethers.utils.parseUnits(config.airdrop[address].toString(), config.decimals).toString();
    }

    // Else, return invalidID
    return null;
  };

  /**
   * Collects claim status for an address
   * @param {string} address to check
   * @returns {Promise<boolean>} true if already claimed, false if available
   */
  const getClaimedStatus = async (address: string): Promise<boolean> => {
    if (isValidNetwork) {
      // Collect token contract
      const token: ethers.Contract = getContract();
      // Return claimed status
      return await token.hasClaimed(address);
    }
    showNetworkErrorAlert();
    return false;
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
      const tokenId: string | null = getAirdropId(formattedAddress);
      if (!!tokenId) {
        // Get tokens for address
        // Generate hashed leaf from address
        const leaf: Buffer = generateLeaf(formattedAddress, tokenId);
        // Generate airdrop proof
        const proof: string[] = merkleTree.getHexProof(leaf);

        // Try to claim airdrop and refresh sync status
        try {
          const tx = await token.claim(formattedAddress, Number(tokenId), proof);
          await tx.wait(1);
          await syncStatus();
        } catch (e) {
          console.error(`Error when claiming certificate: ${e}`);
        }
      }
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
      // Collect tokenId for address
      const tokenId = getAirdropId(address);
      setTokenId(tokenId);

      // Collect claimed status for address, if part of airdrop (tokens > 0)
      if (tokenId) {
        const claimed = await getClaimedStatus(address);
        setAlreadyClaimed(claimed);
      }
    }

    // Toggle loading
    setDataLoading(false);
  };

  // On load:
  useEffect(() => {
    // get connected chainId on load
    async function getChainId() {
      // @ts-ignore
      const chainId = parseInt(await window.ethereum.request({ 'method': 'eth_chainId' }));
      setisValidNetwork(chainId === networkId)
    }
    getChainId()
    syncStatus();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [address, isValidNetwork]);

  return {
    dataLoading,
    tokenId,
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
