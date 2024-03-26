## Filebrowser

### Install Filebrowser

```bash
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
```

### Configure Filebrowser

1. Create datebase dir and datebase

```bash
mkdir /usr/local/lib/filebrowser
filebrowser -d /usr/local/lib/filebrowser/filebrowser.db config init
```

2. Configure

```bash
filebrowser -d /usr/local/lib/filebrowser/filebrowser.db config set -a 0.0.0.0 -p 8800 -r /var/filebrowser -b /pan --log /var/log/filebrowser.log --locale zh-cn
```

3. Create user and password

```bash
filebrowser -d /usr/local/lib/filebrowser/filebrowser.db users add kitin kitin@PAN0105 --perm.admin --locale zh-cn
```

4. Create systemd file

```bash
cat > /usr/lib/systemd/system/filebrowser.service<< EOF
[Unit]
Description=File Browser
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/filebrowser -d /usr/local/lib/filebrowser/filebrowser.db
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable filebrowser
systemctl start filebrowser
```