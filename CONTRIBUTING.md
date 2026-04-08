# Contributing

Thank you for your interest in contributing to GitHub Copilot Customizations!

## How to Contribute

### Reporting Issues

- Use [GitHub Issues](https://github.com/robertsinfosec/gh-copilot-customizations/issues) to report bugs or request features
- Search existing issues before opening a new one
- Include steps to reproduce for bugs

### Submitting Changes

1. Fork the repository
2. Create a branch from `staging` (not `main`)
3. Make your changes following the [Style Guide](STYLE_GUIDE.md)
4. Run validation locally: `bash scripts/validate.sh`
5. Update the changelog: run `/update-changelog` in Copilot chat
6. Open a PR targeting `staging`

### Repository Structure

- **`src/.github/`** — Control files (the product). Don't edit these directly.
- **`src/generation/`** — Generation files (SME braindumps). **Edit these** to change control file content.
- **`scripts/`** — Build and validation tooling.

### Making Changes to Control Files

Control files are generated from their corresponding generation file. To change a control file:

1. Edit the generation file in `src/generation/`
2. Copy from the `/create-*` command (line 5) to the end of the file
3. Paste into a fresh Copilot chat — the LLM produces the updated control file
4. Replace the control file body with the generated output
5. Run `bash scripts/validate.sh` to verify cross-links and required fields

### What Makes a Good PR

- One logical change per PR
- Validation passes (`bash scripts/validate.sh`)
- Changelog updated (the release workflow blocks without it)
- Generation file and control file updated together (never one without the other)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
