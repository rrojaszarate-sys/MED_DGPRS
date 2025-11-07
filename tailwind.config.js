/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Paleta corporativa SIGIMED (Pantone)
        primary: {
          DEFAULT: '#7F2141', // Pantone 505 C
          50: '#F5E6EC',
          100: '#E6BFD0',
          200: '#D699B4',
          300: '#C77398',
          400: '#B74D7C',
          500: '#7F2141',
          600: '#661A34',
          700: '#4C1327',
          800: '#330D1A',
          900: '#19060D',
        },
        secondary: {
          DEFAULT: '#AF8D6B', // Pantone 7504 C
          50: '#F7F3EE',
          100: '#EAE0D4',
          200: '#DDCDBA',
          300: '#D0BAA0',
          400: '#C3A786',
          500: '#AF8D6B',
          600: '#8C7156',
          700: '#695540',
          800: '#46382B',
          900: '#231C15',
        },
        accent: {
          DEFAULT: '#B39F82', // Pantone 467 C
          50: '#F7F4EF',
          100: '#EBE4D9',
          200: '#DFD4C3',
          300: '#D3C4AD',
          400: '#C7B497',
          500: '#B39F82',
          600: '#8F7F68',
          700: '#6B5F4E',
          800: '#484034',
          900: '#24201A',
        },
        neutral: {
          DEFAULT: '#D4D0C8', // Pantone Warm Grey 1 C
          50: '#FAFAF9',
          100: '#F5F4F2',
          200: '#EEEDEA',
          300: '#E7E5E1',
          400: '#DED9D5',
          500: '#D4D0C8',
          600: '#AAA6A0',
          700: '#7F7D78',
          800: '#555350',
          900: '#2A2A28',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        'shake': 'shake 0.5s ease-in-out infinite',
        'glow': 'glow 2s ease-in-out infinite',
      },
      keyframes: {
        shake: {
          '0%, 100%': { transform: 'translateX(0)' },
          '10%, 30%, 50%, 70%, 90%': { transform: 'translateX(-2px)' },
          '20%, 40%, 60%, 80%': { transform: 'translateX(2px)' },
        },
        glow: {
          '0%, 100%': { boxShadow: '0 0 5px rgba(127, 33, 65, 0.5)' },
          '50%': { boxShadow: '0 0 20px rgba(127, 33, 65, 0.8)' },
        },
      },
    },
  },
  plugins: [],
}
