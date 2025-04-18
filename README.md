# Odoo 18 Installer

This repository provides a full setup script for installing **Odoo 18** and **Caddy web server** on Ubuntu 24.04. The script sets up:

- System packages
- Python virtual environment (`odoo18-venv`)
- PostgreSQL user
- Odoo source (branch 18.0)
- Caddy as a reverse proxy
- Logging to `/var/log/odoo18-install.log`

## 🚀 Quick Start

Run the installer in one line:

```bash
bash <(curl -s https://raw.githubusercontent.com/RBTG-WebProduct/Odoo18-installer/main/install-odoo18.sh)
```

## 📁 Files

- `install-odoo18.sh`: Full automated installer with logs.
- `README.md`: This file.

## 📌 Notes

- Make sure you run the script as a user with `sudo` privileges.
- Logs are written to `/var/log/odoo18-install.log`.

---

Made with ❤️ by [RBTG Web Product](https://github.com/RBTG-WebProduct)
