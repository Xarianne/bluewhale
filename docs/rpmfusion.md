# RPM Fusion setup (`recipes/packages/rpmfusion.yml`)

The RPM Fusion repos are added for one consumer: `steam`
(rpmfusion-nonfree). The repos persist in the image so dnf/rpm-ostree can use
them on the running system too.

## Master-mirror pinning

The release RPMs are installed from `download1.rpmfusion.org` (RPM Fusion's
canonical master), **not** via the dnf module's built-in `nonfree: rpmfusion`
shortcut. The built-in uses `mirrors.rpmfusion.org`, a redirector which has
served garbage (HTML error pages with HTTP 200) from out-of-sync mirrors,
producing "not a rpm" build failures. Dnf URL package downloads don't
retry/validate across mirrors the way repo metadata does.

The version number uses the dnf module's `%OS_VERSION%`, so the same file
works on every stream (released → e.g. 44, branched → 45, rawhide → its
number, and `rpmfusion-free-release-<n>` is the same bits as `-rawhide`).

## Codec stack: dropped

This repo previously also swapped Fedora's codec-stripped ffmpeg/mesa for RPM
Fusion's full builds. That was removed: media codecs now come from app-side
bundles that don't depend on the OS image at all —

- **Mozilla's official Firefox tarball** (full h264/AAC, built-in updater);
  the Fedora `firefox` RPM is removed in `recipes/packages/packages.yml`
- **Flathub runtimes** for players/editors (ship full ffmpeg incl. x264/x265);
  flatpak OBS keeps VAAPI hw-encode via the runtime's un-stripped mesa
- **Proton** / game engines carry their own codecs

Benefits: no more codec soname-skew failures on branched/rawhide (a new ffmpeg
major landing in rpmfusion before Fedora's ffmpeg-free used to block those
builds for days), and no codec-patent-shaped transactions in the OS build.
The old implementation (last form: `files/scripts/rpmfusion.sh`) is in git
history if ever needed again.

## Why not the Universal Blue base images?

Historical note: originally about owning the codec stack — ublue/bluebuild
bases do the swap via negativo17, whose mesa pinning had caused an AV1
regression (mesa 26.1.4) that Fedora had already fixed (26.1.8). Moot now that
no codecs come from the OS; plain Fedora base stays out of preference for
owning the setup directly.
