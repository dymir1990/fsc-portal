// Tailwind v4 requires using the '@tailwindcss/postcss' plugin wrapper.
// Include autoprefixer after it.
module.exports = {
	plugins: {
		'@tailwindcss/postcss': {},
		autoprefixer: {}
	}
};
