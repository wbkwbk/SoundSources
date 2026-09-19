#!/usr/bin/env bash
# Idempotent setup for the Balrog Sounds media/firmware toolchain.
#
# This repository has no compiled application. It is a collection of Lord of the
# Rings "Balrog" sound effects plus helper scripts. The pieces that are actually
# runnable on Linux are:
#   - Production/AudacityResultFadeOut/getPlayDuration.ps1  (PowerShell + ffmpeg)
#   - the ffmpeg/ffprobe audio pipeline used throughout Production/
#   - AFMHEX/firmware.hex  (AVR firmware, inspectable with binutils-avr)
#
# ffmpeg is already present in the base image; this script adds the missing
# tools (PowerShell and the AVR binutils) and is safe to run repeatedly.
set -euo pipefail

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

echo "==> Refreshing apt package index"
$SUDO apt-get update -y

echo "==> Ensuring ffmpeg and AVR firmware tools are installed"
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  ffmpeg \
  binutils-avr \
  avrdude

if ! command -v pwsh >/dev/null 2>&1; then
  echo "==> Installing PowerShell (pwsh)"
  source /etc/os-release
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -fsSL "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb" -o "$tmp_deb"
  $SUDO dpkg -i "$tmp_deb"
  rm -f "$tmp_deb"
  $SUDO apt-get update -y
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y powershell
else
  echo "==> PowerShell already installed: $(command -v pwsh)"
fi

echo "==> Toolchain versions"
ffmpeg -version | head -n 1
ffprobe -version | head -n 1
pwsh --version
avr-objdump --version | head -n 1

echo "==> Environment setup complete"
