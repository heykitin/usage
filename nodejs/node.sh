#!/bin/bash
## export path
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

## get ip and country
get_ip() {
    ipv4=$(wget -qO- -t1 -T2 ipv4.icanhazip.com)
        [ -z "${ipv4}" ] && ipv4=$(wget -qO- -t1 -T2 ipinfo.io/ip)
    printf -- "%s" "${ipv4}"
}

get_ip_country() {
    local country=$(wget -qO- -t1 -T2 ipinfo.io/$(get_ip)/country)
    printf -- "%s" "${country}"
}

## install nodejs
installnode="1"
node_install_dir="/usr/local/node"
node_ver="v20.11.1"
nodeinstallmethod="1"

cd /usr/local/src

if [ "${installnode}" == "1" ]; then
    if [ "${nodeinstallmethod}" == "1" ]; then
        node_file_name=node-${node_ver}-linux-x64.tar.gz
    elif [ "${nodeinstallmethod}" == "2" ]; then
        node_file_name=node-${node_ver}.tar.gz
    fi
    if [ "$(get_ip_country)" == "CN" ]; then
        wget -t0 -c https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/${node_ver}/${node_file_name}
    else
        wget -t0 -c https://nodejs.org/dist/${node_ver}/${node_file_name}
    fi
    if [ "${installnode}" == "1" ] && [ "${nodeinstallmethod}" == "1" ]; then
        cd /usr/local/src
        tar zxf node-${node_ver}-linux-x64.tar.gz
        mv node-${node_ver}-linux-x64 ${node_install_dir}
    elif [ "${installnode}" == "1" ] && [ "${nodeinstallmethod}" == "2" ]; then
        cd /usr/local/src
        tar zxf node-${node_ver}.tar.gz
        cd node-${node_ver}
        ./configure --prefix=${node_install_dir}
        make -j$(nproc)
        make install
    fi
    if [ -e "${nodejs_install_dir}/bin/node" ]; then
        echo "export PATH=${node_install_dir}/bin:\$PATH" > /etc/profile.d/node.sh
        source /etc/profile
        rm -rf /usr/local/src/* && echo "Nodejs Install Success!"
    else
        echo "Nodejs Install Failed!"
    fi
else
    echo "Don't Install Nodejs"
fi