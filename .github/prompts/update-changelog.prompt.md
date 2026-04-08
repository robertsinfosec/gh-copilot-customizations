---
description: "Generate or update CHANGELOG.md from git history since the last release tag"
mode: "agent"
tools: ["execute", "read", "search"]
---

# Update Changelog

You are updating `CHANGELOG.md` in a repository that follows [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/).

## How this repo handles changelogs

The changelog follows a state machine:

1. **After a production release**, `CHANGELOG.md` has NO `[Unreleased]` section — only versioned sections like `## [v26.408.505] - 2026-04-08`. This is the signal that the developer needs to run this prompt.
2. **This prompt** creates the `[Unreleased]` section and populates it with entries from git history since the last release tag.
3. **During development**, the developer runs this prompt again to add new entries as commits accumulate.
4. **When a PR merges to `main`**, the release workflow automatically stamps `[Unreleased]` with the version number, commits to `main`, and opens a sync PR back to the source branch. The cycle resets to step 1.

**Your job**: Create or update the `[Unreleased]` section. Never stamp versions — the workflow does that.

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

- If there is **no `[Unreleased]` section**: this is normal after a production release. You will create one.
- If there **is** an `[Unreleased]` section: you will update it with new entries.

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
- ⛔ NEVER stamp a version number on `[Unreleased]` — the release workflow does that
- ⛔ NEVER remove or modify existing versioned sections (e.g., `## [v26.408.505] - ...`)
- ✅ Write entries from the consumer's perspective (what changed for them), not implementation details
- ✅ Reference specific file names when a control file was added, changed, or removed
- ✅ Collapse related commits into a single entry (e.g., 5 commits fixing the same instruction → one "Changed" entry)
- ✅ Preserve existing `[Unreleased]` entries that are still accurate — only add, update, or remove entries as needed

## Step 4: Write the `[Unreleased]` section

**If no `[Unreleased]` section exists**: Insert `## [Unreleased]` on a new line immediately after the header block (the "format is based on" line), followed by a blank line, then your categorized entries. Preserve all versioned sections below.

**If `[Unreleased]` already exists**: Update its contents with the categorized entries. Preserve all versioned sections below it.
