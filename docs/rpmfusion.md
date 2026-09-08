# RPM Fusion setup (`recipes/packages/rpmfusion.yml`)

RPM Fusion provides multimedia codecs and mesa "freeworld" builds with patented
codec support, replacing Fedora's stripped packages.

## Repo installation is pinned to the master mirror

The release RPMs are installed from `download1.rpmfusion.org` (RPM Fusion's
canonical master), **not** via the dnf module's built-in `nonfree: rpmfusion`
shortcut. The built-in uses `mirrors.rpmfusion.org`, a redirector which has
served garbage (HTML error pages with HTTP 200) from out-of-sync mirrors,
producing "not a rpm" build failures. Dnf URL package downloads don't
retry/validate across mirrors the way repo metadata does.

The repos persist in the image intentionally (no cleanup) so that:

- later modules can install from them (`steam` is in rpmfusion-nonfree)
- dnf/rpm-ostree can be used against them on the running system

## Two dnf module entries

The codec packages need the rpmfusion repos, which only exist after the
release RPMs are installed — hence the separate first module.

## mesa: plain install, no swap

Fedora 44 has no standalone `mesa-va-drivers`/`mesa-vdpau-drivers` packages to
swap (VA/VDPAU lives in `mesa-dri-drivers`). RPM Fusion's
`mesa-va-drivers-freeworld` is a self-contained side-loaded package
(`/usr/lib64/dri-freeworld/`, own libgallium with h264/h265) covering both VA
and VDPAU — it obsoletes the old separate `mesa-vdpau-drivers-freeworld`.

## ffmpeg swap needs `allow-erasing`

The whole ffmpeg `*-free` family (`libavcodec-free`, `libswscale-free`, etc.)
must be replaced by `ffmpeg` + `ffmpeg-libs` in one transaction;
`allow-erasing: true` enables that. Verified on the F44 base: only the 8
`*-free` packages are removed, GNOME/mutter/webkitgtk are untouched.

All of the above was verified by hand in a container on
`quay.io/fedora/fedora-silverblue:44`.

## Why not just use the Universal Blue or Bluebuild base images?

Even though they do the codec swap themselves via negativo17, that swap has been 
problematic as it pins the mesa to a slightly older version. Occasionally said
versions might have a regression, while Fedora progresses forward
to a version that might fix it. One such example is an AV1 regression that 
was present in mesa 26.1.4, which negativo17 served. But Fedora had moved on to
26.1.8 which fixed the regression. So I decided to own the codec stack.
