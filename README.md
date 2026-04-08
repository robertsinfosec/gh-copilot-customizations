# Agent Control Files

A centralized governance factory for GitHub Copilot agent control files. SMEs author generation files (human-language intent), an LLM produces Copilot-native control files, and a build step packages clean releases for consumers.

Covers security (OWASP ASVS v5, NIST 800-53), compliance (PCI-DSS, GDPR, HIPAA, SOX), code quality (zero technical debt), accessibility (WCAG 2.2 AA), and brand consistency.

## Repository Structure

```
.
├── .github/workflows/release.yml   ← Auto-versioned release workflow
├── scripts/build.sh                ← Build: src → dist (injects version)
│
├── src/
│   ├── .github/                    ← THE PRODUCT (shipped to consumers)
│   │   ├── instructions/
│   │   ├── prompts/
│   │   ├── agents/
│   │   ├── skills/
│   │   ├── copilot-instructions.md
│   │   └── README.md              ← Consumer-facing README (version injected at build)
│   │
│   └── generation/                 ← THE FACTORY (SME braindumps, never shipped)
│       ├── instructions/*.md
│       ├── prompts/*.md
│       ├── agents/*.md
│       ├── skills/*.md
│       └── copilot-instructions.md
│
└── dist/.github/                   ← BUILD OUTPUT (gitignored, created by build.sh)
```

## How It Works

### The Generation Factory

Every control file has a matching **generation file** in `src/generation/`. The two are cross-linked:

```yaml
# src/generation/instructions/security-standards.md
---
generates: .github/instructions/security-standards.instructions.md
---
/create-instruction
[SME braindump: what security rules to enforce, which standards, etc.]
```

```yaml
# src/.github/instructions/security-standards.instructions.md
---
applyTo: "**"
generation-source: "generation/instructions/security-standards.md"
---
[LLM-generated content based on the braindump above]
```

### Maintainer Workflow

1. **Author**: SMEs edit generation files in `src/generation/` on a working branch. Each team owns their domain — Security writes security, Marketing writes brand, Architecture writes coding standards.

2. **Generate**: Copy from the `/create-*` command (line 5 of any generation file) to the end of the file. Paste into a fresh Copilot chat. The LLM reads the braindump and produces a control file.

3. **Review**: Replace the control file body with the generated output. Iterate until satisfied.

4. **Changelog**: Run `/update-changelog` in Copilot chat. It gathers git history since the last release, categorizes changes per [keepachangelog](https://keepachangelog.com/en/1.1.0/), and updates `CHANGELOG.md`. The release workflow will **block** if the `[Unreleased]` section is empty.

5. **Release**: Push to `staging` or `main` and trigger the release workflow (Actions → Release → Run workflow). The `[Unreleased]` section is used as the release description. After a production release, the workflow automatically archives `[Unreleased]` under the version heading and pushes the archived changelog to `staging` — so it's ready for the next cycle.

### Build Step

```bash
bash scripts/build.sh [version]
```

- Copies `src/.github/` → `dist/.github/` (generation files live outside `.github/`, so they're never included)
- Injects the version string into the consumer README
- Outputs a file manifest and count

### Validation

```bash
bash scripts/validate.sh
```

Runs automatically during the release workflow, but can also be run locally. Checks:

- **Frontmatter exists** — every control and generation file starts with `---`
- **Minimum content** — files must be at least 10 lines (catches empty stubs)
- **Required fields by type** — `applyTo` for instructions, `description` for prompts, `tools` for agents, `name` for skills, `generates` for generation files
- **Cross-link integrity** — every `generation-source` and `generates` path resolves to a real file
- **Pair count** — control file count must equal generation file count

### Auto-Versioned Releases

Releases are triggered manually via `workflow_dispatch` on any branch. The version is auto-generated — no manual input needed.

**Production** (from `main`):
```
v26.408.1430                  ← vYY.MDD.HHMM
```

**Pre-release** (from any other branch):
```
v26.408.901-staging           ← vYY.MDD.HHMM-branch
v26.1231.2207-feature-new     ← branch name sanitized for semver
```

Version format: `YY.MDD.HHMM` — month and hour have no leading zero; day and minute always have a leading zero. The only difference between production and pre-release is the `-branch` suffix.

The workflow has two jobs:

**`validate`** — runs on PRs to `main`, pushes to `main`, and manual dispatch:
1. Validates all control and generation files via `scripts/validate.sh`
2. Checks that `CHANGELOG.md` has been updated since the last release

**`release`** — runs only on pushes to `main` and manual dispatch (skipped for PRs):
1. Auto-detects branch → sets pre-release flag for non-`main`
2. Generates a date-stamp version
3. Extracts the `[Unreleased]` section from `CHANGELOG.md` for the release body
4. Runs the build script with version injection
5. Packages `tar.gz` + `zip` artifacts
6. Creates a GitHub Release with changelog as the description

**Typical flow**: work on `staging` → manual dispatch creates pre-releases → open PR to `main` (validation runs as a check) → merge → production release is created automatically.

## What's Included

### Control Files (34 files)

| Type | Count | Files |
|------|-------|-------|
| **Workspace instructions** | 1 | `copilot-instructions.md` |
| **Instructions** | 13 | `security-standards`, `coding-standards`, `testing-standards`, `zero-tech-debt`, `accessibility`, `api-design`, `database-safety`, `sast-scanning`, `sca-scanning`, `brand-compliance`, `readme-badges`, `compliance-controls`¹, `stack-standards`² |
| **Prompts** | 4 | `/detect-stack`², `/plan-work`, `/execute-work`, `/review-work` |
| **Agents** | 6 | `@security-reviewer`, `@compliance-auditor`, `@strict-code-reviewer`, `@tech-debt-hunter`, `@brand-guardian`, `@technical-writer` |
| **Skills** | 9 | `security-audit`, `compliance-review`, `tech-debt-elimination`, `brand-standards-check`, `threat-modeling`, `sast-setup`, `sca-setup`, `documentation-maintenance`, `readme-badge-bar` |

¹ Requires org-specific configuration (your regulatory obligations)
² `stack-standards` is auto-generated by running `/detect-stack` in the consumer's repo

### Generation Files (33 files)

One generation file per control file (except the consumer README). Each contains the SME braindump and a `/create-*` command for regeneration.

## Consumer Installation

Consumers download a release and extract the `.github/` folder into their repo root:

```bash
# Download and extract the latest release
tar -xzf agent-control-files-v26.408.1430.tar.gz

# Or unzip
unzip agent-control-files-v26.408.1430.zip
```

Then run `/detect-stack` in Copilot chat to generate technology-specific standards. See the [consumer README](src/.github/README.md) for full details.

| Step | Prompt | Input | Output |
|------|--------|-------|--------|
| 1. Plan | `/plan-work` | Braindump (any format) | Classified GitHub Issues with dependencies |
| 2. Execute | `/execute-work` | GH Issue `#N` or ad-hoc description | Standards-compliant code with tests |
| 3. Review | `/review-work` | GH Issue `#N` | Full review verdict (PASS/FAIL) + optional issue creation |

### Review Verdict Criteria

| Condition | Verdict |
|-----------|---------|
| Zero blocking findings + build passes + tests pass + coverage ≥ 75% | **PASS** |
| Any blocking finding OR build fails OR tests fail OR coverage < 75% | **FAIL** |

After the review verdict, the developer is offered the option to create GitHub Issues
for findings. This is a convenience and does **not** affect the verdict.

## File Types Explained

| Type | Location | How It Works |
|------|----------|-------------|
| **Workspace Instructions** | `.github/copilot-instructions.md` | Always loaded into every Copilot interaction. Sets the tone. |
| **Instructions** | `.github/instructions/*.instructions.md` | Auto-attached when you edit files matching `applyTo` glob patterns. |
| **Prompts** | `.github/prompts/*.prompt.md` | Invoked on-demand via `/` in Copilot chat. Single focused task. |
| **Agents** | `.github/agents/*.agent.md` | Specialist agents with restricted tool sets. Invoked by name. |
| **Skills** | `.github/skills/*/SKILL.md` | Multi-step workflow procedures. Invoked via `/` in Copilot chat. |

## Standards Enforced

All files in this template enforce the following standards:

| Domain | Standards |
|--------|-----------|
| Application Security | OWASP Top 10, OWASP API Security Top 10 |
| Security Framework | NIST 800-53 (AC, AU, IA, SC, SI) |
| SAST | CodeQL (public repos), Semgrep (private repos) via GitHub Actions |
| SCA | Dependabot (all repos) + `npm audit` (NPM stacks) |
| Dependency Versions | Latest stable, avoid major `.0` releases until proven |
| Payment Data | PCI-DSS |
| EU Privacy | GDPR |
| CA Privacy | CCPA |
| Financial Controls | SOX (separation of duties, audit trails, change management) |
| Technical Debt | Zero tolerance — never create, actively eliminate |
| Coding Standards | Framework idioms (React hooks, PEP-8, etc.), clean architecture, DI |
| Brand | `docs/BRAND.md` (warn if missing) |
| Accessibility | WCAG 2.1 AA (perceivable, operable, understandable, robust) |
| Testing | Unit, integration, security, edge cases; 75% coverage minimum |
| Documentation | Living docs — README, API, CHANGELOG verified against code reality |
| README Badges | Build, tests, coverage, SAST, SCA, license, issues, PRs, releases |
| GitHub Security Tab | Dependabot, CodeQL/Semgrep, secret scanning alerts checked in reviews |

## Creating `docs/BRAND.md`

Several control files reference `docs/BRAND.md` for brand enforcement. If this file
doesn't exist, the LLM will warn the user. Your brand file should contain:

- Brand voice and tone guidelines
- Color palette with exact hex/RGB values and design tokens
- Typography standards (font families, weights, sizes, line heights)
- Logo usage rules (spacing, minimum sizes, prohibited modifications)
- Approved terminology and language conventions
- UI/UX patterns and component standards
- Iconography standards
- Spacing and layout grid specifications
- Dark mode / light mode requirements

## License

This template is provided as-is. Customize to your organization's needs.
