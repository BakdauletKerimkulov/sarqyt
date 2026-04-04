module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },

  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],

  parser: "@typescript-eslint/parser",

  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
    tsconfigRootDir: __dirname,
  },

  ignorePatterns: [
    "/lib/**/*",
    "/generated/**/*",
  ],

  overrides: [
    {
      files: ["*.js"],
      parserOptions: {
        project: null, // 💥 КЛЮЧЕВО
      },
    },
  ],

  plugins: ["@typescript-eslint", "import"],

  rules: {
    "quotes": ["error", "double"],
    "indent": ["error", 2],
    "import/no-unresolved": 0,
    "semi": ["off"],
    "require-jsdoc": ["off"],
    "object-curly-spacing": ["off"],
    "spaced-comment": ["off"],
    "max-len": [
      "error",
      {
        "code": 140,
      },
    ],
  },
};
