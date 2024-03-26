## Install Nginx

- Set variables and add user, group

```bash
nginx_ver="1.24.0"
openssl1_ver="1.1.1w"

groupadd www
useradd -g www -M -s /usr/sbin/nologin www
```

- Download and unpack souce code

```bash
cd /usr/local/src
wget https://nginx.org/download/nginx-${nginx_ver}.tar.gz
wget https://www.openssl.org/source/old/1.1.1/openssl-${openssl1_ver}.tar.gz
tar zxf nginx-${nginx_ver}.tar.gz
tar zxf openssl-${openssl1_ver}.tar.gz
```

- Create dir, install and add environment variables

```bash
mkdir -p /usr/local/nginx /data/www/{wwwlogs,wwwroot}
cd nginx-${nginx_ver}
./configure --prefix=/usr/local/nginx \
--user=www \
--group=www \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_addition_module \
--with-http_xslt_module \
--with-stream \
--with-stream_ssl_preread_module \
--with-stream_ssl_module \
--with-http_gzip_static_module \
--with-http_realip_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-openssl=../openssl-${openssl1_ver} \
--with-pcre \
--with-pcre-jit \
--with-ld-opt='-ljemalloc'
make -j$(nproc) && make install

echo "export PATH=/usr/local/nginx/sbin:\$PATH" > /etc/profile.d/nginx.sh
source /etc/profile
```

- Create systemd file

Systemd file `/usr/lib/systemd/system/nginx.service` see [here](./nginx.service) , and then set auto start

```bash
systemctl enable nginx
```

- Configure conf file

create bak for `nginx.conf`

```bash
mv /usr/local/nginx/conf/nginx.conf{,_bk}
```

`/usr/local/nginx/conf/nginx.conf` see [here](./nginx.conf) , then add php config

```bash
[ -z "`grep '/php-fpm_status' /use/conf/nginx.conf`" ] &&  sed -i "s@index index.html index.php;@index index.html index.php;\n    location ~ /php-fpm_status {\n        #fastcgi_pass remote_php_ip:9000;\n        fastcgi_pass unix:/dev/shm/php-cgi.sock;\n        fastcgi_index index.php;\n        include fastcgi.conf;\n        allow 127.0.0.1;\n        deny all;\n        }@" /usr/local/nginx/conf/nginx.conf
```

`/usr/local/nginx/conf/proxy.conf` see [here](./proxy.conf)

- Add script and start

```bash
cat > /etc/logrotate.d/nginx << EOF
/data/wwwlogs/*nginx.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
  endscript
}
EOF

ldconfig
systemctl start nginx
```
