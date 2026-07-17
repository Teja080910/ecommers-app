const base = {
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.8,
  strokeLinecap: "round",
  strokeLinejoin: "round",
};

const wrap = (children, size = 24) => (
  <svg width={size} height={size} viewBox="0 0 24 24" {...base}>
    {children}
  </svg>
);

export const Icon = ({ name, size = 24 }) => {
  switch (name) {
    case "bag":
      return wrap(<><path d="M6 8h12l-1 12H7L6 8Z" /><path d="M9 8V6a3 3 0 0 1 6 0v2" /></>, size);
    case "percent":
      return wrap(<><circle cx="7" cy="7" r="2.3" /><circle cx="17" cy="17" r="2.3" /><path d="M17 7 7 17" /></>, size);
    case "truck":
      return wrap(<><path d="M3 7h11v9H3z" /><path d="M14 10h4l3 3v3h-7z" /><circle cx="7.5" cy="18" r="1.6" /><circle cx="17.5" cy="18" r="1.6" /></>, size);
    case "shield":
      return wrap(<><path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3Z" /><path d="M9 12l2 2 4-4" /></>, size);
    case "phone":
      return wrap(<><rect x="7" y="2.5" width="10" height="19" rx="2.2" /><path d="M11 18.5h2" /></>, size);
    case "cube":
      return wrap(<><path d="M12 3l8 4.5v9L12 21l-8-4.5v-9L12 3Z" /><path d="M4.5 7.5 12 12l7.5-4.5" /><path d="M12 12v9" /></>, size);
    case "leaf":
      return wrap(<path d="M20 4c.5 8-4 15-14 15C6.5 10 12 5 20 4Z M6 19c2-4 5-7 10-9" />, size);
    case "heart":
      return wrap(<path d="M12 20s-7-4.4-9.5-9C.8 7.4 3 4 6.5 4c2 0 3.6 1.1 4.5 2.6C11.9 5.1 13.5 4 15.5 4 19 4 21.2 7.4 19.5 11c-2.5 4.6-9.5 9-9.5 9Z" />, size);
    case "ai":
      return wrap(<><rect x="6" y="6" width="12" height="12" rx="3" /><path d="M9 3v2M15 3v2M9 19v2M15 19v2M3 9h2M3 15h2M19 9h2M19 15h2" /><circle cx="9.5" cy="12" r="1" fill="currentColor" /><circle cx="14.5" cy="12" r="1" fill="currentColor" /></>, size);
    case "bolt":
      return wrap(<path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" fill="currentColor" stroke="none" />, size);
    case "support":
      return wrap(<><path d="M4 13v-1a8 8 0 0 1 16 0v1" /><rect x="3" y="13" width="4" height="6" rx="1.5" /><rect x="17" y="13" width="4" height="6" rx="1.5" /><path d="M20 19a5 5 0 0 1-5 4h-2" /></>, size);
    case "store":
      return wrap(<><path d="M4 9 5.5 4h13L20 9" /><path d="M4 9h16v10H4z" /><path d="M9 19v-5h6v5" /></>, size);
    case "trend":
      return wrap(<><path d="M4 16l6-6 4 4 6-7" /><path d="M15 7h5v5" /></>, size);
    case "check":
      return wrap(<><circle cx="12" cy="12" r="9" /><path d="M8 12.5l2.5 2.5L16 9" /></>, size);
    case "mail":
      return wrap(<><rect x="3" y="5" width="18" height="14" rx="2.5" /><path d="M3.5 6.5 12 13l8.5-6.5" /></>, size);
    case "pin":
      return wrap(<><path d="M12 21s7-6.2 7-11.5A7 7 0 0 0 5 9.5C5 14.8 12 21 12 21Z" /><circle cx="12" cy="9.5" r="2.4" /></>, size);
    case "clock":
      return wrap(<><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3.5 2" /></>, size);
    case "globe":
      return wrap(<><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3c2.6 2.6 4 5.7 4 9s-1.4 6.4-4 9c-2.6-2.6-4-5.7-4-9s1.4-6.4 4-9Z" /></>, size);
    case "menu":
      return wrap(<path d="M4 6h16M4 12h16M4 18h16" />, size);
    case "close":
      return wrap(<path d="M6 6l12 12M18 6 6 18" />, size);
    case "arrow-right":
      return wrap(<path d="M5 12h14M13 6l6 6-6 6" />, size);
    case "instagram":
      return wrap(<><rect x="3.5" y="3.5" width="17" height="17" rx="5" /><circle cx="12" cy="12" r="3.6" /><circle cx="17" cy="7" r="0.9" fill="currentColor" stroke="none" /></>, size);
    case "facebook":
      return wrap(<path d="M14 21v-8h2.5l.5-3H14V8c0-.9.3-1.5 1.7-1.5H17V3.8C16.7 3.7 15.7 3.6 14.5 3.6c-2.5 0-4.2 1.5-4.2 4.3V10H8v3h2.3v8H14Z" fill="currentColor" stroke="none" />, size);
    case "linkedin":
      return wrap(<><rect x="3.5" y="3.5" width="17" height="17" rx="3.5" /><path d="M8 10.5v6M8 7.8v.1" /><path d="M12 16.5v-3.6c0-1.2.9-1.9 1.9-1.9 1 0 1.6.7 1.6 1.9v3.6" /></>, size);
    case "twitter":
      return wrap(<path d="M21 5.5c-.7.4-1.5.6-2.3.8a3.6 3.6 0 0 0-6.1 3.3A10.2 10.2 0 0 1 5 5.9a3.6 3.6 0 0 0 1.1 4.8c-.6 0-1.2-.2-1.7-.4v.1c0 1.7 1.2 3.2 2.9 3.5-.5.1-1.1.2-1.7.1.5 1.5 1.9 2.5 3.5 2.6A7.3 7.3 0 0 1 3 18a10.3 10.3 0 0 0 15.9-9.2c.7-.5 1.3-1.2 1.8-1.9-.6.3-1.3.5-2 .6.8-.4 1.4-1.1 1.7-2Z" fill="currentColor" stroke="none" />, size);
    case "handshake":
  return wrap(
    <>
      <path d="M7 13l2 2a2 2 0 0 0 2.8 0l2.2-2.2a2 2 0 0 1 2.8 0L20 16" />
      <path d="M4 10l3-3 4 4" />
      <path d="M20 10l-3-3-4 4" />
      <path d="M2.5 12.5l3-3 2.5 2.5-3 3z" />
      <path d="M18.5 9.5l3 3-2.5 2.5-3-3z" />
    </>,
    size
  );
  case "growth":
  return wrap(
    <>
      <path d="M5 18V11" />
      <path d="M10 18V8" />
      <path d="M15 18V5" />
      <path d="M20 18V2" />
      <path d="M4 18h17" />
    </>,
    size
  );
  case "idea":
  return wrap(
    <>
      <path d="M12 3a5 5 0 0 0-3 9c.8.8 1.3 1.7 1.5 2.7h3c.2-1 .7-1.9 1.5-2.7A5 5 0 0 0 12 3Z"/>
      <path d="M10 18h4"/>
      <path d="M10.5 21h3"/>
    </>,
    size
  );
  case "briefcase":
  return wrap(
    <>
      <rect x="3" y="7" width="18" height="12" rx="2"/>
      <path d="M9 7V5h6v2"/>
      <path d="M3 12h18"/>
    </>,
    size
  );
  case "megaphone":
  return wrap(
    <>
      <path d="M4 13V9l11-4v12L4 13Z"/>
      <path d="M15 8h3a2 2 0 0 1 0 4h-3"/>
      <path d="M7 14l1.5 4"/>
    </>,
    size
  );
  case "settings":
  return wrap(
    <>
      <circle cx="12" cy="12" r="3"/>
      <path d="M12 2v3M12 19v3M2 12h3M19 12h3"/>
      <path d="M5 5l2 2M17 17l2 2M5 19l2-2M17 7l2-2"/>
    </>,
    size
  );
      default:
      return null;
  }
};
