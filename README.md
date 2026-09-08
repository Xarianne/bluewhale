# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A personal custom [BlueBuild](https://blue-build.org/) Fedora Atomic image for someone who likes to tinker and experiment. Not intended for distribution. Published to `ghcr.io/xarianne/bluewhale`.

## Variants

Two images are published from this repo:

- **`ghcr.io/xarianne/bluewhale:latest`** — Silverblue (GNOME) with Hyprland + [Dank Material Shell](https://danklinux.com/) alongside. Builds on every push to `main` and daily at 06:00 UTC.
- **`ghcr.io/xarianne/bluewhale-noctalia:latest`** — experimental variant with the [Noctalia](https://noctalia.dev/) family instead: Noctalia shell, Umbriel compositor, Noctalia Greeter (via greetd) replacing GDM. **Manual builds only** (Actions → bluebuild → Run workflow); parked because Umbriel is still rough around the edges (e.g. games intermittently losing mouse input). Details: [docs/noctalia.md](docs/noctalia.md)

Switch between them with `sudo bootc switch ghcr.io/xarianne/<image>:latest`.

### Why keep GNOME?
Taking a page from Tumbleweed's book. Hyprland and Umbriel are fast-moving, occasionally something breaks, so having a secondary desktop environment I can log into is a safety net.

- How the image is built and edited: [docs/building-conventions.md](docs/building-conventions.md)
- More docs: [docs/rpmfusion.md](docs/rpmfusion.md) · [docs/ublue-packages.md](docs/ublue-packages.md) · [docs/Workarounds.md](docs/Workarounds.md) · [docs/vscode-repo.md](docs/vscode-repo.md) · [Setup.md](Setup.md)

