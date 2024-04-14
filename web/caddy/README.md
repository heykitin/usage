## Caddy Server

### Install Caddy

1. Create dir, group add user

```bash
mkdir -p /etc/caddy/conf.d
mkdir -p /var/log/caddy
groupadd caddy
useradd -g caddy -m -d /var/lib/caddy -s /usr/sbin/nologin caddy
```

2. Download and unpack binary file, move it to install dir, grant permissions


```bash
caddy_ver="2.7.6"
cd /usr/local/src
wget https://github.com/caddyserver/caddy/releases/download/v${caddy_ver}/caddy_${caddy_ver}_linux_amd64.tar.gz
tar zxf caddy_${caddy_ver}_linux_amd64.tar.gz
mv caddy /usr/bin/
chmod +x /usr/bin/caddy
```

### Configure Caddy

1. Create web site and ssl dir (to store own certificates):

```bash
mkdir -p /data/www/default
mkdir -p /var/lib/caddy/ssl
```

2. Create systemd script and set auto start

```bash
cat > /usr/lib/systemd/system/caddy.service << EOF
[Unit]
Description=Caddy
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

systemctl enable caddy
```

1. Create Caddyfile and rewrite or see demo [here](./Caddyfile)

```bash
cat > /etc/caddy/Caddyfile << EOF
{
    admin off
    log {
        output file /var/log/caddy/access.log {
            roll_size 100mb
            roll_keep_for 15d
        }
    }
}

:80 {
    root * /data/www/default
    header {
        Strict-Transport-Security "max-age=31536000; preload"
        X-Content-Type-Options nosniff
        X-Frame-Options SAMEORIGIN
    }
    encode gzip
    # php_fastcgi unix//dev/shm/php-cgi.sock
    file_server
}
import /etc/caddy/conf.d/*.conf
EOF

caddy fmt --overwrite /etc/caddy/Caddyfile
wget https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html -O /data/www/default/index.html
```

2. grant permissions for dir

```bash
chown -R caddy:caddy /etc/caddy
chown -R caddy:caddy /var/lib/caddy
chown -R caddy:caddy /var/log/caddy
chown -R caddy:caddy /data/www
```

3. set file and dir permissions

```bash
chown -R caddy:caddy /data/www/
find /data/www/ -type d -exec chmod 755 {} \;
find /data/www/ -type f -exec chmod 644 {} \;
```

4. commad line

```bash
# rewrite config
caddy fmt --overwrite /etc/caddy/Caddyfile

# check config
caddy adapt -c /etc/caddy/Caddyfile

# reload caddy (if set "admin: off", cant use this command)
caddy reload -c /etc/caddy/Caddyfile

# if set admin off, use systemctl instead
systemctl restart caddy
```
