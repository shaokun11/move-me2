module.exports = {
  root: true,
  env: { node: true },

  extends: [
    'plugin:vue/strongly-recommended', 
    'eslint:recommended',
    '@vue/prettier', //  .prettierrc.js
  ],

  rules: {
    'no-console': 'warn',
    'no-debugger': 'warn',
    'no-unused-vars': [
      'warn',
      {
        ignoreRestSiblings: true ,
        varsIgnorePattern: '^h$', 
      },
    ],
    'no-var': 'warn',
    'prefer-const': ['warn', { destructuring: 'all' }],
    'no-empty': 'warn',
    'vue/order-in-components': 'warn',
  },

  parserOptions: {
    parser: 'babel-eslint',
  },

  overrides: [
    {
      files: [
        '**/__tests__/*.{j,t}s?(x)',
        '**/tests/unit/**/*.spec.{j,t}s?(x)',
      ],
      env: { jest: true },
    },
  ],
}
