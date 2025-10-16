// .eslintrc.cjs
module.exports = {
  extends: ['eslint:recommended', 'plugin:svelte/eslint-svelte3'],
  overrides: [
    {
      files: ['*.svelte'],
      processor: 'svelte3/svelte3',
    },
  ],
  env: {
    browser: true,
    es2021: true,
  },
};