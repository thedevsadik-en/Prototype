
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {
      colors: {
        background: "hsl(var(--background, 0 0% 100%))",
        foreground: "hsl(var(--foreground, 240 10% 3.9%))",
        card: "hsl(var(--card, 0 0% 100%))",
        "card-foreground": "hsl(var(--card-foreground, 240 10% 3.9%))",
        primary: "hsl(var(--primary, 240 5.9% 10%))",
        "primary-foreground": "hsl(var(--primary-foreground, 0 0% 98%))",
        secondary: "hsl(var(--secondary, 240 4.8% 95.9%))",
        "secondary-foreground": "hsl(var(--secondary-foreground, 240 5.9% 10%))",
        muted: "hsl(var(--muted, 240 4.8% 95.9%))",
        "muted-foreground": "hsl(var(--muted-foreground, 240 3.8% 46.1%))",
        accent: "hsl(var(--accent, 240 4.8% 95.9%))",
        "accent-foreground": "hsl(var(--accent-foreground, 240 5.9% 10%))",
        border: "hsl(var(--border, 240 5.9% 90%))",
        input: "hsl(var(--input, 240 5.9% 90%))",
        ring: "hsl(var(--ring, 240 5.9% 10%))",
        aetheris: {
          dark: "#0a0a0c",
          surface: "#121215",
          border: "#1f1f24",
          text: "#e4e4e7",
          glow: "rgba(124, 58, 237, 0.15)",
        }
      },
      fontFamily: {
        sans: ["Inter", "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "sans-serif"],
        mono: ["JetBrains Mono", "Fira Code", "Courier New", "monospace"],
      },
      borderRadius: {
        xl: "12px",
        "2xl": "16px",
        "3xl": "24px",
      },
    },
  },
  plugins: [],
};