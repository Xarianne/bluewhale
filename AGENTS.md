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

- The base image is plain Fedora Atomic (`quay.io/fedora/fedora-silverblue`), not Universal Blue.
- `recipes/packages/rpmfusion.yml` adds RPM Fusion by installing the release RPMs from `download1.rpmfusion.org` (pinned; `mirrors.rpmfusion.org` is an unreliable redirector, so the module's `nonfree: rpmfusion` shortcut is not used; repos persist since later modules install `steam` from rpmfusion-nonfree), installs `mesa-va-drivers-freeworld` (side-loaded full-codec VA/VDPAU stack; Fedora 44 has no standalone mesa-va/vdpau-drivers to swap), installs codec packages, and swaps `ffmpeg-free` for full `ffmpeg` (with `allow-erasing` to replace the `*-free` ffmpeg family).
- `recipes/packages/ublue.yml` installs the full Universal Blue ujust setup from the `ublue-os/packages` COPR (`ublue-os-just`, `ublue-os-update-services`, `ublue-os-udev-rules`, `uupd`) plus the Fedora tools its recipes call, so `ujust` (incl. BlueBuild's `60-custom.just`) and the game-devices udev rules track upstream on each rebuild. `uupd.timer` is NOT enabled — automatic updates stay on `rpm-ostreed-automatic.timer` (`ujust toggle-updates` can switch at runtime).
- `rpm-ostreed-automatic.timer` is enabled; the override at `files/system/etc/rpm-ostreed-automatic.timer.d/override.conf` sets `OnBootSec=15min` and `OnUnitInactiveSec=1d`.
- `files/system/etc/rpm-ostreed.conf` stages automatic updates (`AutomaticUpdatePolicy=stage`).
- Kernel argument `amdgpu.ppfeaturemask=0xffffffff` is injected via `recipes/modules/kargs.yml` (x86_64 only).
- COPR repos are cleaned up after the package install step (`cleanup: true`).

## Gotchas
- Do not `git commit`, `git push`, or open PRs without explicit user review and approval.
