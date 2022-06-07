import { eth } from "state/eth"; // Global state: ETH
import { useState } from "react"; // State management
import { token } from "state/token"; // Global state: Tokens
import Layout from "components/Layout"; // Layout wrapper
import styles from "styles/pages/Claim.module.scss"; // Page styles
// import { AddressList } from '../components/addresses';

import {config} from "config";


export default function Claim() {
  const addressList = config.airdrop;
  // Global ETH state
  const { address, unlock }: { address: string | null; unlock: Function } =
    eth.useContainer();
  // Global token state
  const {
    dataLoading,
    tokenId,
    alreadyClaimed,
    claimAirdrop,
  }: {
    dataLoading: boolean;
    tokenId: string |  null;
    alreadyClaimed: boolean;
    claimAirdrop: Function;
  } = token.useContainer();

  // Local button loading
  const [buttonLoading, setButtonLoading] = useState<boolean>(false);

  const addLink = () => {
    if (typeof address==='string') {
      let index = addressList[address];
      location.href = `https://bafybeigceihbii6flqhdtnvleu4wiwbsekbju2hzbsjjw2nmv5u752fywq.ipfs.dweb.link/${index}.jpeg`;
    }
  }
  /**
   * Claims airdrop with local button loading
   */
  const claimWithLoading = async () => {
    setButtonLoading(true); // Toggle
    await claimAirdrop(); // Claim
    setButtonLoading(false); // Toggle
  };
  return (
    <Layout>
      <div className={styles.claim}>
        {!address ? (
          // Not authenticated
          <div className={styles.card}>
            <h1>You are not authenticated.</h1>
            <p>Please connect your wallet to claim your certificate.</p>
            <button onClick={() => unlock()}>Connect Wallet</button>
          </div>
        ) : dataLoading ? (
          // Loading details about address
          <div className={styles.card}>
            <h1>Loading details...</h1>
            <p>Please hold while we collect details about your address.</p>
          </div>
        ) : tokenId===null ? (
          // Not part of airdrop
          <div className={styles.card}>
            <h1>Ineligible Address</h1>
            <p>
              Sorry, your address is not eligible to claim a Web3Bridge
              certificate.
            </p>
          </div>
        ) : alreadyClaimed ? (
          // Already claimed airdrop
          <div className={styles.card}>
            <h1>Congratulations!</h1>
            <p>
              Your address ({address}) <br /> has successfully claimed a
              Web3Bridge Certificate.
            </p>
            <button onClick={addLink}>

              View
              {/* </a> */}
            </button>
          </div>
        ) : (
          // Claim your airdrop
          <div className={styles.card}>
            <h1>Claim your certificate.</h1>

            <p>Your address qualifies for a Web3Bridge Certificate.</p>
            <button onClick={claimWithLoading} disabled={buttonLoading}>
              {buttonLoading ? "Claiming Certificate..." : "Claim Certificate"}
            </button>
          </div>
        )}
      </div>
    </Layout>
  );
}
