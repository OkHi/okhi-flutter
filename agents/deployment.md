# OkHi Flutter — Library Deployment Guide

## Overview

This document describes the end-to-end process for releasing a new version of the `okhi_flutter` package to [pub.dev](https://pub.dev/packages/okhi_flutter).

---

## Prerequisites

- Write access to the [OkHi/okhi-flutter](https://github.com/OkHi/okhi-flutter) GitHub repository
- A [pub.dev](https://pub.dev) account linked to the OkHi publisher
- Flutter SDK installed and `flutter` available on `$PATH`
- `gh` CLI authenticated (`gh auth status`)

---

## Step 1 — Merge all changes into `develop`

Ensure all feature and fix branches targeting this release have open PRs against `develop` and are merged before proceeding.

```bash
git checkout develop
git pull origin develop
```

---

## Step 2 — Bump the version

Update the version number in **both** files. Use [semantic versioning](https://semver.org) (`MAJOR.MINOR.PATCH`).

**`pubspec.yaml`**
```yaml
version: X.Y.Z
```

**`ios/okhi_flutter.podspec`**
```ruby
s.version = 'X.Y.Z'
```

---

## Step 3 — Update CHANGELOG.md

Add a new section at the top of `CHANGELOG.md` describing what changed:

```markdown
## X.Y.Z

- Short description of each change
```

---

## Step 4 — Update native dependency versions (if changed)

If native Android or iOS libraries were updated, verify these files reflect the correct versions:

| File | Field |
|------|-------|
| `android/build.gradle` | `implementation("io.okhi.android:okhi:X.Y.Z")` |
| `ios/okhi_flutter.podspec` | `s.dependency 'OkHi', 'X.Y.Z'` |

---

## Step 5 — Commit the release prep changes

```bash
git add pubspec.yaml ios/okhi_flutter.podspec CHANGELOG.md
git commit -m "Prepare release vX.Y.Z"
git push origin develop
```

---

## Step 6 — Create a release branch from `develop`

```bash
git checkout -b release/vX.Y.Z
git push -u origin release/vX.Y.Z
```

---

## Step 7 — Run the pub.dev dry-run

From the repository root:

```bash
flutter pub publish --dry-run
```

The output must end with:

```
Package has 0 warnings.
```

Fix any warnings before continuing. Common issues:
- Podspec version out of sync with `pubspec.yaml`
- Stale or build-generated files tracked in git (e.g. Gradle init scaffolding in `lib/`)
- Uncommitted changes on the branch

---

## Step 8 — Create and push the release tag

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z

- Summary of key changes"

git push origin vX.Y.Z
```

---

## Step 9 — Publish to pub.dev

```bash
flutter pub publish
```

You will be prompted to authenticate via Google. After confirmation the package is live at:
`https://pub.dev/packages/okhi_flutter`

---

## Step 10 — Merge release branch into `master`

Open a PR from `release/vX.Y.Z` → `master` on GitHub, get it reviewed, and merge.

```bash
gh pr create \
  --base master \
  --head release/vX.Y.Z \
  --title "Release vX.Y.Z" \
  --body "Merges release/vX.Y.Z into master."
```

After merging, also merge `master` back into `develop` to keep them in sync:

```bash
git checkout develop
git merge master
git push origin develop
```

---

## Quick Reference

```
develop ──► release/vX.Y.Z ──► (pub.dev publish) ──► master ──► develop
```

| Step | Command |
|------|---------|
| Pull develop | `git pull origin develop` |
| Create release branch | `git checkout -b release/vX.Y.Z` |
| Dry-run | `flutter pub publish --dry-run` |
| Tag | `git tag -a vX.Y.Z -m "Release vX.Y.Z"` |
| Push tag | `git push origin vX.Y.Z` |
| Publish | `flutter pub publish` |

---

## Files to verify before every release

| File | What to check |
|------|---------------|
| `pubspec.yaml` | `version` matches release |
| `ios/okhi_flutter.podspec` | `s.version` matches release, metadata is not placeholder |
| `CHANGELOG.md` | New version section exists at the top |
| `android/build.gradle` | Native Android SDK version is intentional |
| `ios/okhi_flutter.podspec` | Native iOS SDK version is intentional |
