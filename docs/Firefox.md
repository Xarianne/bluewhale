# Why are you installing the Firefox tarball from Mozilla?

Because I can't be bothered with codecs. I do sometimes install proprietary codecs in the image, but they are often a bit of an issue when I then want to use a testing or the rawhide image. I do QA for Fedora and the third party repos that handle those codecs, including RPM Fusion and Negativo 17, can get out of sync with those images. The tarball bundles its codecs, so you don't need to install them separately. 

Installed this way, the browser also still auto-updates, it also does it faster because it's directly from the source, so security updates can potentially land faster. If an auto-update ever introduces features I don't want after an update, then I just ditch the browser.

## So why not use the Firefox Flatpak?

Because the Flatpak sandboxing causes some issues with Firefox's own internal sandbox. That's the sandbox that makes it harder for websites to snoop on each other from other tabs. The Flatpak sandboxing restricts access to the Kernel's user namespaces (the stuff that makes a process think it is running as root), which weakens the isolation that Firefox provides between websites and makes it easier to exfiltrate cookies and other browser data.

## Isn't this a bit annoying to install though?
Yes, so I have created a just script for that. Running ujust install-firefox, will download and install the latest Firefox tarball from Mozilla, drops it into PATH and adds a desktop shortcut.
