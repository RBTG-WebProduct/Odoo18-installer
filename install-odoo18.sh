#!/bin/bash

LOG_FILE="/var/log/odoo18-install.log"

# Create the log file with appropriate permissions
sudo touch "$LOG_FILE"
sudo chown "$USER":"$USER" "$LOG_FILE"

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

exec > >(tee -a "$LOG_FILE") 2>&1

set -e

log "🚀 Starting Odoo 18 installation on Ubuntu 24.04..."

# Update system
# log "🔄 Updating system packages..."
# export DEBIAN_FRONTEND=noninteractive
# sudo apt-get update
# sudo apt-get -y -o Dpkg::Options::="--force-confdef" \
#                 -o Dpkg::Options::="--force-confold" \
#                 dist-upgrade



# Install dependencies
log "📦 Installing system dependencies..."
sudo apt install -y git python3-pip build-essential wget python3-dev \
  python3-venv libxslt-dev libzip-dev libldap2-dev libsasl2-dev \
  python3-setuptools node-less libjpeg-dev gdebi libpq-dev \
  libxml2-dev libffi-dev libssl-dev libjpeg8-dev liblcms2-dev \
  libblas-dev libatlas-base-dev libpq-dev libtiff5-dev \
  libopenjp2-7-dev npm

# Install and configure PostgreSQL
log "🐘 Installing PostgreSQL and creating user..."
sudo apt install -y postgresql
sudo -u postgres createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo18

# Add Odoo system user
log "👤 Creating Odoo system user..."
sudo useradd -m -d /opt/odoo18 -U -r -s /bin/bash odoo18

# Clone Odoo and set up virtual environment
log "📥 Cloning Odoo 18 source and creating Python virtual environment..."
sudo -u odoo18 -H bash << EOF
cd /opt/odoo18
git clone https://www.github.com/odoo/odoo --depth 1 --branch 18.0 --single-branch .
python3 -m venv odoo18-venv
source odoo18-venv/bin/activate
pip install wheel
pip install -r requirements.txt
deactivate
EOF

# Create custom addons directory
log "📁 Creating custom addons directory..."
sudo mkdir /opt/odoo18/custom-addons
sudo chown -R odoo18: /opt/odoo18/custom-addons

# Install Caddy
log "🌐 Installing Caddy web server..."
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy
sudo systemctl enable --now caddy

# Set up automatic security updates
log "🔒 Setting up unattended-upgrades for automatic security updates..."
log "🔒 Installing and configuring unattended-upgrades non-interactively..."
sudo apt-get install unattended-upgrades -y

# Enable unattended upgrades via config
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades

log "✅ Unattended-upgrades installed and enabled without user interaction."


# Install SSHGuard
log "🛡️ Installing and enabling SSHGuard for SSH protection..."
sudo apt install -y sshguard
sudo systemctl enable --now sshguard.service

log "📝 SSHGuard config file is located at: /etc/sshguard/sshguard.conf"
log "✅ Security hardening steps completed."


log "✅ Odoo 18 and Caddy installed successfully. All output saved to $LOG_FILE"
