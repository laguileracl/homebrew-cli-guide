// Flat config: el formato que ESLint 9 exige (reemplaza a .eslintrc.json).
// Equivale a la configuración anterior: recomendadas de ESLint y de
// typescript-eslint, con el proyecto TS para las reglas que necesitan tipos.
const js = require("@eslint/js");
const tseslint = require("typescript-eslint");

module.exports = tseslint.config(
  // `out/` es la carpeta compilada: lintearla rompía el CI, porque su .js no
  // está en el tsconfig y el parser con `project` no sabe de dónde tomarlo.
  // `eslint.config.js` es CommonJS y se linteaba a sí mismo con las reglas de TS.
  { ignores: ["out/**", "node_modules/**", "eslint.config.js"] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    // El `project` solo sobre el código fuente TS: aplicarlo a todo hacía que el
    // propio eslint.config.js —que no está en el tsconfig— fallara al parsear.
    files: ["src/**/*.ts"],
    languageOptions: {
      parserOptions: { project: ["./tsconfig.json"] },
    },
  },
  {
    rules: {
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/explicit-module-boundary-types": "off",
    },
  },
);
