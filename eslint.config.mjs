import { defineConfig, globalIgnores } from 'eslint/config';
import importPlg from 'eslint-plugin-import';
import prettier from 'eslint-plugin-prettier/recommended';
import simpleImportSort from 'eslint-plugin-simple-import-sort';
import globals from 'globals';
import jsoncParser from 'jsonc-eslint-parser';
import js from '@eslint/js';
import json from '@eslint/json';
import markdown from '@eslint/markdown';

export default defineConfig([
  globalIgnores(['node_modules/', 'package-lock.json'], 'Node'),
  {
    files: ['**/*.{js,mjs,cjs}'],
    plugins: {
      'import': importPlg,
      'simple-import-sort': simpleImportSort,
    },
    extends: ['js/recommended'],
    languageOptions: { globals: globals.node },
    rules: {
      'sort-imports': 'off',
      'simple-import-sort/exports': 'error',
      'simple-import-sort/imports': [
        'error',
        {
          groups: [
            // Dotenv imports first
            ['^dotenv', '^@dotenvx/dotenvx'],

            // Node.js built-ins
            [
              '^assert',
              '^buffer',
              '^child_process',
              '^cluster',
              '^console',
              '^constants',
              '^crypto',
              '^dgram',
              '^dns',
              '^domain',
              '^events',
              '^fs',
              '^http',
              '^https',
              '^inspector',
              '^module',
              '^net',
              '^os',
              '^path',
              '^perf_hooks',
              '^process',
              '^punycode',
              '^querystring',
              '^readline',
              '^repl',
              '^stream',
              '^string_decoder',
              '^timers',
              '^tls',
              '^tty',
              '^url',
              '^util',
              '^v8',
              '^vm',
              '^zlib',
              '^node:',
            ],

            // Side-effect imports (polyfills, CSS resets, etc.)
            ['^\\u0000'],

            // Non-scoped and scoped third-party packages (chalk, lodash, express, @scope/...)
            ['^[^@./]', '^@\\w'],

            // Telareth libraries
            ['^(@dcdavidev)(/.*|$)'],

            // Internal packages + relative imports (parent + sibling)
            ['^(@dcdavidev)(/.*|$)', '^\\.\\.?/.+'],

            // Styles and media assets last
            [
              '^.+\\.s?css$',
              '^.+\\.(png|jpe?g|gif|webp|svg)$',
              '^.+\\.(mp3|wav|ogg)$',
              '^.+\\.(mp4|avi|mov)$',
            ],
          ],
        },
      ],
    },
  },
  {
    files: ['**/*.json', '.czrc', '.release-it.json', 'package.json'],
    plugins: { json },
    language: 'json/json',
    languageOptions: { parser: jsoncParser },
    extends: ['json/recommended'],
  },
  {
    files: ['**/*.jsonc', '.vscode/**/*.json'],
    plugins: { json },
    language: 'json/jsonc',
    languageOptions: { parser: jsoncParser },
    extends: ['json/recommended'],
  },
  {
    files: ['**/*.{md,mdx}'],
    plugins: { markdown },
    extends: ['markdown/recommended'],
    language: 'markdown/gfm',
    languageOptions: { frontmatter: 'yaml' },
    rules: { 'markdown/no-html': 'off' },
  },
  prettier,
]);
