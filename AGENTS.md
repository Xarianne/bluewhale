# AGENTS.md

Compact guidance for working on this BlueBuild image repository.

## What this repo is

- A personal custom Fedora Kinoite (Atomic) image built with [BlueBuild](https://blue-build.org/).
- Image name: `bluewhale`; published to `ghcr.io/xarianne/bluewhale`.
- Not intended for distribution.

## Build entry point

- The single recipe is [`recipes/recipe.yml`](recipes/recipe.yml). It drives the whole image build.
- CI is [`/.github/workflows/build.yml`](.github/workflows/build.yml) and uses the `blue-build/github-action` reusable action.
- `Containerfile` is generated during the build and gitignored. Do not hand-edit it.

## Local validation

- The `bluebuild` CLI is installed on this machine.
- `bluebuild -h` lists available commands.
- Run `bluebuild validate` to validate [`recipes/recipe.yml`](recipes/recipe.yml) locally.
- There is no local test suite; CI is the primary verification.

## Repo layout

- `recipes/recipe.yml` — main recipe that includes sub-files in order.
- `recipes/packages/*.yml` — BlueBuild `dnf`, `default-flatpaks`, and similar package/flatpak/repo modules.
- `recipes/modules/*.yml` — non-package modules such as kernel arguments.
- `files/system/` — overlay files copied into the image root (`/`).
- `files/scripts/` — custom build-time scripts; only referenced here, not executed unless listed in the recipe.
- `modules/` — empty placeholder for custom BlueBuild modules.
- `files/system/nix/.gitkeep` — exists only so the overlay creates `/nix`; no custom script needed for this.
- `cosign.pub` / `cosign.key` — Sigstore signing keys. The private key is gitignored; never commit or expose it.

## Editing conventions

- Prefer BlueBuild built-in modules. Consult the docs first: https://blue-build.org/learn/getting-started/
- Only add a custom script in `files/scripts/` when the built-in modules cannot do what you need.
  - Example: adding a COPR repo and installing from it should use the `dnf` module, not a custom script.
- Keep the recipe modular. Split related logic into files under `recipes/packages/` and `recipes/modules/`.
- Custom scripts must be explicitly referenced from `recipes/recipe.yml` to run during the build.

## Notable behavior

- `files/system/etc/udev/rules.d/60-steam-input.rules` — custom Steam/controller udev rules overlay.
- `rpm-ostreed-automatic.timer` is enabled; the override at `files/system/etc/rpm-ostreed-automatic.timer.d/override.conf` sets `OnBootSec=15min` and `OnUnitInactiveSec=1d`.
- `files/system/etc/rpm-ostreed.conf` stages automatic updates (`AutomaticUpdatePolicy=stage`).
- Kernel argument `amdgpu.ppfeaturemask=0xffffffff` is injected via `recipes/modules/kargs.yml` (x86_64 only).
- COPR repos are cleaned up after the package install step (`cleanup: true`).
- `recipes/packages/kwallet-fix.yml` masks the legacy `kwalletd6` D-Bus activation so only `ksecretd` runs. This works around a `kf6-kwallet` 6.29.0 regression where both daemons run concurrently and qtkeychain credentials don't persist across reboots (e.g. Nextcloud flatpak re-auths every boot). Upstream: https://invent.kde.org/frameworks/kwallet/-/work_items/11

## Gotchas

- `*.iso`, `*.iso-CHECKSUM`, `Containerfile`, and `.bluebuild-scripts_*` are generated artifacts and gitignored.
- Dependabot only watches `github-actions` updates daily.
- `CODEOWNERS` was updated to `@xarianne`.
- Do not `git commit`, `git push`, or open PRs without explicit user review and approval.
