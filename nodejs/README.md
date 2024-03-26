## Install Nodejs
### Install From Source Code

```bash
node_ver="v20.11.1"
mkdir -p /usr/local/node
cd /usr/local/src
wget https://nodejs.org/dist/${node_ver}/node-${node_ver}.tar.gz

# for CN, use tsinghua mirror
wget https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/${node_ver}/node-${node_ver}.tar.gz
tar zxf node-${node_ver}.tar.gz
cd node-${node_ver}
./configure --prefix=/usr/local/node
make -j$(nproc)
make install
```

### Install From Binary File

```bash
node_ver="v20.11.1"
mkdir -p /usr/local/node
cd /usr/local/src
wget https://nodejs.org/dist/${node_ver}/node-${node_ver}-linux-x64.tar.gz

# for CN, use tsinghua mirror
wget https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/${node_ver}/node-${node_ver}-linux-x64.tar.gz
tar zxf node-${node_ver}-linux-x64.tar.gz
mv node-${node_ver}-linux-x64 /usr/local/node
```

## Add Environment Variables

```bash
echo "export PATH=/usr/local/node/bin:\$PATH" > /etc/profile.d/node.sh
source /etc/profile
```