# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

A personal custom [BlueBuild](https://blue-build.org/) Fedora Atomic image for someone who likes to tinker and experiment. Not intended for distribution. Published to `ghcr.io/xarianne/bluewhale`.

## Variants

Two image variants live in this repo (one build currently disabled):

- **`ghcr.io/xarianne/bluewhale:main`** (recipe: `recipes/recipe.yml`) — Silverblue (GNOME) with Hyprland + [Dank Material Shell](https://danklinux.com/) alongside. Builds on every push and daily.
- **`ghcr.io/xarianne/bluewhale:noctalia`** (recipe: `recipes/recipe-noctalia.yml`, *build currently disabled in the workflow matrix*) — Silverblue (GNOME) with the [Noctalia](https://noctalia.dev/) family instead: Noctalia shell, the Umbriel compositor, and Noctalia Greeter (via greetd) replacing GDM as the login screen. Details: [docs/noctalia.md](docs/noctalia.md). The last published image stays on GHCR but receives no updates while disabled; re-add the matrix entry in `build.yml` to resume.

Switch between them with `sudo bootc switch ghcr.io/xarianne/bluewhale:<tag>`.

- How the image is built and edited: [docs/building-conventions.md](docs/building-conventions.md)
- More docs: [docs/rpmfusion.md](docs/rpmfusion.md) · [docs/ublue-packages.md](docs/ublue-packages.md) · [docs/Workarounds.md](docs/Workarounds.md) · [docs/vscode-repo.md](docs/vscode-repo.md) · [Setup.md](Setup.md)

