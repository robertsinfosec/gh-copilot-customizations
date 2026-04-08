# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Release workflow no longer pushes directly to staging; instead commits the stamped changelog to `main` and opens a sync PR back to the source branch via `gh`
- Workflow no longer hardcodes `staging` — automatically detects the source branch from the merged PR
- `/update-changelog` prompt and README updated to describe the sync PR approach

### Added

- `pull-requests: write` permission in release workflow for automated sync PRs

## [v26.408.509] - 2026-04-08

### Changed

- Simplified release workflow versioning to use HHMM timestamp for both production and pre-release tags (replaced auto-incrementing sequence number for production)
- Changelog now follows a state machine: production releases stamp `[Unreleased]` with the version number and push the result to both `main` and `staging`; `/update-changelog` creates the `[Unreleased]` section for the next cycle
- `/update-changelog` prompt rewritten to understand the state machine lifecycle

### Added

- `CODE_OF_CONDUCT.md` based on Contributor Covenant
- `CONTRIBUTING.md` with contribution guidelines for the project
- `SECURITY.md` with vulnerability reporting policy
- `STYLE_GUIDE.md` with writing conventions for control files
- `LICENSE` (MIT)

## [v26.408.505] - 2026-04-08

### Added

- 13 instruction files: `security-standards`, `coding-standards`, `testing-standards`, `zero-tech-debt`, `accessibility`, `api-design`, `database-safety`, `sast-scanning`, `sca-scanning`, `brand-compliance`, `readme-badges`, `compliance-controls` (stub), `stack-standards` (stub)
- 4 prompts: `/detect-stack`, `/plan-work`, `/execute-work`, `/review-work`
- 6 agents: `@security-reviewer`, `@compliance-auditor`, `@strict-code-reviewer`, `@tech-debt-hunter`, `@brand-guardian`, `@technical-writer`
- 9 skills: `security-audit`, `compliance-review`, `tech-debt-elimination`, `brand-standards-check`, `threat-modeling`, `sast-setup`, `sca-setup`, `documentation-maintenance`, `readme-badge-bar`
- Workspace governance via `copilot-instructions.md`
- Generation factory with 33 SME braindump files and `/create-*` commands for quarterly regeneration
- Consumer README with quick start guide, included file tables, and configuration instructions
- Auto-versioned release workflow with date-stamp versions
- PR validation gate (runs `validate.sh` and changelog check on PRs to `main`)
- Build script with version injection into consumer README
- Validation script enforcing frontmatter, minimum content, required fields, cross-link integrity, and pair count
- `/update-changelog` maintainer prompt for generating changelog entries from git history
