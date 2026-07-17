import { motion } from "framer-motion";
import "./cartmock.css";

export default function CartMock() {
  return (
    <div className="cart-scene">
      <motion.div
        className="cart-shell"
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1], delay: 0.15 }}
      >
        <svg viewBox="0 0 220 240" fill="none" xmlns="http://www.w3.org/2000/svg">
          {/* bag 1 (back, red) */}
          <g transform="translate(18,10)">
            <rect x="0" y="34" width="70" height="86" rx="6" fill="var(--red-500)" />
            <path
              d="M14 34 V20a20 20 0 0 1 40 0 v14"
              stroke="var(--navy-900)"
              strokeWidth="4"
              fill="none"
              strokeLinecap="round"
            />
          </g>

          {/* bag 2 (front, orange) */}
          <g transform="translate(78,44)">
            <rect x="0" y="26" width="62" height="76" rx="6" fill="var(--orange-500)" />
            <path
              d="M12 26 V15a13 13 0 0 1 26 0 v11"
              stroke="var(--navy-900)"
              strokeWidth="4"
              fill="none"
              strokeLinecap="round"
            />
            <text x="31" y="70" textAnchor="middle" fontFamily="Sora, sans-serif" fontWeight="800" fontSize="26" fill="white">Z</text>
          </g>

          {/* cart basket */}
          <g transform="translate(6,118)">
            <path
              d="M4 4 H186 L168 90 H40 L4 4 Z"
              stroke="var(--navy-800)"
              strokeWidth="6"
              fill="none"
              strokeLinejoin="round"
            />
            <path d="M22 26 H176M30 48 H162M38 70 H150" stroke="var(--navy-800)" strokeWidth="3.5" opacity="0.7" />
            <path d="M48 4 L58 90M96 4 L100 90M144 4 L142 90" stroke="var(--navy-800)" strokeWidth="3.5" opacity="0.7" />
            {/* handle */}
            <path d="M4 4 L-14 -20 H10" stroke="var(--navy-800)" strokeWidth="6" fill="none" strokeLinecap="round" />
            {/* wheels */}
            <circle cx="58" cy="106" r="11" fill="var(--navy-900)" />
            <circle cx="150" cy="106" r="11" fill="var(--navy-900)" />
          </g>
        </svg>
      </motion.div>

      <motion.div
        className="cart-tag"
        animate={{ rotate: [-6, 2, -6] }}
        transition={{ duration: 3.4, repeat: Infinity, ease: "easeInOut" }}
      >
        SALE
      </motion.div>
    </div>
  );
}
