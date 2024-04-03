## Git Usage

### Global Config

Set global user and email

```bash
git config --global user.name user
git config --global user.email user@email.com
```

Add an exception for directory

```bash
git config --global --add safe.directory D:/path/to/dir

# or add all
git config --global --add safe.directory "*"
```

### Set SSH Key Login

Run command to create ssh key, file in ~/.ssh

```bash
ssh-keygen -t ed25519 -C "user"
```

Upload public key to github or gitee, then add key and test

```bash
ssh-add ~/.ssh/keygen
ssh -T git@github.com
```

### Configure Two Or More Key And Host

Create diferent ssh key, like github and gitee

```bash
# for github
ssh-keygen -t ed25519 -C "user" -f ~/.ssh/github

# for gitee
ssh-keygen -t ed25519 -C "user" -f ~/.ssh/gitee
```

Create config file to manage host and key

```bash
cat > ~/.ssh/config << EOF
# Github
Host github.com
HostName ssh.github.com
Port 443
User git
PreferredAuthentications publickey
IdentityFile ~/.ssh/github

# Gitee
Host gitee.com
HostName gitee.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/gitee
EOF
```

then add remote for local repositories

```bash
# github
git remote add origin git@github.com:user/repo.git

# gitee
git remote add origin git@gitee.com:user/repo.git
```

### Different User And Email

If you have different user and email, you should set them in different repositories with local config 

```bash
git config --local user.name user
git config --local user.email user@email.com
```

### Connet With Proxy

Add `ProxyCommand` to your config file

```bash
ProxyCommand connect -S 127.0.0.1:10808 %h %p

# for linux
ProxyCommand nc -X 5 -x 127.0.0.1:10808 %h %p
```

Full configuration

```bash
# Github
Host github.com
HostName ssh.github.com
ProxyCommand connect -S 127.0.0.1:10808 %h %p
Port 443
User git
PreferredAuthentications publickey
IdentityFile ~/.ssh/github

# Gitee
Host gitee.com
HostName gitee.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/gitee
```