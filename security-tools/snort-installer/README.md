# Snort 3 Installer

A Bash installer that automates the installation of Snort 3 and all required dependencies on a clean Linux server.

---

## Features

- Installs all required system packages
- Downloads dependencies from their official sources
- Compiles and installs each dependency
- Installs Snort 3 from source
- Interactive debug menu to install individual components
- Designed to simplify updates by centralizing dependency versions and download URLs
---

## Supported Platform

- Ubuntu 24.04 LTS (currently tested)

Other Debian-based distributions may work but have not been tested.

---

## Requirements

- Root privileges
- Internet connection
- Clean Linux installation

---

## Usage

Download the installer:

```bash
https://raw.githubusercontent.com/BaAmadoCamunas/cybersecurity/refs/heads/main/security-tools/snort-installer/SnortInstaller.sh
```

Make it executable:

```bash
chmod +x SnortInstaller.sh
```

Run it:

```bash
sudo ./SnortInstaller.sh
```

---

## Project Status

This project is currently under development.

---

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
See the `LICENSE` file for details.

The installer is being implemented and tested dependency by dependency.



