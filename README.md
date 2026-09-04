# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A personal custom [BlueBuild](https://blue-build.org/) Fedora Atomic image for someone who likes to tinker and experiment. Not intended for distribution. Published to `ghcr.io/xarianne/bluewhale`.

## Variants

Two images are published from this repo:

- **`ghcr.io/xarianne/bluewhale:main`** (recipe: `recipes/recipe.yml`) — Silverblue (GNOME) with Hyprland + [Dank Material Shell](https://danklinux.com/) alongside
- **`ghcr.io/xarianne/bluewhale:noctalia`** (recipe: `recipes/recipe-noctalia.yml`) — Silverblue (GNOME) with the [Noctalia](https://noctalia.dev/) family instead: Noctalia shell, the Umbriel compositor, and Noctalia Greeter (via greetd) replacing GDM as the login screen. Details: [docs/noctalia.md](docs/noctalia.md)

Switch between them with `sudo bootc switch ghcr.io/xarianne/bluewhale:<tag>`.

- How the image is built and edited: [docs/building-conventions.md](docs/building-conventions.md)
- More docs: [docs/rpmfusion.md](docs/rpmfusion.md) · [docs/ublue-packages.md](docs/ublue-packages.md) · [docs/Workarounds.md](docs/Workarounds.md) · [docs/vscode-repo.md](docs/vscode-repo.md) · [Setup.md](Setup.md)

