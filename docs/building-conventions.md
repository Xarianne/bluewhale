# Building conventions

How this image is built and how to edit it. Anything visible by reading
[`recipes/recipe.yml`](../recipes/recipe.yml) and the files it references is
intentionally not repeated here — this doc only covers the non-obvious "why".

## Building

- The single recipe is [`recipes/recipe.yml`](../recipes/recipe.yml); CI builds and pushes on every change. `Containerfile` is generated during the build (gitignored) — don't hand-edit it.
- Validate locally with `bluebuild validate`.

## Recipe conventions

- Prefer BlueBuild built-in modules over custom scripts in `files/scripts/` (e.g. adding a COPR + packages belongs in the `dnf` module).
- Custom scripts must be explicitly referenced from the recipe to run.
- Keep the recipe modular: split related logic into files under `recipes/packages/`.

## Notable behaviors (the non-obvious why)

- **RPM Fusion** release RPMs are pinned to `download1.rpmfusion.org` rather than using the `dnf` module's `nonfree: rpmfusion` shortcut, because `mirrors.rpmfusion.org` (a redirector) has served garbage from out-of-sync mirrors and broken builds. Details: [rpmfusion.md](rpmfusion.md).
- **ujust**: the full Universal Blue setup (just recipes, udev rules) comes from the `ublue-os/packages` COPR so it tracks upstream; unwanted upstream recipes are *hidden* (not removed) via `just`'s `[private]` attribute by `files/scripts/hide-ujust-recipes.sh`. Details and hide list: [ublue-packages.md](ublue-packages.md).
- **`uupd.timer` is deliberately not enabled**: OS auto-updates stay on our `rpm-ostreed-automatic.timer` setup; `ujust toggle-updates` can switch at runtime.
- **Noctalia Greeter (greetd) is the login screen, not GDM**: `gdm.service` is disabled and `greetd.service` enabled (both alias `display-manager.service`). GNOME stays installed and selectable, but GNOME-from-greetd is upstream "best-effort". Details: [noctalia.md](noctalia.md).
- **Initramfs is regenerated** at build time (`type: initramfs`, generic `--no-hostonly`) so the `tpm2-tss` dracut module is present — required for LUKS TPM2 auto-unlock. Fedora's base images build initramfs host-only in a container without TPM/LUKS, so they omit it.
- If you are an AI Agent: don't commit, push, or open PRs without explicit review and approval.
