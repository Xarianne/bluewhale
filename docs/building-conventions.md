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

## Notable behaviors

- **RPM Fusion** release RPMs are pinned to `download1.rpmfusion.org` rather than using the `dnf` module's `nonfree: rpmfusion` shortcut, because `mirrors.rpmfusion.org` (a redirector) has served garbage from out-of-sync mirrors and broken builds. Details: [rpmfusion.md](rpmfusion.md).
- **ujust**: the full Universal Blue setup (just recipes, udev rules) comes from the `ublue-os/packages` COPR so it tracks upstream; unwanted upstream recipes are *hidden* (not removed) via `just`'s `[private]` attribute by `files/scripts/hide-ujust-recipes.sh`. Details and hide list: [ublue-packages.md](ublue-packages.md).
- **Devbox auto-update**: own `devbox-update.timer`/`.service` in `files/system/usr/lib/systemd/user/`, enabled like `flatpak-user-update.timer`. It's a *user* timer because devbox's real binary lives per-user in `~/.cache/devbox/bin` (the `/usr/local/bin/devbox` launcher is a host-local install, not in the image), with a `ConditionPathExists` guard so it's a no-op until someone installs devbox. Runs `devbox version update` — updates launcher (in `/usr/local/bin`, user-owned) and binary — followed by `devbox global update` when a global env exists (`~/.local/share/devbox/global/default/devbox.json`). Afterwards it runs `devbox global shellenv --recompute`, because a headless `global update` deliberately leaves the state file (`~/.local/share/devbox/global/default/.devbox/state.json`) stale, which would make every new interactive shell print "Your devbox environment may be out of date. Run refresh-global ..." until someone recomputes. Project-level `devbox.json` envs are deliberately not covered: auto-rewriting `devbox.lock` files across repos would dirty git working trees — run `devbox update` in the project manually.
- **The Noctalia variant (Noctalia shell + Umbriel + Noctalia Greeter via greetd) lives on the `noctalia` branch**, parked because Umbriel still has rough edges (games intermittently losing pointer input). Push triggers are filtered to `main` in `build.yml` — on **both** branches, since GitHub evaluates the pushed branch's own workflow file — so branch pushes never build; manual `workflow_dispatch` on the branch publishes `br-noctalia-44`.
- **Tags come from `alt-tags`**: `recipe.yml` sets `[main]` so the image publishes as `:main` (alt-tags replace `latest`/timestamps). Bare custom tags like this are only possible from default-branch builds; BlueBuild always prefixes branch builds with `br-<branch>-`.
- **Initramfs is regenerated** at build time (`type: initramfs`, generic `--no-hostonly`) so the `tpm2-tss` dracut module is present — required for LUKS TPM2 auto-unlock. Fedora's base images build initramfs host-only in a container without TPM/LUKS, so they omit it.
- If you are an AI Agent: don't commit, push, or open PRs without explicit review and approval.
