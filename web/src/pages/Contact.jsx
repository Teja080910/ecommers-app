import PageHeader from "../components/PageHeader";
import Reveal from "../components/Reveal";
import { Icon } from "../components/Icons";
import { CONTACT } from "../data/content";
import contactPoster from "../assets/images/contact.png"; 
import "./contact.css";

const CONTACT_ITEMS = [
  {
    icon: "phone",
    title: CONTACT.phone,
    sub: CONTACT.phoneHours,
  },
  {
    icon: "mail",
    title: CONTACT.email,
    sub: CONTACT.emailNote,
  },
  {
    icon: "pin",
    title: CONTACT.addressLines[0],
    sub: CONTACT.addressLines.slice(1).join(" "),
  },
  {
    icon: "globe",
    title: CONTACT.website,
    sub: "Visit our website",
  },
];

const FEATURES = [
  {
    icon: "shield",
    title: "Quick Support",
    desc: "We're here to help anytime.",
  },
  {
    icon: "support",
    title: "Expert Team",
    desc: "Friendly experts ready to assist.",
  },
  {
    icon: "clock",
    title: "Fast Response",
    desc: "We value your time and respond fast.",
  },
  {
    icon: "heart",
    title: "Your Satisfaction",
    desc: "Your happiness is our priority.",
  },
];

export default function Contact() {
  return (
    <div>

      

      <section className="contact-hero section-pad">

        <div className="container contact-hero-inner">

          {/* LEFT */}

          <Reveal>
            <div className="contact-left">

              

              <h1>
               CONTACT US
              </h1>
               <span className="page-badge">
               We're Here To
                Help!</span>

              <p className="contact-desc">
                Have a question, feedback or need support?
                Reach out to us, we'd love to hear from you.
              </p>

              <div className="contact-details">

                {CONTACT_ITEMS.map((item) => (

                  <div className="contact-item" key={item.title}>

                    <div className="contact-item-icon">
                      <Icon name={item.icon} size={20} />
                    </div>

                    <div className="contact-text">

                      <h4>{item.title}</h4>

                      <p>{item.sub}</p>

                    </div>

                  </div>

                ))}

              </div>

            </div>
          </Reveal>

          {/* RIGHT IMAGE */}

          <Reveal delay={0.15}>

            <div className="contact-right">

              <img
                src={contactPoster}
                alt="Contact Zipzapcart"
              />

            </div>

          </Reveal>

        </div>

        {/* Bottom Features */}

        <div className="container">

          <div className="contact-bottom">

            {FEATURES.map((item) => (

              <div className="bottom-card" key={item.title}>

                <div className="bottom-icon">
                  <Icon name={item.icon} size={24} />
                </div>

                <div>

                  <h4>{item.title}</h4>

                  <p>{item.desc}</p>

                </div>

              </div>

            ))}

          </div>

        </div>

      </section>

    </div>
  );
}