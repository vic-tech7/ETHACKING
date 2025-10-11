# ETHACKING (Ethical OSINT & Recon Launcher)

**Author:** vic‑tech7  
**License:** MIT

ETHACKING is a menu-based launcher for educational, ethical reconnaissance and OSINT tools.
It provides a unified interface to run common tools (nmap, amass, theHarvester, Sherlock, etc.),
cloning missing tools on demand, showing live results and previews, and returning you to the main menu.

> ⚠️ **WARNING / ETHICS**  
> This software is strictly for **legal, authorized security testing**.  
> Do not use it against systems, networks, or targets without explicit permission.  
> Using tools on unauthorized systems may violate laws and be prosecutable.

## Quick start

```bash
git clone https://github.com/vic-tech7/ETHACKING.git
cd ETHACKING
chmod +x install_deps.sh ethacking.sh
sudo ./install_deps.sh        # optional: installs common dependencies
sudo ./ethacking.sh
