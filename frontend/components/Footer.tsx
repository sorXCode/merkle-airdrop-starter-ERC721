// import Image from "next/image"; // Images
import styles from "styles/components/Footer.module.scss"; // Component styles

// /**
//  * Links to render in footer
//  * @dev Does not render any links where url is undefined, allowing conditional rendering
//  */
// const footerLinks: { icon: string; url: string | undefined }[] = [
//   // Discord
//   { icon: "/icons/discord.svg", url: process.env.NEXT_PUBLIC_DISCORD },
//   // Twitter
//   { icon: "/icons/twitter.svg", url: process.env.NEXT_PUBLIC_TWITTER },
//   // Github
//   { icon: "/icons/github.svg", url: process.env.NEXT_PUBLIC_GITHUB },
// ];

export default function Footer() {
  return (
    <div className={styles.footer}>
      <p>Copyright&copy; {new Date().getFullYear()} Web3Bridge.</p>
      <p>All Rights Reserved.</p>

      {/* {footerLinks.map(({ icon, url }, i) => {
        // For each link in footer that is valid
        return url ? (
          // Render link with icon image
          <a href={url} target="_blank" rel="noopener noreferrer" key={i}>
            <Image
              className="icons"
              src={icon}
              alt="Social link"
              width={30}
              height={30}
            />
            <style jsx global>
              {`
                a .icons {
                  opacity: 1;
                  filter: contrast(0);
                }
                a:hover .icons {
                  opacity: 1;
                  filter: brightness(10);
                }
              `}
            </style>
          </a>
        ) : null;
      })} */}
    </div>
  );
}
