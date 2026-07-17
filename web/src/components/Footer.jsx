import { Link } from "react-router-dom";
import { NAV_LINKS, CONTACT, PLAYSTORE_URL } from "../data/content";
import { Icon } from "./Icons";
import logo from "../assets/logo/logo.png";
import "./footer.css";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="container footer-top">
        <div className="footer-brand">
          <img src={logo} alt="Zipzapcart" className="footer-logo" />
          <p className="footer-tagline">Shop Smart, Live Better</p>
          <p className="footer-desc">
            Your one-stop e-commerce app for quality products, best deals and a
            seamless shopping experience — right to your fingertips.
          </p>
        </div>

        <div className="footer-col">
          <h4>Explore</h4>
          <ul>
            {NAV_LINKS.map((l) => (
              <li key={l.to}><Link to={l.to}>{l.label}</Link></li>
            ))}
          </ul>
        </div>

        <div className="footer-col">
          <h4>Get in touch</h4>
          <ul className="footer-contact">
            <li><Icon name="phone" size={16} /><span>{CONTACT.phone}</span></li>
            <li><Icon name="mail" size={16} /><span>{CONTACT.email}</span></li>
            <li><Icon name="pin" size={16} /><span>{CONTACT.addressLines.join(" ")}</span></li>
          </ul>
        </div>

      
      </div>

      <div className="container footer-bottom ">
        <p>© {new Date().getFullYear()} Zipzapcart. All rights reserved.</p>
        
      </div>
    </footer>
  );
}
