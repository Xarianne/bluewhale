#!/bin/bash

set -ouex pipefail

dnf5 install -y '@cosmic-desktop'

systemctl mask cosmic-greeter.service
systemctl mask cosmic-greeter-daemon.service
