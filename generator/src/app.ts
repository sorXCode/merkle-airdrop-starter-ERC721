import { ethers } from "ethers";
import fs from "fs"; // Filesystem
import path from "path"; // Path routing
import Generator from "./generator"; // Generator
import { logger } from "./utils/logger"; // Logging

// Config file path
const configPath: string = path.join(__dirname, "../config.json");
const addr = process.argv[2] ? ethers.utils.getAddress(process.argv[2]) : ""
/**
 * Throws error and exists process
 * @param {string} erorr to log
 */
function throwErrorAndExit(error: string): void {
  logger.error(error);
  process.exit(1);
}

(async () => {
  // Check if config exists
  if (!fs.existsSync(configPath)) {
    throwErrorAndExit("Missing config.json. Please add.");
  }

  // Read config
  const configFile: Buffer = await fs.readFileSync(configPath);
  const configData = JSON.parse(configFile.toString());

  // Check if config contains airdrop key
  if (configData["airdrop"] === undefined) {
    throwErrorAndExit("Missing airdrop param in config. Please add.");
  }

  // Collect config
  const decimals: number = configData.decimals ?? 0;
  const airdrop: Record<string, number> = configData.airdrop;

  // Initialize and call generator
  const generator = new Generator(decimals, airdrop);
  if (!!addr){
    await generator.getProof(addr);
    return;
  }
  logger.info("No address provided, generating root")
  await generator.process();
})();