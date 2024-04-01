## Hysteria

### Install Hysteria

- Install and update main soft

```bash
bash <(curl -fsSL https://get.hy2.sh/)
```

- Uninstall

```bash
bash <(curl -fsSL https://get.hy2.sh/) --remove
```

### Configure Hysteria Server

- See demo [here](./config_server.yml)

```bash
vim /etc/hysteria/config.yaml
```

- Set auto start and start soft

```bash
systemctl enable hysteria-server
systemctl start hysteria-server
```

#### Set port hopping

For example, set port to 40000-50000

- iptables

```bash
# IPv4
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 40000:50000 -j DNAT --to-destination :8443
# IPv6
ip6tables -t nat -A PREROUTING -i eth0 -p udp --dport 40000:50000 -j DNAT --to-destination :8443
```

- ufw

Open ipforward on sysctl

```bash
sudo tee /etc/sysctl.d/99-forward.conf >/dev/null <<EOT
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOT

sysctl --system
```

run `ifconfig` to get if-cfg, then edit `/etc/ufw/before.rules` and add:

```bash
cat >> /etc/ufw/before.rules <<EOF
# port forwarding
*nat
:PREROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p udp --dport 40000:50000 -j DNAT --to-destination :8443
COMMIT
EOF
```

Reconfigure hysteria config, add option:

```yaml
transport:
  udp:
    hopInterval: 30s
```

#### Set Certificate

Generate self-signed certificate

```bash
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /var/lib/hysteria/server.key -out /var/lib/hysteria/server.crt -subj "/CN=bing.com" -days 3650 && chown hysteria /var/lib/hysteria/server.key && chown hysteria /var/lib/hysteria/server.crt
```

### Directives of Hysteria Server

```bash
# Start Hysteria
systemctl start hysteria-server

# Restart Hysteria
systemctl restart hysteria-server

# Cat Hysteria Status
systemctl status hysteria-server

# Stop Hysteria
systemctl stop hysteria-server

# Set Autostart
systemctl enable hysteria-server

# Cat Log
journalctl -u hysteria-server
```
