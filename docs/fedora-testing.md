# Fedora testing & Rawhide notes

Why the second and third images exist: running Fedora's development streams
on a second disk and propping [Bodhi](https://bodhi.fedoraproject.org) karma.
Both are full clones of the main image, differing only in `image-version` plus
the karma toolset from [`recipes/packages/test-kit.yml`](../recipes/packages/test-kit.yml)
(`fedora-easy-karma` + `bodhi-client`).

Throughout this doc, **45** is just the example: read it as "the currently
branched pre-release Fedora", and **46** as "the then-current rawhide".

## `bluewhale-testing` = the branched release

- Base: `quay.io/fedora/fedora-silverblue:45` — the branched pre-release
  Fedora, published as nightly composes (`45.<date>.n.0` tags). A release
  goes: rawhide → branched → Beta → GA (final release), and this image
  tracks the middle part.
- **`updates-testing` is enabled by default during the pre-release phase** —
  that's exactly what makes the base image "the testing image", so the recipe
  deliberately does no repo juggling. At GA a `fedora-release` update flips
  `updates_testing_enabled` off, and keeping the image on the released version
  afterwards is just stable Fedora again.
- **Freezes** (a few weeks around the Beta and Final milestones) pause
  *stable pushes*: the compose repo only takes blocker/freeze-exception fixes,
  so the nightly base churns less during those windows. `updates-testing`
  keeps flowing the whole time — freeze karma on blockers is the most
  valuable kind.
- **Recurrent chore**: after each Fedora GA, bump `image-version` in
  [`recipes/recipe-testing.yml`](../recipes/recipe-testing.yml) to the next
  branched number (e.g. `45` → `46`), once that branch exists. There is no
  floating `branched` tag, so this can't be automated via the tag — the
  recipe comment repeats the reminder.

## `bluewhale-rawhide`

- Base: `quay.io/fedora/fedora-silverblue:rawhide` — the floating,
  always-rolling development stream. **Never bump `image-version`.**
  BlueBuild resolves the number itself from the base image's os-release at
  build time; it only shows up in the auto-generated version tags (e.g.
  `:46` while F46 is rawhide, silently becoming `:47` after the next branch
  point).
- RPM Fusion needs no rawhide-specific handling in the recipe: `%OS_VERSION%`
  resolves to that same number, and for the current rawhide number `n` the
  `rpmfusion-free-release-<n>` package is the same bits as `-rawhide`.
- **Bodhi karma does not apply to rawhide builds** — rawhide updates bypass
  Bodhi gating; karma flows through branched + stable `updates-testing` only.
  The rawhide image is for early bug hunting and test days; the karma tools
  ride along anyway so the image stays a superset of the testing one.
- Expect **occasional failed daily builds** when rawhide churn breaks a COPR
  or RPM Fusion package — e.g. a major ffmpeg version landing in rpmfusion
  before Fedora rawhide's ffmpeg-free follows (soname skew), which blocks the
  codec swap until Fedora catches up. A failed build just means no new image
  that day — the installed system keeps working and picks up the next good one.

## Giving karma

Karma needs a [Fedora account](https://accounts.fedoraproject.org) (FAS).

- On the **testing image**, new testing content arrives through the daily
  rebuilds (the nightly base tracks the branched stream). To grab a specific
  candidate update ad hoc: `rpm-ostree install <pkg>` pulls from
  `updates-testing` since it's enabled (clean up later with
  `rpm-ostree uninstall <pkg>`).
- Then run **`fedora-easy-karma`**: it auto-detects installed
  updates-testing packages, shows each update's info and other testers'
  comments, and lets you comment + ±1 karma straight from the terminal —
  follow its first-run auth prompts.
- For browsing/targeting: **`bodhi-client`** (e.g.
  `bodhi updates query --releases f45 --status testing`) or the
  [Bodhi web UI](https://bodhi.fedoraproject.org). The
  [feedback guidelines](https://fedoraproject.org/wiki/QA:Update_feedback_guidelines)
  explain when ±1 is appropriate.

Install/rebase the second disk per [Setup.md](../Setup.md), pointing at
`ghcr.io/xarianne/bluewhale-testing:latest` or `-rawhide`, and switch streams
any time with `sudo bootc switch ghcr.io/xarianne/<image>:latest`.

Background docs:
[QA:Updates Testing](https://fedoraproject.org/wiki/QA:Updates_Testing) ·
[Fedora Easy Karma](https://fedoraproject.org/wiki/Fedora_Easy_Karma) ·
[Branched](https://docs.fedoraproject.org/en-US/releases/branched/) ·
[Rawhide](https://docs.fedoraproject.org/en-US/releases/rawhide/)
