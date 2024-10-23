const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    "./layouts/*.html",
    "./layouts/**/*.html",
    "./themes/**/**/**/*.html",
    "./themes/**/**/*.html",
  ],
  theme: {
    screens: {
      "mobile": "640px",
      "tablet": "950px",
      // => @media (min-width: 640px) { ... }
      "desktop": "1280px",
      // => @media (min-width: 1280px) { ... }
    },
    fontFamily: {
      sans: ["Helvetica Neue", "Graphik", "sans-serif"],
      serif: ["Merriweather", "serif"],
    },
    colors: {
      vibez: {
        "red": "#e52e71",
      },
      mocha: {
        rosewater: "#f5e0dc",
        flamingo: "#f2cdcd",
        pink: "#f5c2e7",
        mauve: "#cba6f7",
        red: "#f38ba8",
        maroon: "#eba0ac",
        peach: "#fab387",
        yellow: "#f9e2af",
        green: "#a6e3a1",
        teal: "#94e2d5",
        sky: "#89dceb",
        sapphire: "#74c7ec",
        blue: "#89b4fa",
        lavender: "#b4befe",
        text: "#cdd6f4", // Light text color
        subtext1: "#bac2de",
        subtext0: "#a6adc8",
        overlay2: "#9399b2",
        overlay1: "#7f849c",
        overlay0: "#6c7086",
        surface2: "#585b70",
        surface1: "#45475a",
        surface0: "#313244",
        base: "#1e1e2e", // Background color
        mantle: "#181825",
        crust: "#11111b",
      },
      emerald: colors.emerald,
      indigo: colors.indigo,
      purple: colors.violet,
      yellow: colors.amber,
      pink: colors.fuchsia,
      transparent: "transparent",
      "tahiti": {
        100: "#cffafe",
        200: "#a5f3fc",
        300: "#67e8f9",
        400: "#22d3ee",
        500: "#06b6d4",
        600: "#0891b2",
        700: "#0e7490",
        800: "#155e75",
        900: "#164e63",
      },
    },
    extend: {},
  },
  plugins: [],
};
