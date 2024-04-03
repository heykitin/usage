## Base Set

### Security Setting

- Change password

```bash
passwd
```

#### SSH Setting

- Change SSH port, base security

run `vim /etc/ssh/sshd_config` , and configure follow:

```bash
Port 1234

LoginGraceTime 1m
PermitRootLogin yes
MaxAuthTries 3
MaxSessions 5

PasswordAuthentication yes
PermitEmptyPasswords no
```

- Set security key login

Run command follow to generate a key:

```bash
ssh-keygen -t ed25519 -C "user"

# output
Generating public/private ed25519 key pair.
Enter file in which to save the key (/root/.ssh/id_ed25519):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_ed25519
Your public key has been saved in /root/.ssh/id_ed25519.pub
The key fingerprint is:
The key's randomart image is:
```

Rename public key and download private key to local dir

```bash
mv ~/.ssh/ed25519 authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Modify `/vim/etc/ssh/sshd_config` set security key login:

```bash
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys .ssh/authorized_keys2
PasswordAuthentication no
PermitEmptyPasswords no
```

Restart sshd

```bash
systemctl restart sshd
```

### Install Base Soft For Web

```bash
apt update && apt dist-upgrade -y && apt autoremove -y && apt autoclean
apt install -y debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf libjpeg62-turbo-dev libjpeg-dev libpng-dev libwebp7 libwebp-dev libfreetype6 libfreetype6-dev libssh2-1-dev libmhash2 libpcre3 libpcre3-dev gzip libbz2-1.0 libbz2-dev libgd-dev libxml2 libxml2-dev libsodium-dev argon2 libargon2-1 libargon2-dev libiconv-hook-dev zlib1g zlib1g-dev libc6 libc6-dev libc-client2007e-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev numactl libreadline-dev curl libcurl3-gnutls libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11-dev openssl net-tools libssl-dev libtool libevent-dev bison re2c libsasl2-dev libxslt1-dev libicu-dev locales patch vim zip unzip tmux htop bc dc expect libexpat1-dev libonig-dev libtirpc-dev rsync git lsof lrzsz rsyslog cron logrotate chrony libsqlite3-dev psmisc wget sysv-rc apt-transport-https ca-certificates software-properties-common gnupg

```

Reboot 
