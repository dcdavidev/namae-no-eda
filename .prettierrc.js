import yaml from '@yaml-js/config-prettier';

/**
 * @see https://prettier.io/docs/configuration
 * @typedef {import("prettier").Config}
 */
const config = {
  plugins: ['prettier-plugin-sh'],
  ...yaml,

  trailingComma: 'es5',
  tabWidth: 2,
  semi: true,
  singleQuote: true,
  printWidth: 80,
  endOfLine: 'lf',

  overrides: [
    {
      files: ['.czrc', '**/*.json', '**/*.jsonc'],
      options: {
        parser: 'json',
      },
    },
    {
      files: ['*.md', '*.mdx'],
      options: {
        parser: 'markdown',
      },
    },
    {
      files: ['*.yaml', '*.yml'],
      options: {
        printWidth: 80,
      },
    },
  ],
};

export default config;
