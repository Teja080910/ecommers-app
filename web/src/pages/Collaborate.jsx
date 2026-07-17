import PageHeader from "../components/PageHeader";
import Reveal from "../components/Reveal";
import { Icon } from "../components/Icons";
import { COLLABORATE } from "../data/content";
import collaborateImage from "../assets/images/collaborate.png";
import "./collaborate.css";

const FEATURES = [
  {
    icon: "handshake",
    title: "Grow Together",
    desc: "Expand your business and reach more customers with us.",
  },
  {
    icon: "growth",
    title: "Win-Win Partnerships",
    desc: "We believe in long-term relationships and mutual success.",
  },
  {
    icon: "idea",
    title: "Innovate & Create",
    desc: "Collaborate, innovate and bring new ideas to life.",
  },
  {
    icon: "shield",
    title: "Trust & Transparency",
    desc: "Built on trust, honesty and shared goals.",
  },
];

const STRIP = [
  {
    icon: "briefcase",
    title: "Business Alliances",
    desc: "Strategic partnerships for continuous growth.",
  },
  {
    icon: "megaphone",
    title: "Marketing Collaborations",
    desc: "Co-promote and create greater brand value.",
  },
  {
    icon: "settings",
    title: "Technology Integrations",
    desc: "Integrate, innovate and deliver better experiences.",
  },
  {
    icon: "globe",
    title: "Global Opportunities",
    desc: "Expand beyond boundaries together.",
  },
];

export default function Collaborate() {
  return (
    <div>

    

      <section className="collaborate-hero section-pad">

        <div className="container collaborate-inner">

          {/* LEFT */}

          <Reveal>
            <div className="collaborate-left">

              <h1>
                COLLABORATE WITH US
             </h1>

              <span className="collab-label">
                Stronger Together,
                <span> Greater Tomorrow.</span>
              </span>

             

              <p className="collab-desc">
                Join hands with Zipzapcart and grow together.
                Let's create value, reach more people and
                build a better future.
              </p>

              <div className="collab-list">

                {FEATURES.map((item) => (

                  <div className="collab-item" key={item.title}>

                    <div className="collab-icon">
                      <Icon name={item.icon} size={22} />
                    </div>

                    <div>

                      <h4>{item.title}</h4>

                      <p>{item.desc}</p>

                    </div>

                  </div>

                ))}

              </div>

            </div>
          </Reveal>

          {/* RIGHT */}

          <Reveal delay={0.15}>

            <div className="collaborate-right">

              <img
                src={collaborateImage}
                alt="Collaborate with Zipzapcart"
              />

              <div className="partner-box">

                <div className="partner-left">

                  <div className="partner-icon">
                    <Icon name="handshake" size={24} />
                  </div>

                  <div>

                    <h4>Partner with Zipzapcart</h4>

                    <p>
                      Together, we can achieve more
                      and make a lasting impact.
                    </p>

                  </div>

                </div>

                <div className="partner-divider"></div>

                <div className="partner-right">

                  <div className="partner-icon">
                    <Icon name="mail" size={24} />
                  </div>

                  <div>

                    <h4>Let's Connect</h4>

                    <p>support@zipzapcart.com</p>

                  </div>

                </div>

              </div>

            </div>

          </Reveal>

        </div>

        <div className="container">

          <div className="collab-strip">

            {STRIP.map((item) => (

              <div className="strip-card" key={item.title}>

                <div className="strip-icon">
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