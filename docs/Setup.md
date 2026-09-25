# bluewhale &nbsp; [![bluebuild build badge](https://github.com/xarianne/bluewhale/actions/workflows/build.yml/badge.svg)](https://github.com/xarianne/bluewhale/actions/workflows/build.yml)

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

After setup, it is recommended you update this README to describe your custom image.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/xarianne/bluewhale:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/xarianne/bluewhale:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Umbriel config layout

`/etc/xdg/umbriel/config.toml` (baked in from `files/system-noctalia/`) is the
source of truth for the compositor config. However, Noctalia's theming module
rewrites `~/.config/umbriel/noctalia.toml` on theme changes and, if the user
config directory lacks a `config.toml`, regenerates a stub main file there —
which then shadows `/etc/xdg/umbriel/config.toml` entirely and loses all
keybinds. To prevent this, `~/.config/umbriel/config.toml` is an include-only
shim:

```toml
[include]
files = ["/etc/xdg/umbriel/config.toml", "noctalia.toml"]
```

Never put real settings in `~/.config/umbriel/` — edit the repo copy and
`pkexec cp` it to `/etc/xdg/umbriel/`.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/xarianne/bluewhale
```
