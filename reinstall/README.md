## Reinstall

```bash
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh') -debian 12 -hostname "hostname" -port "prot" -pwd "password" -timezone "Asia/Shanghai" -swap "2048"
```

Servers in mainland of China:

```bash
bash <(wget --no-check-certificate -qO- 'https://gitee.com/mb9e8j2/Tools/raw/master/Linux_reinstall/InstallNET.sh') -debian 12 -mirror "https://mirrors.tuna.tsinghua.edu.cn/debian/" -hostname "hostname" -port "prot" -pwd "password" -timezone "Asia/Shanghai" -swap "2048"
```

If boot stuck after reinstall, use command follow:

```bash
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh') debian 12
```

Servers in mainland of China:

```bash
bash <(wget --no-check-certificate -qO- 'https://raw.gitmirror.com/bin456789/reinstall/main/reinstall.sh') debian 12
```

Default user and password:

Username: `root`
Password: `123@@@`

For OpenVZ/LXC VPS 

Run command follow

```bash
wget -qO OsMutation.sh https://raw.githubusercontent.com/LloydAsp/OsMutation/main/OsMutation.sh && chmod u+x OsMutation.sh && ./OsMutation.sh
```

or 

```bash
curl -so OsMutation.sh https://raw.githubusercontent.com/LloydAsp/OsMutation/main/OsMutation.sh && chmod u+x OsMutation.sh && ./OsMutation.sh
```

For vps whose disk is small (less than 1GiB, experimental support)

```bash
wget -qO OsMutation.sh https://raw.githubusercontent.com/LloydAsp/OsMutation/main/OsMutationTight.sh && chmod u+x OsMutation.sh && ./OsMutation.sh
```