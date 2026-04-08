---
description: "Generate or update CHANGELOG.md from git history since the last release tag"
mode: "agent"
tools: ["execute", "read", "search"]
---

# Update Changelog

You are updating `CHANGELOG.md` in a repository that follows [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/).

## How this repo handles changelogs

- The `[Unreleased]` section accumulates entries across all pre-releases.
- Pre-releases use `[Unreleased]` as their release description but do NOT consume or clear it.
- Only production releases (from `main`) archive `[Unreleased]` under a version heading — and that is done automatically by the release workflow, not by this prompt.
- Your job is to keep `[Unreleased]` accurate and up to date.

## Step 1: Gather context

Run these commands to collect what changed since the last release:

```bash
# Find the most recent release tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
echo "Last tag: ${LAST_TAG:-none (first release)}"

# Show commits since that tag (or all commits if no tag)
if [[ -n "$LAST_TAG" ]]; then
  git log "$LAST_TAG"..HEAD --oneline --no-merges
else
  git log --oneline --no-merges
fi
```

```bash
# Show files changed (summary) since the last tag
if [[ -n "$LAST_TAG" ]]; then
  git diff "$LAST_TAG" --stat
else
  git diff --stat $(git rev-list --max-parents=0 HEAD) HEAD
fi
```

## Step 2: Read the current CHANGELOG

Read `CHANGELOG.md` and understand the existing structure and entries.

## Step 3: Categorize changes

Group commits into Keep a Changelog categories:

- **Added** — new files, features, or capabilities
- **Changed** — modifications to existing behavior
- **Fixed** — bug fixes
- **Removed** — deleted files or capabilities
- **Deprecated** — features marked for future removal
- **Security** — vulnerability fixes or security improvements

Rules:
- ⛔ NEVER include a category with no entries
- ⛔ NEVER fabricate changes that don't appear in the git history
- ⛔ NEVER archive or clear the `[Unreleased]` section — the release workflow handles that
- ✅ Write entries from the consumer's perspective (what changed for them), not implementation details
- ✅ Reference specific file names when a control file was added, changed, or removed
- ✅ Collapse related commits into a single entry (e.g., 5 commits fixing the same instruction → one "Changed" entry)
- ✅ Preserve existing `[Unreleased]` entries that are still accurate — only add, update, or remove entries as needed

## Step 4: Update the `[Unreleased]` section

Replace or update the contents of the `[Unreleased]` section in `CHANGELOG.md` with the categorized entries. Preserve all previous release sections below it.

If there is no `[Unreleased]` section, add one immediately after the header block.
