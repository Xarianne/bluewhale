# Fedora testing & Rawhide notes

Why the second and third images exist: running Fedora's development streams
on a second disk and propping [Bodhi](https://bodhi.fedoraproject.org) karma.
Both are full clones of the main image, differing only in `image-version` plus
the karma toolset from [`recipes/packages/test-kit.yml`](../recipes/packages/test-kit.yml)
(`fedora-easy-karma` + `bodhi-client`).

## `bluewhale-testing` = the branched release

- Base: `quay.io/fedora/fedora-silverblue:45` — the branched **F45 pre-release**
  (branched from Rawhide Aug 2026; GA ~end Oct 2026), rebuilt as nightly
  composes (`45.<date>.n.0` tags). Built daily like the others.
- **`updates-testing` is enabled by default during the pre-release phase** —
  that's exactly what makes the base image "the testing image", so the recipe
  deliberately does no repo juggling. At GA a `fedora-release` update flips
  `updates_testing_enabled` to 0 and the image becomes plain stable F45.
- **Freezes** (Beta ~mid-Sept, Final ~2 weeks before GA) pause *stable pushes*:
  the compose repo only takes blocker/freeze-exception fixes, so the nightly
  base churns less for a few weeks. `updates-testing` keeps flowing the whole
  time — freeze karma on blockers is the most valuable kind.
- **Recurrent chore**: after each Fedora GA, bump `image-version: 45` → the
  next branched version (46, then 47, ...) in
  [`recipes/recipe-testing.yml`](../recipes/recipe-testing.yml) — once the new
  branch exists (~Aug branch point / shortly after GA). There is no floating
  `branched` tag, so this can't be automated via the tag. The recipe comment
  says the same thing.

## `bluewhale-rawhide`

- Base: `quay.io/fedora/fedora-silverblue:rawhide` — the floating, always-
  rolling development stream. **Never bump `image-version`.** BlueBuild
  resolves the actual number (46 as of Sept 2026) from the base image's
  os-release at build time; it only shows up in the auto-generated version
  tags (`:46` today, `:47` after the next branch point).
- RPM Fusion needs no rawhide-specific handling in the recipe: `%OS_VERSION%`
  resolves to that same number, and `rpmfusion-free-release-<n>` is identical
  to `-rawhide` (verified byte-for-byte when this was set up).
- **Bodhi karma does not apply to rawhide builds** — rawhide updates bypass
  Bodhi gating; karma flows through branched + stable `updates-testing` only.
  The rawhide image is for early bug hunting and test days; the karma tools
  ride along anyway so the image stays a superset of the testing one.
- Expect **occasional failed daily builds** when rawhide churn breaks a COPR
  package (all six COPRs used here had `fedora-rawhide` chroots as of Sept
  2026, but rawhide is rawhide). A failed build just means no new image that
  day — the installed system keeps working and picks up the next good one.

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
