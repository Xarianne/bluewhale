# Building conventions

How this image is built and how to edit it. Anything visible by reading
[`recipes/recipe.yml`](../recipes/recipe.yml) and the files it references is
intentionally not repeated here — this doc only covers the non-obvious "why".

## Building

- Four recipes on one branch: [`recipes/recipe.yml`](../recipes/recipe.yml) (main image), [`recipes/recipe-testing.yml`](../recipes/recipe-testing.yml) (Fedora branched pre-release + karma tools), [`recipes/recipe-rawhide.yml`](../recipes/recipe-rawhide.yml) (Fedora Rawhide + karma tools) and [`recipes/recipe-noctalia.yml`](../recipes/recipe-noctalia.yml) (experimental Noctalia/Umbriel variant). All build on every push to `main`, the daily schedule, and manual `workflow_dispatch` (the dropdown there rebuilds a single image on demand). All share everything under `recipes/packages/` via `from-file:`; variant-only bits are `recipes/packages/test-kit.yml` (karma tooling for testing/rawhide) and `files/system-noctalia/`. `Containerfile` is generated during the build (gitignored) — don't hand-edit it.
- Validate locally with `bluebuild validate`.

## Recipe conventions

- Prefer BlueBuild built-in modules over custom scripts in `files/scripts/` (e.g. adding a COPR + packages belongs in the `dnf` module).
- Custom scripts must be explicitly referenced from the recipe to run.
- Keep the recipe modular: split related logic into files under `recipes/packages/`.

## Notable behaviors

- **RPM Fusion** release RPMs are pinned to `download1.rpmfusion.org` rather than using the `dnf` module's `nonfree: rpmfusion` shortcut, because `mirrors.rpmfusion.org` (a redirector) has served garbage from out-of-sync mirrors and broken builds. Details: [rpmfusion.md](rpmfusion.md).
- **ujust**: Universal Blue's just recipes and update services come from the `ublue-os/packages` COPR so they track upstream; unwanted upstream recipes are *hidden* (not removed) via `just`'s `[private]` attribute by `files/scripts/hide-ujust-recipes.sh`. Details and hide list: [ublue-packages.md](ublue-packages.md).
- **Game-controller udev rules** are vendored in the repo: `files/system/usr/lib/udev/rules.d/*.rules` come from the upstream [`fabiscafe/game-devices-udev`](https://codeberg.org/fabiscafe/game-devices-udev) project (Codeberg), and `files/system/usr/lib/modules-load.d/uinput.conf` loads `uinput` at boot. They used to come packaged via a COPR, but that package is missing from its `fedora-45` repo, breaking the new variant builds — vendoring removes the dependency. To refresh: unpack the latest tag's `src/*.rules` over the vendored copies and commit.
- **The testing/rawhide variants are full clones of the main image** on the next Fedora track, differing only in `image-version` (`45` / `rawhide`) and the extra karma tooling from `recipes/packages/test-kit.yml`. The testing recipe's pin must be bumped to the next branched release after each Fedora GA; the rawhide recipe never needs a bump (rawhide is a floating tag, and the release-RPM URLs' `%OS_VERSION%` resolves to a number whose RPM Fusion release package is identical to `-rawhide`). Details: [fedora-testing.md](fedora-testing.md).
- **The Noctalia variant (Noctalia shell + Umbriel + Noctalia Greeter via greetd) is a fourth recipe, `recipes/recipe-noctalia.yml`**; Umbriel still has rough edges (games intermittently losing pointer input). It builds daily like the others. Details: [noctalia.md](noctalia.md).
- **Image names differ per recipe** (`bluewhale` / `bluewhale-testing` / `bluewhale-rawhide` / `bluewhale-noctalia`), each publishing plain `:latest` (+ an auto-generated version tag — `:44`, `:45`, the resolved rawhide number, and timestamp tags). Distinct names matter: recipes sharing one GHCR package would race to publish the version tag, and the last runner to finish would win.
- **Initramfs is regenerated** at build time (`type: initramfs`, generic `--no-hostonly`) so the `tpm2-tss` dracut module is present — required for LUKS TPM2 auto-unlock. Fedora's base images build initramfs host-only in a container without TPM/LUKS, so they omit it.
- If you are an AI Agent: don't commit, push, or open PRs without explicit review and approval.
