import Reveal from "../components/Reveal";
import { Icon } from "../components/Icons";
import futureImage from "../assets/images/future.jpeg";
import "./future.css";

export default function Future() {
  const features = [
    {
      icon: "ai",
      title: "AI Powered Shopping",
      desc: "Smart recommendations for you",
    },
    {
      icon: "truck",
      title: "Lightning Fast Delivery",
      desc: "Same day or next day delivery",
    },
    {
      icon: "shield",
      title: "Secure & Trusted",
      desc: "100% secure payments & data",
    },
    {
      icon: "support",
      title: "24x7 Customer Support",
      desc: "Hum hamesha aapke saath",
    },
  ];

  return (
    <section className="future-page">
      <div className="container">

        <div className="future-hero">

          {/* LEFT */}

          <Reveal>
            <div className="future-left">

              <h1>
                FUTURE
              </h1>

           <span className="future-badge">Humara Vision, Aapka Bharosa</span>

              

              <p>
                Zipzapcart ka future hai smart, fast aur secure shopping
                experience dena har ghar tak.
              </p>

              <div className="feature-list">

                {features.map((item) => (
                  <div className="feature-card" key={item.title}>

                    <div className="feature-icon">
                      <Icon name={item.icon} size={22} />
                    </div>

                    <div>
                      <h4>{item.title}</h4>
                      <span>{item.desc}</span>
                    </div>

                  </div>
                ))}

              </div>

            </div>
          </Reveal>

          {/* RIGHT */}

          <Reveal>
            <div className="future-right">
              <img
                src={futureImage}
                alt="Future"
              />
            </div>
          </Reveal>

        </div>

        <div className="future-bottom">

          <div>
            <h3>One App</h3>
            <p>All Solutions</p>
          </div>

          <div>
            <h3>Wide Range</h3>
            <p>Products</p>
          </div>

          <div>
            <h3>Best Prices</h3>
            <p>Everyday</p>
          </div>

          <div>
            <h3>Sustainable</h3>
            <p>Future</p>
          </div>

          <div>
            <h3>Customer First</h3>
            <p>Always</p>
          </div>

        </div>

      </div>
    </section>
  );
}