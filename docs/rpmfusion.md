# RPM Fusion setup (`recipes/packages/rpmfusion.yml` → `files/scripts/rpmfusion.sh`)

RPM Fusion provides multimedia codecs (ffmpeg) and mesa "freeworld" builds with patented
codec support, replacing Fedora's stripped packages.

## Why a script and not dnf modules

The dnf module's `replace:` translates to `dnf5 swap --from-repo …`, which
works — but across three Fedora streams (released / branched / rawhide) we
need exact control over what the module doesn't expose:

- **Transaction order**: the ffmpeg swap runs *before* the freeworld codec
  installs. Erasing the `ffmpeg-free` family up front removes the Conflicts
  that freeworld packages hit when rpmfusion's ffmpeg is ahead of Fedora's
  ffmpeg-free (seen on rawhide during the 8.1 → 9.0 bump).
- **The exact flags**: `--allowerasing` for the whole `*-free` family
  erasure, `--from-repo` restricted source — no translation-layer surprises.

## Repo installation is pinned to the master mirror

The release RPMs are installed from `download1.rpmfusion.org` (RPM Fusion's
canonical master), **not** via the dnf module's built-in `nonfree: rpmfusion`
shortcut. The built-in uses `mirrors.rpmfusion.org`, a redirector which has
served garbage (HTML error pages with HTTP 200) from out-of-sync mirrors,
producing "not a rpm" build failures. Dnf URL package downloads don't
retry/validate across mirrors the way repo metadata does.

The version number comes from `rpm -E %fedora` inside the build, so the same
script works on every stream (44 → 44, branched → 45, rawhide → 46; and
`rpmfusion-free-release-46` is the same bits as `-rawhide`).

The repos persist in the image intentionally so that:

- later modules can install from them (`steam` is in rpmfusion-nonfree)
- dnf/rpm-ostree can be used against them on the running system

## The ffmpeg swap's `--from-repo` lists two repos

`--from-repo rpmfusion-free,rpmfusion-free-updates` restricts where ffmpeg
may be taken from. On released Fedora ffmpeg lives in `-updates`; on the
branched pre-release and rawhide streams the `-updates` repo is empty and
ffmpeg lives in the frozen base repo — the two-name list covers all streams.
A `rpmfusion-free*` glob is avoided on purpose: it would also match the
`-updates-testing` repos.

`--allowerasing` replaces the whole ffmpeg `*-free` family
(`libavcodec-free`, `libswscale-free`, etc.) with `ffmpeg` + `ffmpeg-libs` in
one transaction. Verified: only the `*-free` packages are removed,
GNOME/mutter/webkitgtk are untouched.

## Rawhide caveat: soname skews self-heal

When rpmfusion rawhide jumps to a new ffmpeg major before Fedora rawhide's
ffmpeg-free follows, neither the swap nor the freeworld installs can resolve
(installed base packages need the old sonames), and that day's rawhide build
fails. No recipe change fixes this — Fedora catches up within days/weeks and
the daily builds go green on their own.

## mesa: plain install, no swap

Fedora has no standalone `mesa-va-drivers`/`mesa-vdpau-drivers` packages to
swap (VA/VDPAU lives in `mesa-dri-drivers`). RPM Fusion's
`mesa-va-drivers-freeworld` is a self-contained side-loaded package
(`/usr/lib64/dri-freeworld/`, own libgallium with h264/h265) covering both VA
and VDPAU — it obsoletes the old separate `mesa-vdpau-drivers-freeworld`.

## Why not just use the Universal Blue or Bluebuild base images?

Even though they do the codec swap themselves via negativo17, that swap has
been problematic as it pins the mesa to a slightly older version. Occasionally
said versions might have a regression, while Fedora progresses forward
to a version that might fix it. One such example is an AV1 regression that
was present in mesa 26.1.4, which negativo17 served. But Fedora had moved on to
26.1.8 which fixed the regression. So I decided to own the codec stack.
