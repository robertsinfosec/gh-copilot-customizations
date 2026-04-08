# Security Policy

## Supported Versions

Only the latest production release is supported with security updates.

| Version | Supported |
|---------|-----------|
| Latest  | Yes       |
| Older   | No        |

## Reporting a Vulnerability

**Do not open a public issue for security vulnerabilities.**

Instead, please report vulnerabilities through [GitHub Security Advisories](https://github.com/robertsinfosec/gh-copilot-customizations/security/advisories/new).

You can expect:

- **Acknowledgment** within 48 hours
- **Status update** within 7 days
- **Resolution or mitigation** as soon as reasonably possible

## Scope

This repository contains Copilot customization files — markdown configuration files that govern LLM behavior. Security concerns here typically involve:

- Control files that could instruct an LLM to bypass security safeguards
- Generation prompts that could produce insecure control file content
- Build or release pipeline vulnerabilities
- Sensitive data accidentally included in control files

## Disclosure

We follow coordinated disclosure. We will credit reporters in the release notes unless they prefer to remain anonymous.
