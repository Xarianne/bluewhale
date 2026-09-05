# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A personal custom [BlueBuild](https://blue-build.org/) Fedora Atomic image for someone who likes to tinker and experiment. Not intended for distribution. Published to `ghcr.io/xarianne/bluewhale`.

## Variants

- **`ghcr.io/xarianne/bluewhale:main`** — Silverblue (GNOME) with Hyprland + [Dank Material Shell](https://danklinux.com/) alongside. Builds on every push to `main` and daily at 06:00 UTC.

There is also an experimental **Noctalia** variant (Noctalia shell, Umbriel compositor, Noctalia Greeter via greetd replacing GDM) on the [`noctalia` branch](https://github.com/Xarianne/bluewhale/tree/noctalia). It never builds automatically — trigger it manually via Actions → bluebuild → Run workflow → `noctalia`, which publishes `ghcr.io/xarianne/bluewhale:br-noctalia-44`. Parked because Umbriel is still rough around the edges (e.g. games intermittently losing mouse input).

Switch between them with `sudo bootc switch ghcr.io/xarianne/bluewhale:<tag>`.

- How the image is built and edited: [docs/building-conventions.md](docs/building-conventions.md)
- More docs: [docs/rpmfusion.md](docs/rpmfusion.md) · [docs/ublue-packages.md](docs/ublue-packages.md) · [docs/Workarounds.md](docs/Workarounds.md) · [docs/vscode-repo.md](docs/vscode-repo.md) · [Setup.md](Setup.md)

