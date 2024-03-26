## Install Xanmod

Install nessray soft first
   
```bash
apt update && apt install -y gnupg
```

Then check platform compatibility:

```bash
awk -f <(wget -qO- https://dl.xanmod.org/check_x86-64_psabi.sh)

# output
CPU supports x86-64-v4
```

### Install From APT Repository

1. Register the PGP key:

```bash
wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
```

2. Add the repository:

```bash
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list
```

3. Update and Install

```bash
apt update
apt install -y linux-xanmod-x64v4
```

### Install From Deb 

Download form [source forge](https://sourceforge.net/projects/xanmod/files/releases/)

Then install soft:

```bash
dpkg -i linux-image-*xanmod*.deb linux-headers-*xanmod*.deb
```

After install, run `reboot`

### Configure

After download, run `uname -r` or `cat /proc/version` check install

```bash
uname -r

# output
6.7.6-x64v4-xanmod1
```

Run command follow to enable bbr and set congestion control algorithm to fq_pie

```bash
cat > /etc/sysctl.conf << EOF
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq_pie
EOF
```

More kernel parameter

```bash
cat > /etc/sysctl.conf << EOF
vm.swappiness = 1
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq_pie
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
EOF
```