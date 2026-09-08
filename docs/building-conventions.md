# Building conventions

How this image is built and how to edit it. Anything visible by reading
[`recipes/recipe.yml`](../recipes/recipe.yml) and the files it references is
intentionally not repeated here — this doc only covers the non-obvious "why".

## Building

- Two recipes on one branch: [`recipes/recipe.yml`](../recipes/recipe.yml) (main image; push to `main`, daily, manual) and [`recipes/recipe-noctalia.yml`](../recipes/recipe-noctalia.yml) (experimental Noctalia/Umbriel variant; manual `workflow_dispatch` only — the gated `noctalia` job in [`build.yml`](../.github/workflows/build.yml)). Both share everything under `recipes/packages/` via `from-file:`; variant-only files live in `files/system-noctalia/`. `Containerfile` is generated during the build (gitignored) — don't hand-edit it.
- Validate locally with `bluebuild validate`.

## Recipe conventions

- Prefer BlueBuild built-in modules over custom scripts in `files/scripts/` (e.g. adding a COPR + packages belongs in the `dnf` module).
- Custom scripts must be explicitly referenced from the recipe to run.
- Keep the recipe modular: split related logic into files under `recipes/packages/`.

## Notable behaviors

- **RPM Fusion** release RPMs are pinned to `download1.rpmfusion.org` rather than using the `dnf` module's `nonfree: rpmfusion` shortcut, because `mirrors.rpmfusion.org` (a redirector) has served garbage from out-of-sync mirrors and broken builds. Details: [rpmfusion.md](rpmfusion.md).
- **ujust**: the full Universal Blue setup (just recipes, udev rules) comes from the `ublue-os/packages` COPR so it tracks upstream; unwanted upstream recipes are *hidden* (not removed) via `just`'s `[private]` attribute by `files/scripts/hide-ujust-recipes.sh`. Details and hide list: [ublue-packages.md](ublue-packages.md).
- **The Noctalia variant (Noctalia shell + Umbriel + Noctalia Greeter via greetd) is a second recipe, `recipes/recipe-noctalia.yml`**, parked because Umbriel still has rough edges (games intermittently losing pointer input). It builds only via manual workflow dispatch; the `if:` gate in `build.yml` has a commented one-line alternative that also builds it on the daily schedule. Details: [noctalia.md](noctalia.md).
- **Tags come from `alt-tags`**: `recipe.yml` sets `[main]` and `recipe-noctalia.yml` sets `[noctalia]` (alt-tags replace `latest`/timestamps). The Noctalia recipe deliberately uses a distinct `name:` (`bluewhale-noctalia`): two recipes sharing `bluewhale` would race to publish the auto-generated version tag (`:44`) on the same GHCR package, and the last runner to finish would win.
- **Initramfs is regenerated** at build time (`type: initramfs`, generic `--no-hostonly`) so the `tpm2-tss` dracut module is present — required for LUKS TPM2 auto-unlock. Fedora's base images build initramfs host-only in a container without TPM/LUKS, so they omit it.
- If you are an AI Agent: don't commit, push, or open PRs without explicit review and approval.
