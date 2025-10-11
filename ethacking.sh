#!/usr/bin/env bash
# ETHACKING - Ethical OSINT & Recon Toolkit (vic-tech7)
# Updated: results preview, IP changer banner, PhoneInfoga build, robust entrypoints
# Auto-elevates to root; clones tools into ./tools/ and runs them immediately.

set -euo pipefail
IFS=$'\n\t'

# Auto-elevate to root if not already
if [ "$EUID" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

TOOLS_DIR="./tools"
mkdir -p "$TOOLS_DIR"
TMP_DIR="./.ethacking_tmp"
mkdir -p "$TMP_DIR"

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

# Ensure UI & helper tools exist (best-effort installs)
command -v figlet >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y figlet >/dev/null 2>&1) || true
command -v lolcat >/dev/null 2>&1 || gem install lolcat >/dev/null 2>&1 || true
command -v jq >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y jq >/dev/null 2>&1) || true
command -v less >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y less >/dev/null 2>&1) || true
command -v git >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y git >/dev/null 2>&1) || true

# Header
header() {
  clear
  if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    figlet -f slant "ETHACKING" | lolcat -a -d 3
  elif command -v figlet >/dev/null 2>&1; then
    figlet -f slant "ETHACKING"
  else
    echo -e "${BOLD}${GREEN}=== ETHACKING ===${RESET}"
  fi
  echo -e "${CYAN}Author:${RESET} ${YELLOW}vic-tech7${RESET}"
  echo -e "${MAGENTA}Note: Always stay Ethical${RESET}"
  echo
}

# Menu
print_menu() {
  header
  local leftw=4
  local rightw=30

  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}     ${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "1)" "$rightw" "NETWORK_SCAN" \
    "$leftw" "2)" "$rightw" "PASSIVE_WIFI"
  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}     ${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "3)" "$rightw" "IP_CHANGER" \
    "$leftw" "4)" "$rightw" "IP_OSINT"
  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}     ${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "5)" "$rightw" "PHONE_OSINT" \
    "$leftw" "6)" "$rightw" "WEBSITE_SCANNER"
  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}     ${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "7)" "$rightw" "SOCIAL_OSINT" \
    "$leftw" "8)" "$rightw" "PEGASUS"
  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}     ${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "9)" "$rightw" "AMASS" \
    "$leftw" "10)" "$rightw" "THEHARVESTER"
  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}     ${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "11)" "$rightw" "GOBUSTER" \
    "$leftw" "12)" "$rightw" "RECON_NG"
  printf "${GREEN}%*s${RESET}  ${RED}%-*s${RESET}\n" \
    "$leftw" "13)" "$rightw" "EXIT"

  echo
}

_wait() {
  echo
  read -r -p $'Press Enter to return to menu...'
}

# Run command, stream to terminal (tee), save to file, then preview
# Usage: run_and_capture "command string" "outfile_prefix"
run_and_capture() {
  local cmd="$1"
  local prefix="$2"
  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local outfile="${TMP_DIR}/${prefix}_${ts}.log"
  echo -e "${CYAN}Command:${RESET} $cmd"
  echo -e "${CYAN}Logging to:${RESET} $outfile"
  # Run and stream
  bash -c "$cmd" 2>&1 | tee "$outfile" || true

  echo
  echo -e "${YELLOW}--- Preview (first 200 lines) ---${RESET}"
  sed -n '1,200p' "$outfile" || true
  echo -e "${YELLOW}--- End preview ---${RESET}"
  echo

  # Offer to view full output if less is available
  if command -v less >/dev/null 2>&1; then
    read -r -p $'View full output with less? (y/N): ' v
    if [[ "$v" =~ ^[Yy]$ ]]; then
      less "$outfile"
    fi
  else
    echo -e "${YELLOW}Install 'less' to view full logs comfortably: apt install less${RESET}"
  fi
}

# Clone-if-missing helper
git_clone_if_missing() {
  local repo_url="$1"
  local dest_dir="$2"
  if [ -d "$dest_dir" ]; then
    echo -e "${YELLOW}Already present: $dest_dir${RESET}"
    return 0
  fi
  echo -e "${CYAN}Cloning $repo_url -> $dest_dir${RESET}"
  git clone --depth 1 "$repo_url" "$dest_dir"
}

### TOOL FUNCTIONS ###

NETWORK_SCAN() {
  command -v nmap >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y nmap >/dev/null 2>&1) || true
  read -r -p $'Target (IP / range / domain): ' target
  outfile="nmap_${target//[^a-zA-Z0-9_.-]/_}.txt"
  cmd="nmap -sC -sV -oN \"$outfile\" \"$target\""
  echo -e "${GREEN}Running nmap...${RESET}"
  bash -c "$cmd" 2>&1 | tee "${TMP_DIR}/nmap_run_$(date +%s).log" || true
  echo
  if [ -f "$outfile" ]; then
    echo -e "${YELLOW}--- nmap output ($outfile) preview ---${RESET}"
    sed -n '1,200p' "$outfile" || true
    echo -e "${YELLOW}--- end preview ---${RESET}"
    if command -v less >/dev/null 2>&1; then
      read -r -p $'View full nmap output with less? (y/N): ' v
      if [[ "$v" =~ ^[Yy]$ ]]; then
        less "$outfile"
      fi
    fi
  fi
  _wait
}

PASSIVE_WIFI() {
  if ! command -v kismet >/dev/null 2>&1; then
    echo -e "${YELLOW}kismet not installed. Install it with: apt install kismet${RESET}"
    _wait
    return
  fi
  echo -e "${GREEN}Launching kismet (interactive; Ctrl+C to stop)${RESET}"
  kismet
  _wait
}

# Animated IP changer (shows progress, restarts tor, figlet banner, shows IPs)
IP_CHANGER() {
  apt-get update -y >/dev/null 2>&1 || true
  apt-get install -y tor proxychains4 curl >/dev/null 2>&1 || true

  echo -e "${CYAN}Changing your IP${RESET}"
  # animated dots
  for i in 1 2 3 4 5; do
    printf "%s" "."
    sleep 0.6
  done
  echo

  echo -e "${YELLOW}Restarting Tor to request a new circuit...${RESET}"
  systemctl restart tor || { echo -e "${YELLOW}systemctl restart failed, trying service tor restart...${RESET}"; service tor restart || true; }

  # wait a bit
  sleep 2

  # animated banner
  if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    figlet -f big "IP CHANGED" | lolcat -a -d 2
  elif command -v figlet >/dev/null 2>&1; then
    figlet -f big "IP CHANGED"
  else
    echo -e "${GREEN}IP CHANGED${RESET}"
  fi

  echo -e "${CYAN}Current external IP (direct):${RESET}"
  if command -v curl >/dev/null 2>&1; then
    curl -s https://ifconfig.me || true
  else
    echo -e "${YELLOW}curl not installed. apt install curl${RESET}"
  fi
  echo

  echo -e "${CYAN}External IP via proxychains4 (Tor):${RESET}"
  if command -v proxychains4 >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
    proxychains4 curl -s https://ifconfig.me || true
  else
    echo -e "${YELLOW}proxychains4 or curl missing. apt install proxychains4 curl${RESET}"
  fi

  echo
  echo -e "${GREEN}Done${RESET}"
  _wait
}

IP_OSINT() {
  read -r -p $'IP to lookup: ' ip
  command -v curl >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y curl >/dev/null 2>&1) || true
  cmd="curl -s \"https://ipinfo.io/${ip}/json\" | jq ."
  run_and_capture "$cmd" "ipinfo_${ip//[^a-zA-Z0-9_.-]/_}"
  _wait
}

PHONE_OSINT() {
  local repo="https://github.com/sundowndev/PhoneInfoga.git"
  local dest="$TOOLS_DIR/PhoneInfoga"
  git_clone_if_missing "$repo" "$dest"
  echo -e "${GREEN}PhoneInfoga directory: $dest${RESET}"

  # Build if it's Go source and binary missing
  if [ ! -f "$dest/phoneinfoga" ]; then
    echo -e "${YELLOW}Attempting to build PhoneInfoga (if source present)...${RESET}"
    if ! command -v go >/dev/null 2>&1; then
      echo -e "${YELLOW}Go not found. Installing golang...${RESET}"
      apt-get update -y >/dev/null 2>&1 || true
      apt-get install -y golang >/dev/null 2>&1 || true
    fi
    if [ -f "$dest/main.go" ]; then
      (cd "$dest" && go build -o phoneinfoga main.go) || true
    else
      if [ -d "$dest/cmd" ]; then
        (cd "$dest/cmd" && for d in *; do if [ -f "$d/main.go" ]; then (cd "$d" && go build -o ../../phoneinfoga main.go) && break; fi; done) || true
      fi
    fi
  fi

  # detect entrypoints
  if [ -f "$dest/phoneinfoga" ]; then
    read -r -p $'Phone number (with country code, e.g. +123...): ' number
    cmd="\"$dest/phoneinfoga\" scan -n \"$number\""
    run_and_capture "$cmd" "phoneinfoga_${number//[^a-zA-Z0-9+]/_}"
  elif [ -f "$dest/phoneinfoga.py" ]; then
    read -r -p $'Phone number (with country code, e.g. +123...): ' number
    cmd="python3 \"$dest/phoneinfoga.py\" scan -n \"$number\""
    run_and_capture "$cmd" "phoneinfoga_${number//[^a-zA-Z0-9+]/_}"
  elif command -v phoneinfoga >/dev/null 2>&1; then
    read -r -p $'Phone number (with country code, e.g. +123...): ' number
    cmd="phoneinfoga scan -n \"$number\""
    run_and_capture "$cmd" "phoneinfoga_${number//[^a-zA-Z0-9+]/_}"
  else
    echo -e "${YELLOW}Could not run PhoneInfoga automatically. Listing contents of $dest:${RESET}"
    ls -la "$dest"
    echo -e "${YELLOW}If PhoneInfoga requires a manual build, cd $dest and follow its README.${RESET}"
  fi
  _wait
}

WEBSITE_SCANNER() {
  command -v nikto >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y nikto >/dev/null 2>&1) || true
  read -r -p $'Target URL/domain: ' url
  outfile="nikto_${url//[^a-zA-Z0-9_.-]/_}.txt"
  cmd="nikto -h \"$url\" -output \"$outfile\""
  run_and_capture "$cmd" "nikto_${url//[^a-zA-Z0-9_.-]/_}"
  if [ -f "$outfile" ]; then
    echo -e "${YELLOW}--- nikto output preview ($outfile) ---${RESET}"
    sed -n '1,200p' "$outfile" || true
    if command -v less >/dev/null 2>&1; then
      read -r -p $'View full nikto output with less? (y/N): ' v
      if [[ "$v" =~ ^[Yy]$ ]]; then
        less "$outfile"
      fi
    fi
  fi
  _wait
}

SOCIAL_OSINT() {
  local repo="https://github.com/sherlock-project/sherlock.git"
  local dest="$TOOLS_DIR/Sherlock"
  git_clone_if_missing "$repo" "$dest"
  read -r -p $'Username to enumerate: ' user

  if [ -f "$dest/sherlock.py" ]; then
    cmd="python3 \"$dest/sherlock.py\" \"$user\""
    run_and_capture "$cmd" "sherlock_${user}"
  elif [ -f "$dest/sherlock/sherlock.py" ]; then
    cmd="python3 \"$dest/sherlock/sherlock.py\" \"$user\""
    run_and_capture "$cmd" "sherlock_${user}"
  elif command -v sherlock >/dev/null 2>&1; then
    cmd="sherlock \"$user\""
    run_and_capture "$cmd" "sherlock_${user}"
  else
    echo -e "${YELLOW}Cannot find Sherlock executable in $dest. Listing contents:${RESET}"
    ls -la "$dest"
  fi
  _wait
}

PEGASUS() {
  if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    figlet -f big "PLEASE STAY ETHICAL" | lolcat -a -d 2
  elif command -v figlet >/dev/null 2>&1; then
    figlet -f big "PLEASE STAY ETHICAL"
  else
    echo -e "${RED}PLEASE STAY ETHICAL${RESET}"
  fi
  _wait
}

AMASS() {
  command -v amass >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y amass >/dev/null 2>&1) || true
  read -r -p $'Domain to enumerate (e.g. example.com): ' domain
  outfile="amass_${domain//[^a-zA-Z0-9_.-]/_}.txt"
  cmd="amass enum -d \"$domain\" -o \"$outfile\""
  run_and_capture "$cmd" "amass_${domain//[^a-zA-Z0-9_.-]/_}"
  if [ -f "$outfile" ]; then
    echo -e "${YELLOW}--- amass output preview ($outfile) ---${RESET}"
    sed -n '1,200p' "$outfile" || true
    if command -v less >/dev/null 2>&1; then
      read -r -p $'View full amass output with less? (y/N): ' v
      if [[ "$v" =~ ^[Yy]$ ]]; then
        less "$outfile"
      fi
    fi
  fi
  _wait
}

THEHARVESTER() {
  local repo="https://github.com/laramies/theHarvester.git"
  local dest="$TOOLS_DIR/theHarvester"
  git_clone_if_missing "$repo" "$dest"
  read -r -p $'Domain (e.g. example.com): ' domain
  if [ -f "$dest/theHarvester.py" ]; then
    cmd="python3 \"$dest/theHarvester.py\" -d \"$domain\" -b all"
    run_and_capture "$cmd" "theharvester_${domain}"
  elif command -v theHarvester >/dev/null 2>&1; then
    cmd="theHarvester -d \"$domain\" -b all"
    run_and_capture "$cmd" "theharvester_${domain}"
  else
    echo -e "${YELLOW}theHarvester script not found; listing $dest:${RESET}"
    ls -la "$dest"
  fi
  _wait
}

GOBUSTER() {
  command -v gobuster >/dev/null 2>&1 || (apt-get update -y >/dev/null 2>&1 && apt-get install -y gobuster >/dev/null 2>&1) || true
  read -r -p $'Target URL/domain (e.g. https://example.com): ' target
  read -r -p $'Wordlist (full path) [default: /usr/share/wordlists/dirb/common.txt]: ' w
  w="${w:-/usr/share/wordlists/dirb/common.txt}"
  read -r -p $'Mode (dir/vhost) [dir]: ' mode
  mode="${mode:-dir}"
  if [ "$mode" = "vhost" ]; then
    cmd="gobuster vhost -u \"$target\" -w \"$w\""
  else
    cmd="gobuster dir -u \"$target\" -w \"$w\""
  fi
  run_and_capture "$cmd" "gobuster_$(date +%s)"
  _wait
}

RECON_NG() {
  local repo="https://github.com/lanmaster53/recon-ng.git"
  local dest="$TOOLS_DIR/recon-ng"
  git_clone_if_missing "$repo" "$dest"
  if command -v recon-ng >/dev/null 2>&1; then
    echo -e "${GREEN}Launching recon-ng interactive shell (Ctrl+D to exit)${RESET}"
    recon-ng
  elif [ -f "$dest/recon-ng" ]; then
    cmd="python3 \"$dest/recon-ng\""
    run_and_capture "$cmd" "reconng_$(date +%s)"
  else
    echo -e "${YELLOW}Recon-ng not found as executable. Listing $dest:${RESET}"
    ls -la "$dest"
  fi
  _wait
}

# Main loop
while true; do
  print_menu
  read -r -p $'Choose an option [1-13]: ' choice
  case "$choice" in
    1) NETWORK_SCAN ;;
    2) PASSIVE_WIFI ;;
    3) IP_CHANGER ;;
    4) IP_OSINT ;;
    5) PHONE_OSINT ;;
    6) WEBSITE_SCANNER ;;
    7) SOCIAL_OSINT ;;
    8) PEGASUS ;;
    9) AMASS ;;
    10) THEHARVESTER ;;
    11) GOBUSTER ;;
    12) RECON_NG ;;
    13) echo -e "${YELLOW}Goodbye${RESET}"; exit 0 ;;
    *) echo -e "${RED}Invalid choice${RESET}"; sleep 1 ;;
  esac
done
