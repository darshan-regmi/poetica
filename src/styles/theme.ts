/* This code snippet is defining a theme object in TypeScript. The theme object contains various
properties such as colors, spacing, fontSizes, borderRadius, and shadows. Each property has specific
values assigned to it, such as color codes for different elements, spacing values, font sizes,
border radius values, and shadow effects. */
export const theme = {
  colors: {
    primary: '#00ADB5',          // Accent
    secondary: '#393E46',        // Card / dark shade
    accent: '#EEEEEE',           // Text on dark
    background: '#222831',       // Background
    card: '#393E46',             // PoemCard background
    text: '#EEEEEE',             // Main text
    lightText: '#B0B0B0',        // Placeholder, subtext
    border: '#393E46',           // Subtle border
    overlay: 'rgba(0, 173, 181, 0.1)', // Hover overlay
    shadowColor: 'rgba(0, 0, 0, 0.3)', // Shadow color
  },

  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },

  fontSizes: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
  },

  borderRadius: {
    sm: 6,
    md: 12,
    lg: 20,
    xl: 30,
  },

  shadows: {
    small: '0 1px 3px rgba(0, 0, 0, 0.3)',
    medium: '0 4px 8px rgba(0, 0, 0, 0.4)',
    large: '0 12px 24px rgba(0, 0, 0, 0.5)',
  },
};