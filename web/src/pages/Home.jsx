import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import Reveal from "../components/Reveal";
import PhoneMock from "../components/PhoneMock";
import { Icon } from "../components/Icons";
import { PLAYSTORE_URL } from "../data/content";
import "./home.css";

const floatingCards = [
  {
    icon: "bag",
    title: "Shopping",
    top: "9%",
    left: "-8%",
    delay: 0,
  },
  {
    icon: "truck",
    title: "Fast Delivery",
    top: "20%",
    right: "-8%",
    delay: .4,
  },
  {
    icon: "percent",
    title: "Mega Offers",
    bottom: "22%",
    left: "-10%",
    delay: .8,
  },
  {
    icon: "shield",
    title: "Secure Payment",
    bottom: "8%",
    right: "-8%",
    delay: 1.2,
  },
];

export default function Home() {

  return (

<div className="home">

<section className="hero">

<div className="hero-circle hero-circle-one"></div>
<div className="hero-circle hero-circle-two"></div>

<div className="container hero-container">

<div className="hero-left">



<Reveal delay={.08}>
<h1 className="hero-title">
  Everything You Need,
  <br></br>
  <span> Delivered In A Zip.</span>
</h1>

</Reveal>

<Reveal delay={.16}>

<p className="hero-description">
  Zipzapcart is your one-stop shopping destination bringing groceries,
  fashion, electronics, beauty and daily essentials together in one
  beautiful mobile shopping experience.
</p>

</Reveal>

<Reveal delay={.24}>

<div className="hero-buttons">

<a
href={PLAYSTORE_URL}
target="_blank"
rel="noreferrer"
className="btn btn-primary hero-download"
>

Download App

<Icon name="arrow-right" size={18}/>

</a>

<Link
to="/our-company"
className="btn btn-outline"
>

Learn More

</Link>

</div>

</Reveal>

<Reveal delay={.32}>

<div className="stats-card">
   <div>
    <h2>1000+</h2>
    <p>Users</p>
  </div>
  <div className="line"/>

<div>

<h2>5000+</h2>

<p>Products</p>

</div>

<div className="line"/>

<div>

<h2>100+</h2>

<p>Brands</p>

</div>

<div className="line"/>

<div>

<h2>24×7</h2>

<p>Support</p>

</div>

<div className="line"/>

<div>

<h2>Fast</h2>

<p>Delivery</p>

</div>

</div>

</Reveal>

</div>

<div className="hero-right">

<div className="phone-glow"/>

<div

className="phone-wrapper"

initial={{
opacity:0,
scale:.85,
y:50
}}

animate={{
opacity:1,
scale:1,
y:0
}}

transition={{
duration:1,
ease:[0.16,1,0.3,1]
}}

>

<PhoneMock/>

</div>

{

floatingCards.map((card)=>(

<motion.div

key={card.title}

className="floating-card"

style={{

top:card.top,

bottom:card.bottom,

left:card.left,

right:card.right

}}

animate={{

y:[0,-12,0]

}}

transition={{

duration:4,

repeat:Infinity,

delay:card.delay

}}

>

<div className="floating-icon">

<Icon
name={card.icon}
size={18}
/>

</div>

<span>

{card.title}

</span>

</motion.div>

))

}

</div>

</div>

</section>

</div>

  );

}