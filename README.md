# Go Development Container

Ubuntu-based Go development image published to Docker Hub, with automated multi-version builds.

## Overview

This repository builds and publishes one or more Go images on a schedule using GitHub Actions.

- Registry: [Docker Hub - esacteksab/go](https://hub.docker.com/r/esacteksab/go)
- Runtime base: Ubuntu 24.04 (digest pinned)
- Build schedule: Every Friday at 9:00 AM Central Time (US/Chicago)

## Local Development (VS Code Dev Container)

Local development is standardized through a shared dev-container instead of per-repo bootstrap files.

- Dev container config: [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)
- Shared environment image: `docker.io/esacteksab/dev-container:2026-03-13-20-04@sha256:ff0997d094d0ffadfc73a278ac6b2316a15f0a6025fbfc067c2348929071ded3`

### Getting started

1. Open this repository in VS Code.
1. Run the command: `Dev Containers: Reopen in Container`.
1. Wait for the container build to complete.
1. Start working with the preinstalled toolchain inside the container.

The container post-create step installs pre-commit hooks automatically.

### First-pass boilerplate removed from this repo

The following local bootstrap files were intentionally removed in favor of the shared dev-container:

- `package.json`
- `pnpm-lock.yaml`
- `requirements.txt`
- `.mise.toml`

Project policy/config files such as `.pre-commit-config.yaml`, `.prettierrc`, `.prettierignore`, and GitHub workflow files remain in this repository.

## How Versions Are Selected

The workflow resolves the build matrix in one of two ways:

1. If repository variable `GO_VERSION` is set, only that exact version is built.
1. If `GO_VERSION` is not set, versions are queried from `https://go.dev/dl/?mode=json`, then reduced to the latest stable patch release for each stable Go minor line.

## Multi-Version Build Behavior

For each Go version in the matrix, the workflow:

1. Resolves the digest for `golang:<version>-bookworm`.
1. Passes `GO_VERSION` and `GO_IMAGE_DIGEST` as build args.
1. Builds an Ubuntu runtime image and copies `/usr/local/go` from the digest-pinned Go source stage.

This keeps builds reproducible while still supporting multiple Go versions.

## Tags Published

For each built version `<go-version>`:

- `esacteksab/go:<go-version>`
- `esacteksab/go:<go-version>-YYYY-MM-DD`

Additionally:

- `esacteksab/go:latest` is applied to the highest version in the matrix for that run.

## Image Characteristics

- `CGO_ENABLED=0`
- `GOPATH=/go`
- `PATH` includes `/usr/local/go/bin` and `/go/bin`
- `GO_VERSION` is set in the final image environment
- OCI label `org.opencontainers.image.version` is set to the built Go version

## Manual Build Example

```bash
docker build \
 --build-arg GO_VERSION=1.25.8 \
 --build-arg GO_IMAGE_DIGEST=sha256:<digest-for-golang-1.25.8-bookworm> \
 -t esacteksab/go:1.25.8 .
```

## Troubleshooting CI Failures

### 1. Failed to Resolve Go Image Digest

Symptom in workflow logs:

- `Failed to resolve digest for golang:<version>-bookworm`

Common causes:

- Temporary Docker Hub or network outage on GitHub-hosted runners.
- Invalid or unavailable Go version in the matrix.

What to do:

1. Re-run the failed workflow once to rule out transient network errors.
1. Verify the version exists: `docker buildx imagetools inspect golang:<version>-bookworm`.
1. If using repository variable `GO_VERSION`, confirm it matches a real upstream tag (example: `1.25.8`).

### 2. Invalid GO_VERSION Override

Symptom in workflow logs:

- Matrix resolves to one value, then digest or build steps fail.

What to do:

1. Check repository variable `GO_VERSION` in GitHub Actions settings.
1. Use semantic Go version format only (for example `1.25.8`, not `go1.25.8`).
1. Clear the variable to return to API-driven multi-version builds.

### 3. Docker Hub Login or Push Failure

Symptom in workflow logs:

- Login step fails, or push returns `denied`/`unauthorized`.

What to do:

1. Confirm `DOCKERHUB_TOKEN` secret exists and is valid.
1. Confirm Docker Hub username in the workflow matches the account that owns the token.
1. Recreate the token in Docker Hub and update the GitHub secret if token scope or expiration changed.

### 4. Context Warning for vars.GO_VERSION in Editor

Symptom in editor diagnostics:

- `Context access might be invalid: GO_VERSION`

What it means:

- This is often a static validation warning when the repository variable is not defined.
- Workflow runtime still works because the expression falls back to an empty string.

What to do:

1. Define repository variable `GO_VERSION` if you want override mode.
1. Leave it undefined if you want API-driven multi-version mode.

## Release Notes Label Mapping

GitHub release notes are generated from [.github/release.yml](.github/release.yml), and PR labels determine which section each change appears in.

Apply labels consistently to ensure entries land in the expected category.

### :warning: Breaking changes and deprecations

- `type: breaking`
- `type: deprecation`
- `type: regression`
- `type: revert`

### :whale: Image and runtime updates

- `type: release`
- `type: feat`
- `type: fix`
- `type: perf`
- `type: enhancement`
- `enhancement`
- `bug`

### :rocket: CI and build pipeline

- `type: ci`
- `type: build`
- `type: refactor`

### :book: Documentation and tests

- `type: docs`
- `type: test`
- `type: style`
- `documentation`

### :tools: Development dependency updates

- `github_actions`
- `javascript`
- `npm`
- `python`

### :package: Container dependency updates

- `dependencies`
- `docker`
- `go`

### :broom: Chores and maintenance

- `chore`
- `type: chore`
- `type: task`

### :grey_question: Other labeled changes

- `question`
- `invalid`
- `duplicate`
- `wontfix`

### Excluded from changelog

- `ignore-changelog`

### Note about commit message types

Conventional commit prefixes (for example `chore:` or `feat:`) do not automatically place PRs into a section unless matching labels are applied.

### PR checklist snippet

Copy and paste into PR descriptions:

```markdown
## Release Notes Checklist

- [ ] I applied at least one release label that matches `.github/release.yml`.
- [ ] If this PR should be excluded from release notes, I applied `ignore-changelog`.
- [ ] If this is a breaking change, I applied `type: breaking` and documented impact/migration notes.
```

## License

MIT
