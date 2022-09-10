#!/bin/bash
set -e

# Ensure required CLI tools are installed
swupd bundle-add jq curl  > /dev/null 2>&1

# Ensure there is no Telegraf files in /tmp
rm -rf /tmp/telegraf*

# Get latest release
latest_rel=$(curl https://api.github.com/repos/influxdata/telegraf/releases/latest -s | jq .name -r)
latest_rel=${latest_rel:1}

# Download binary
curl -L -o /tmp/telegraf-${latest_rel}_linux_amd64.tar.gz https://dl.influxdata.com/telegraf/releases/telegraf-${latest_rel}_linux_amd64.tar.gz

# Extract
cd /tmp
tar -xvzf telegraf-${latest_rel}_linux_amd64.tar.gz

# Install files
cp -f telegraf-${latest_rel}/usr/bin/telegraf /usr/bin/telegraf
mkdir -p /etc/telegraf
cat > /etc/systemd/system/telegraf.service<< EOF
[Unit]
Description=Telegraf service
After=network.target

[Service]
ExecStart=/usr/bin/telegraf -config /etc/telegraf/telegraf.conf
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

echo
echo
echo "Create /etc/telegraf.conf file and enable/start service:"
echo "  systemctl enable --now telegraf.service"
echo
echo "If telegraf is already installed and you just updated it:"
echo "  systemctl restart telegraf.service"
