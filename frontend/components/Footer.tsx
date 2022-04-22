// import Image from "next/image"; // Images
import styles from "styles/components/Footer.module.scss"; // Component styles

export default function Footer() {
  return (
    <div className={styles.footer}>
      <p>Copyright&copy; {new Date().getFullYear()} Web3Bridge.</p>
      <p>All Rights Reserved.</p>
    </div>
  );
}
