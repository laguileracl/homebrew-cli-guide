// Flat config: el formato que ESLint 9 exige (reemplaza al .eslintrc.json de la
// raíz, que este subproyecto heredaba). Mismas reglas que antes.
const js = require("@eslint/js");

module.exports = [
  { ignores: ["node_modules/**", "eslint.config.js"] },
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: "commonjs",
      globals: {
        require: "readonly",
        module: "writable",
        process: "readonly",
        console: "readonly",
        __dirname: "readonly",
        setTimeout: "readonly",
        clearTimeout: "readonly",
      },
    },
    rules: {
      "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    },
  },
];
