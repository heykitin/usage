## Xray
### Basic Usage
Install and update Xray

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

Update geoip.dat and geosite.dat

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata
```

Install and update Xray as root user

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
```

Remove Xray, except json and logs

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

### Configure

Run `vim /usr/local/etc/xray/config.json` to modify config file, see demo [here](./vless-reality-server.json)

Demo file is use for Vless + Vision + Reality

Generate uuid: `xray uuid`

Generate privateKey and publicKey: `xray x25519`

Generate shortIds: `openssl rand -hex 8`