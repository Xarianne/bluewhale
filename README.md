# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A personal custom [BlueBuild](https://blue-build.org/) Fedora Atomic image for someone who likes to tinker and experiment. Not intended for distribution. Published to `ghcr.io/xarianne/bluewhale`.

## Variants

Four images are published from this repo, all built daily at 06:00 UTC and on every push to `main` (single images can be rebuilt manually via Actions → bluebuild → Run workflow):

- **`ghcr.io/xarianne/bluewhale:latest`** — Silverblue (GNOME) with Hyprland + [Dank Material Shell](https://danklinux.com/) alongside.
- **`ghcr.io/xarianne/bluewhale-testing:latest`** — same image on the branched pre-release Fedora (pinned to its version tag, e.g. `45`), with Bodhi karma tooling (`fedora-easy-karma`, `bodhi-client`); `updates-testing` is enabled by default during the pre-release phase. Details: [docs/fedora-testing.md](docs/fedora-testing.md)
- **`ghcr.io/xarianne/bluewhale-rawhide:latest`** — same image on Fedora Rawhide + karma tooling. Occasional build breakage is expected (that's Rawhide). Details: [docs/fedora-testing.md](docs/fedora-testing.md)
- **`ghcr.io/xarianne/bluewhale-noctalia:latest`** — experimental variant with the [Noctalia](https://noctalia.dev/) family instead, based on **Fedora stable**: Noctalia shell, Umbriel compositor, Noctalia Greeter (via greetd) replacing GDM. Umbriel is still rough around the edges (e.g. games intermittently losing mouse input). Details: [docs/noctalia.md](docs/noctalia.md)

Switch between them with `sudo bootc switch ghcr.io/xarianne/<image>:latest`.

### Why keep GNOME?
Taking a page from Tumbleweed's book. Hyprland and Umbriel are fast-moving, occasionally something breaks, so having a secondary desktop environment I can log into is a safety net.

## Docs

- How the image is built and edited: [docs/building-conventions.md](docs/building-conventions.md)
- More docs inside the docs folder.
