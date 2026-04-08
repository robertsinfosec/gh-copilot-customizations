# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- 13 instruction files: `security-standards`, `coding-standards`, `testing-standards`, `zero-tech-debt`, `accessibility`, `api-design`, `database-safety`, `sast-scanning`, `sca-scanning`, `brand-compliance`, `readme-badges`, `compliance-controls` (stub), `stack-standards` (stub)
- 4 prompts: `/detect-stack`, `/plan-work`, `/execute-work`, `/review-work`
- 6 agents: `@security-reviewer`, `@compliance-auditor`, `@strict-code-reviewer`, `@tech-debt-hunter`, `@brand-guardian`, `@technical-writer`
- 9 skills: `security-audit`, `compliance-review`, `tech-debt-elimination`, `brand-standards-check`, `threat-modeling`, `sast-setup`, `sca-setup`, `documentation-maintenance`, `readme-badge-bar`
- Workspace governance via `copilot-instructions.md`
- Generation factory with 33 SME braindump files and `/create-*` commands for quarterly regeneration
- Consumer README with quick start guide, included file tables, and configuration instructions
- Auto-versioned release workflow with date-stamp versions (`vYY.MDD.HHMM` production, `vYY.MDD.HHMM-branch` pre-release)
- PR validation gate (runs `validate.sh` and changelog check on PRs to `main`)
- Build script with version injection into consumer README
- Validation script enforcing frontmatter, minimum content, required fields, cross-link integrity, and pair count
- `/update-changelog` maintainer prompt for generating changelog entries from git history
- `CODE_OF_CONDUCT.md` based on Contributor Covenant
- `CONTRIBUTING.md` with contribution guidelines for the project
- `SECURITY.md` with vulnerability reporting policy
- `STYLE_GUIDE.md` with writing conventions for control files
- `LICENSE` (MIT)

### Changed

- Simplified release workflow versioning to use HHMM timestamp for both production and pre-release tags (replaced auto-incrementing sequence number for production)
