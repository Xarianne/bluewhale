# AGENTS.md

Compact guidance for working on this BlueBuild image repository.

## What this repo is

- A personal custom Fedora Atomic image built with [BlueBuild](https://blue-build.org/). The desktop environment is not fixed.
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


## Editing conventions

- Prefer BlueBuild built-in modules. Consult the docs first: https://blue-build.org/learn/getting-started/
- Only add a custom script in `files/scripts/` when the built-in modules cannot do what you need.
  - Example: adding a COPR repo and installing from it should use the `dnf` module, not a custom script.
- Keep the recipe modular. Split related logic into files under `recipes/packages/` and `recipes/modules/`.
- Custom scripts must be explicitly referenced from `recipes/recipe.yml` to run during the build.

## Notable behavior

- `rpm-ostreed-automatic.timer` is enabled; the override at `files/system/etc/rpm-ostreed-automatic.timer.d/override.conf` sets `OnBootSec=15min` and `OnUnitInactiveSec=1d`.
- `files/system/etc/rpm-ostreed.conf` stages automatic updates (`AutomaticUpdatePolicy=stage`).
- Kernel argument `amdgpu.ppfeaturemask=0xffffffff` is injected via `recipes/modules/kargs.yml` (x86_64 only).
- COPR repos are cleaned up after the package install step (`cleanup: true`).

## Gotchas
- Do not `git commit`, `git push`, or open PRs without explicit user review and approval.
