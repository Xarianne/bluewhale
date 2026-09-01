# Workarounds

These are temporary fixes applied in the image while waiting for upstream resolution. They will be removed once the upstream projects ship a proper fix.

### Plasma login manager not registering keystrokes

Only applies when image uses KDE. Occasionally, when the Plasma login manager starts, it won't register keystrokes at the password prompt. A 3-second delay is added before the service starts to work around this race condition.

- **File:** `files/system/etc/systemd/system/plasmalogin.service.d/override.conf`
