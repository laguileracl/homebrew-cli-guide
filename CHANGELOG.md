# Changelog

## 2025-09-30 — Maintenance release

This release contains repository maintenance and modernization work:

- Fix placeholders and owner links across documentation (README, INSTALL, CONTRIBUTING, GITHUB_SETUP) — see the merged PRs.
- Bump Node and VS Code engine requirements (api-server: Node >=18, vscode-extension: VS Code ^1.80.0).
- Update developer tooling:
  - TypeScript and @types updates; added minimal TS scaffold for the VS Code extension.
  - Updated Jest in the API package and added `--passWithNoTests` to avoid CI failures when tests are absent.
  - Added ESLint configuration and lint job in CI; per-package configs for TypeScript packages.
- CI improvements:
  - Add a unified CI workflow to run API tests, compile extension, linting, Quarto HTML render and a Quarto PDF attempt with sanitization fallback.
  - Dependabot configured to open PRs for minor/patch updates and GitHub Actions updates weekly.
- Documentation and tooling enhancements:
  - Added `scripts/sanitize-quarto-for-latex.sh` to help produce PDFs by removing problematic Unicode symbols or using xelatex first.
  - Added `.github/CODEOWNERS` and a `RELEASE_NOTES.md` entry.

For details, review the repository PR history around 2025-09-30.
