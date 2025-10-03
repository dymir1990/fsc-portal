/** @type {import('tailwindcss').Config} */
module.exports = {
	content: ['./src/**/*.{html,js,svelte,ts}'],
	theme: {
		extend: {
			colors: {
				brand: {
					50: '#f5f8ff',
					100: '#e9f0ff',
					200: '#cfe0ff',
					300: '#a6c3ff',
					400: '#6f9cff',
					500: '#3f7aff',
					600: '#1d5fff',
					700: '#134be0',
					800: '#123db3',
					900: '#142f80'
				}
			}
		}
	},
	plugins: []
};
