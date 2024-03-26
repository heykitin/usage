## V2ray

### Install V2ray

- Install and update main soft

```bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

- Update geoip.dat and geosite.dat

```bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
```

### Configure V2ray

- Choose a config above

```bash
vim /usr/local/etc/v2ray/config.json
```

- Set auto start and start soft

```bash
systemctl enable v2ray
systemctl start v2ray
```
