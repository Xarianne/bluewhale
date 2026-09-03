# VS Code repo file (`files/dnf/vscode.repo`)

The `dnf` module's `repos.files:` supports `https://` URLs, but for VS Code we ship the
`.repo` file locally instead. Reason: the only repo file Microsoft hosts
(`https://packages.microsoft.com/yumrepos/vscode/config.repo`) ships with `gpgcheck=0`
and `repo_gpgcheck=0`, while the [official setup docs](https://code.visualstudio.com/docs/setup/linux)
have you create the file manually with `gpgcheck=1`.

BlueBuild has no way to override GPG checking on a URL-sourced repo file — it adds the
file verbatim, and its `no-gpgchecks` option only goes the other direction (disabling
checks). So the local file is the only way to install `code` with package signature
verification intact. The module's `repos.keys:` still handles importing
`https://packages.microsoft.com/keys/microsoft.asc`.

Note: the docs' template includes `autorefresh=1`, which we omit — dnf4 ignored unknown
options, but dnf5 (used by the module) hard-fails on it.
