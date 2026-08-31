# Dank Material Shell notes

Notes on integrating DMS with a KDE-based atomic Fedora image.

## Qt6 theming for KDE-based base images

When the base image is Kinoite (KDE-based), plasmalogin sets `QT_QPA_PLATFORMTHEME=gtk3` in the session environment. Hyprland inherits this value, so Dolphin and other Qt applications use the GTK3 platform theme and ignore DMS colours and icons. DMS's "Apply Qt Colors" button also fails because `qt6ct` is not installed.

### Fix

Three changes are required.

#### 1. Install `qt6ct`

Add `qt6ct` to the install list in `recipes/packages/dms-hyprland.yml`:

```yaml
  install:
    packages:
    - dgop
    - dms
    - hyprland
    - matugen
    - quickshell
    - ghostty
    - qt6ct # Only if running KDE
```

Rebuild and rebase to pick up the new package.

#### 2. Set environment variables

Add the following to `~/.config/environment.d/90-dms.conf` (for systemd and D-Bus activated services):

```
QT_QPA_PLATFORMTHEME=qt6ct
QT_QPA_PLATFORMTHEME_QT6=qt6ct
```

#### 3. Set Hyprland process environment

Add `hl.env()` calls in `~/.config/hypr/hyprland.lua` inside the `DMS_STARTUP_BEGIN` block, before `dbus-update-activation-environment`:

```lua
hl.on("hyprland.start", function()
    hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
    hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    ...
```

Without this, Hyprland's process keeps the `gtk3` value inherited from plasmalogin, and applications launched from Hyprland (including Dolphin) ignore `qt6ct.conf`.

#### 4. Apply Qt colours in DMS

After rebooting, open DMS Settings → Theme & Colors and toggle "Apply Qt Colors". This runs the `qt.sh` script, which writes `custom_palette=true` and `color_scheme_path` into `~/.config/qt6ct/qt6ct.conf`, pointing to the generated `DankMatugen.colors` palette.

Log out and back in for all changes to take effect.

## Kitty pulled in as a weak dependency of hyprland

The `hyprland` package from the `sdegler/hyprland` COPR lists `kitty` in its `Recommends`. Because dnf installs recommended packages by default, `kitty` is pulled in automatically when `hyprland` is installed — it does not need to be listed explicitly in the recipe.

### Removing kitty

Add `kitty` to the `remove.packages` list in the dnf module (e.g. `recipes/packages/dms-hyprland.yml`):

```yaml
  remove:
    packages:
    - kitty
```

If kitty is removed, update the terminal setting in `~/.config/environment.d/90-dms.conf` (`TERMINAL=kitty`) and in DMS settings to point to another terminal (e.g. `ghostty`).