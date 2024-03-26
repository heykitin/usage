## Waline
### Install Waline

- For CN set npm mirror first

```bash
npm config set registry https://registry.npmmirror.com
```

Install waline

```bash
npm install -g @waline/vercel
```

Create systemd file and set auto start

systemd file at [here](/locked/waline.service)

```bash
vim /use/lib/systemd/system/waline.service
```

Set auto start and start soft

```bash
systemctl enable waline
systemctl start waline
```
