#!/usr/bin/env bash
# ETHACKING dependency installer for Kali/Debian
set -euo pipefail

echo "[*] Installing packages (Kali/Debian)... (requires sudo)"
sudo apt update -y

# UI & helpers
sudo apt install -y git figlet ruby jq curl python3 python3-pip build-essential

# lolcat via gem (may require ruby-dev)
if ! command -v lolcat >/dev/null 2>&1; then
  sudo apt install -y ruby-dev
  sudo gem install lolcat || true
fi

# security/OSINT tools
sudo apt install -y nmap nikto amass gobuster proxychains4 tor

# optional GUI/passive wifi
sudo apt install -y kismet || true

# Python pip packages commonly needed
sudo pip3 install --upgrade pip setuptools || true

echo "[*] Install complete (best-effort)."
echo "[*] Some tools (Sherlock, PhoneInfoga, theHarvester, recon-ng) will be cloned on demand and may require additional build steps."
echo "[*] Run ./ethacking.sh"
