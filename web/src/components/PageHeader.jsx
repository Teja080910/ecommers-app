import Reveal from "./Reveal";
import "./pageheader.css";

export default function PageHeader({ eyebrow, title, sub }) {
  return (
    <section className="page-header">
      <div className="page-header-glow" aria-hidden="true" />
      <div className="container">
        <Reveal><span className="eyebrow">{eyebrow}</span></Reveal>
        <Reveal delay={0.06}><h1>{title}</h1></Reveal>
        {sub && <Reveal delay={0.12}><p>{sub}</p></Reveal>}
      </div>
    </section>
  );
}
