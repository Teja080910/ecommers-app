
import { Icon } from "./Icons";
import appScreenshot from "../assets/images/app-home-screenshot.jpeg";
import "./phonemock.css";

export default function PhoneMock() {
  const isMobile = window.innerWidth <= 768;

  return (
    <div className="phone-scene">
      <div
        className="phone-glow"
        animate={
          isMobile
            ? {}
            : {
                scale: [1, 1.08, 1],
                opacity: [0.55, 0.8, 0.55],
              }
        }
        transition={
          isMobile
            ? { duration: 0 }
            : {
                duration: 5,
                repeat: Infinity,
                ease: "easeInOut",
              }
        }
      />

      <div
        className="phone-shell"
        initial={
          isMobile
            ? false
            : {
                y: 40,
                opacity: 0,
                rotate: -2,
              }
        }
        animate={
          isMobile
            ? {}
            : {
                y: 0,
                opacity: 1,
                rotate: 0,
              }
        }
        transition={
          isMobile
            ? { duration: 0 }
            : {
                duration: 0.9,
                ease: [0.16, 1, 0.3, 1],
              }
        }
      >
        <div className="phone-notch" />

        <div className="phone-screen phone-screen-img">
          <img
            src={appScreenshot}
            alt="Zipzapcart app home screen"
          />
        </div>

        <div className="phone-home-bar" />
      </div>

      
    </div>
  );
}