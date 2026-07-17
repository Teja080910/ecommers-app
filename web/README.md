# Zipzapcart — Website

A static, animated React marketing site for Zipzapcart, built with Vite + React Router + Framer Motion.

## Pages
- **Home** (`/`) — hero, feature grid, highlight strip, download CTA
- **Our Company** (`/our-company`)
- **Future** (`/future`)
- **Collaborate With App** (`/collaborate`)
- **Contact Us** (`/contact`) — contact details + message form (front-end only, no backend wired up)

## Getting started
```bash
npm install
npm run dev       # local dev server
npm run build     # production build -> dist/
npm run preview   # preview the production build
```

## Things to update before launch
1. **Play Store link** — currently a placeholder in `src/data/content.js`:
   ```js
   export const PLAYSTORE_URL = "https://play.google.com/store/apps/details?id=com.zipzapcart.app";
   ```
   Replace with your real Play Store listing URL. It's used in the Navbar, Home hero/CTA, and Footer.
2. **Contact details, address, phone, email** — edit `CONTACT` in `src/data/content.js`.
3. **Contact form** — `src/pages/Contact.jsx` currently just shows a success state on submit. Wire it up to your email service / form backend (e.g. Formspree, a serverless function, etc.) when ready.
4. **Social links** — placeholder `#` hrefs in `src/components/Footer.jsx`; add your real profile URLs.
5. **Logo** — `src/assets/logo.png` was extracted/cleaned from your uploaded logo file. Swap in a higher-resolution transparent PNG/SVG if you have one for best sharpness.

## Design notes
- Color theme pulled from your logo (deep navy blue + red/orange).
- Fonts: Sora (headings) + Inter (body), loaded from Google Fonts.
- Motion: scroll-reveal on all sections, an animated top progress bar, floating phone-mockup hero, and hover micro-interactions — all respect `prefers-reduced-motion`.
- Fully responsive down to mobile.
