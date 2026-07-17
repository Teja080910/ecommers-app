
import Reveal from "../components/Reveal";
import PhoneMock from "../components/PhoneMock";
import CartMock from "../components/CartMock";
import { Icon } from "../components/Icons";
import { OUR_COMPANY, HOME_FEATURES } from "../data/content";
import "./ourcompany.css";

export default function OurCompany() {
  return (
    <div>
      <section className="section-pad about-showcase">
        <div className="container about-showcase-grid">
          <Reveal>
            <div className="about-showcase-left">
              <h2 className="about-showcase-title">
                About <span>Zipzapcart</span>
              </h2>
              <p className="about-showcase-body">{OUR_COMPANY.body}</p>
              <div className="about-showcase-visual">
                <PhoneMock />
                <CartMock />
              </div>
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <div className="about-feature-list">
              {HOME_FEATURES.map((f, i) => (
                <Reveal key={f.title} delay={0.08 * i}>
                  <div className="about-feature-row">
                    <div className="about-feature-icon">
                      <Icon name={f.icon} size={22} />
                    </div>
                    <div>
                      <h3>{f.title}</h3>
                      <p>{f.desc}</p>
                    </div>
                  </div>
                </Reveal>
              ))}
            </div>
          </Reveal>
        </div>
      </section>
    </div>
  );
}