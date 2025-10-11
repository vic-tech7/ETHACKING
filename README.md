# ETHACKING - Ethical OSINT & Recon Toolkit

![Banner](screenshots/banner.png) <!-- Replace with your screenshot path -->

> **Author:** [vic-tech7](https://github.com/vic-tech7)  
> **License:** [MIT](LICENSE)  
> **Purpose:** For ethical penetration testing, red teaming, and reconnaissance training

---

## 🔍 About ETHACKING

**ETHACKING** is a terminal-based toolkit that combines popular recon and OSINT tools into one unified, menu-driven launcher. It helps automate common reconnaissance tasks while maintaining a clean and organized interface.

The toolkit is ideal for:

- Bug bounty hunting
- Penetration testing
- OSINT research
- CTF and red team preparation

| Tool         | Purpose                         |
| ------------ | ------------------------------- |
| nmap         | Network scanning                |
| kismet       | Passive WiFi monitoring         |
| proxychains  | Anonymity (via Tor)             |
| PhoneInfoga  | Phone number OSINT              |
| Sherlock     | Social media username search    |
| theHarvester | Email, host, domain gathering   |
| amass        | Subdomain enumeration           |
| gobuster     | Directory & vhost brute-forcing |
| recon-ng     | Framework for web recon         |
| nikto        | Web vulnerability scanning      |

## 📸 Screenshots

### 🔧 ETHACKING Main Menu
![Menu](screenshots/menu.png)

 ETHACKING/
├── ethacking.sh            # Main launcher script

├── install_deps.sh         # Optional dependency installer

├── screenshots/            # Your screenshots (optional)

├── .github/workflows/    

├── .gitignore

├── README.md

└── LICENSE


> ⚠️ **WARNING / ETHICS**  
> This software is strictly for **legal, authorized security testing**.  
> Do not use it against systems, networks, or targets without explicit permission.  
> Using tools on unauthorized systems may violate laws and be prosecutable.

## Quick start
```bash
sudo ln -sf "$(pwd)/ethacking.sh" /usr/local/bin/ethacking
ethacking  # Now you can run it from anywhere


```bash
git clone https://github.com/vic-tech7/ETHACKING.git
cd ETHACKING
chmod +x ethacking.sh install_deps.sh

# Optional: install recommended tools
sudo ./install_deps.sh

# Run ETHACKING
sudo ./ethacking.sh


