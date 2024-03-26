## Use V2ray On Linux

### Install V2day

#### Install By Command

If your network can direct connect Github, then run command follow to install: 

- install or update v2ray

```bash
apt update && apt install -y curl
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

#### Install By File

Down load file and unpack

```bash
v2ray_ver="v5.14.1"
wget https://github.com/v2fly/v2ray-core/releases/download/${v2ray_ver}/v2ray-linux-64.zip
unzip v2ray-linux-64.zip
```

Then move file to follow dir

```bash
mkdir /usr/local/share/v2ray /usr/local/etc/v2ray
mv v2ray /usr/local/bin/v2ray
mv geoip.dat /usr/local/share/v2ray/geoip.dat
mv geosite.dat /usr/local/share/v2ray/geosite.dat
mv systemd/system/* /etc/systemd/system
```

### Configure V2ray

Modify config file in `/usr/local/etc/v2ray/config.json` can see template above

Set auto start and start v2ray

```bash
systemctl enable v2ray
systemctl start v2ray
```

- Update geoip.dat and geosite.dat

```bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
```

- Remove V2ray

```bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
```
