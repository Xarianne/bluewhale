# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A personal custom [BlueBuild](https://blue-build.org/) Fedora Atomic image for someone who likes to tinker and experiment. Not intended for distribution. Published to `ghcr.io/xarianne/bluewhale`.

## The image

Silverblue (GNOME) with Hyprland + [Dank Material Shell](https://danklinux.com/) alongside.

Switch to it with `sudo bootc switch ghcr.io/xarianne/bluewhale:latest`.

### Why keep GNOME?
Taking a page from Tumbleweed's book. Hyprland and Umbriel are fast-moving, occasionally something breaks, so having a secondary desktop environment I can log into is a safety net.

## Docs

- How the image is built and edited: [docs/building-conventions.md](docs/building-conventions.md)
- More docs inside the docs folder.
