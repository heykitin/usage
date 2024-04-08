#!/bin/bash
## export path
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

## install nginx
run_group="www"
run_user="www"
www_dir="/data/www"
logs_dir="/data/logs"
nginx_install_dir="/usr/local/nginx"
nginx_ver="1.24.0"
openssl1_ver="1.1.1w"


groupadd ${run_group}
useradd -g ${run_group} -M -s /usr/sbin/nologin ${run_user}

cd /usr/local/src
wget -t0 -c https://nginx.org/download/nginx-${nginx_ver}.tar.gz
wget -t0 -c https://www.openssl.org/source/old/1.1.1/openssl-${openssl1_ver}.tar.gz
tar zxf nginx-${nginx_ver}.tar.gz
tar zxf openssl-${openssl1_ver}.tar.gz
[ ! -d "${nginx_install_dir}" ] && mkdir -p ${nginx_install_dir}
[ ! -d "${logs_dir}" ] && mkdir -p ${logs_dir}
cd nginx-${nginx_ver}
./configure --prefix=${nginx_install_dir} \
--user=${run_user} \
--group=${run_group} \
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
make -j $(nproc) && make install

if [ -e "${nginx_install_dir}/conf/nginx.conf" ]; then
    rm -rf openssl-${openssl11_ver} nginx-${nginx_ver}
    echo "Nginx installed successfully!"
else
    rm -rf ${nginx_install_dir}
    echo "Nginx install failed, Please Contact the author!"
    kill -9 $$; exit 1;
  fi

echo "export PATH=${nginx_install_dir}/sbin:\$PATH" > /etc/profile.d/nginx.sh
source /etc/profile

cat > /usr/lib/systemd/system/nginx.service << 'EOF'
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPost=/bin/sleep 0.1
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
TimeoutStartSec=120
LimitNOFILE=1000000
LimitNPROC=1000000
LimitCORE=1000000

[Install]
WantedBy=multi-user.target
EOF

sed -i "s@/usr/local/nginx@${nginx_install_dir}@g" /usr/lib/systemd/system/nginx.service
systemctl enable nginx

mv ${nginx_install_dir}/conf/nginx.conf{,_bk}
cat > ${nginx_install_dir}/conf/nginx.conf << 'EOF'
user www www;
worker_processes auto;

error_log /data/logs/error_nginx.log crit;
pid /var/run/nginx.pid;
worker_rlimit_nofile 51200;

events {
  use epoll;
  worker_connections 51200;
  multi_accept on;
}

http {
  include mime.types;
  default_type application/octet-stream;
  server_names_hash_bucket_size 128;
  client_header_buffer_size 32k;
  large_client_header_buffers 4 32k;
  client_max_body_size 1024m;
  client_body_buffer_size 10m;
  sendfile on;
  tcp_nopush on;
  keepalive_timeout 120;
  server_tokens off;
  tcp_nodelay on;

  fastcgi_connect_timeout 300;
  fastcgi_send_timeout 300;
  fastcgi_read_timeout 300;
  fastcgi_buffer_size 64k;
  fastcgi_buffers 4 64k;
  fastcgi_busy_buffers_size 128k;
  fastcgi_temp_file_write_size 128k;
  fastcgi_intercept_errors on;

  #Gzip Compression
  gzip on;
  gzip_buffers 16 8k;
  gzip_comp_level 6;
  gzip_http_version 1.1;
  gzip_min_length 256;
  gzip_proxied any;
  gzip_vary on;
  gzip_types
    text/xml application/xml application/atom+xml application/rss+xml application/xhtml+xml image/svg+xml
    text/javascript application/javascript application/x-javascript
    text/x-json application/json application/x-web-app-manifest+json
    text/css text/plain text/x-component
    font/opentype application/x-font-ttf application/vnd.ms-fontobject
    image/x-icon;
  gzip_disable "MSIE [1-6]\.(?!.*SV1)";

  ##Brotli Compression
  #brotli on;
  #brotli_comp_level 6;
  #brotli_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;

  ##If you have a lot of static files to serve through Nginx then caching of the files' metadata (not the actual files' contents) can save some latency.
  #open_file_cache max=1000 inactive=20s;
  #open_file_cache_valid 30s;
  #open_file_cache_min_uses 2;
  #open_file_cache_errors on;

  log_format json escape=json '{"@timestamp":"$time_iso8601",'
                      '"server_addr":"$server_addr",'
                      '"remote_addr":"$remote_addr",'
                      '"scheme":"$scheme",'
                      '"request_method":"$request_method",'
                      '"request_uri": "$request_uri",'
                      '"request_length": "$request_length",'
                      '"uri": "$uri", '
                      '"request_time":$request_time,'
                      '"body_bytes_sent":$body_bytes_sent,'
                      '"bytes_sent":$bytes_sent,'
                      '"status":"$status",'
                      '"upstream_time":"$upstream_response_time",'
                      '"upstream_host":"$upstream_addr",'
                      '"upstream_status":"$upstream_status",'
                      '"host":"$host",'
                      '"http_referer":"$http_referer",'
                      '"http_user_agent":"$http_user_agent"'
                      '}';

######################## default ############################
  server {
    listen 80;
    server_name _;
    access_log /data/logs/access_nginx.log combined;
    root /data/www/default;
    index index.html index.htm index.php;
    #error_page 404 /404.html;
    #error_page 502 /502.html;
    location /nginx_status {
      stub_status on;
      access_log off;
      allow 127.0.0.1;
      deny all;
    }
    location ~ [^/]\.php(/|$) {
      #fastcgi_pass remote_php_ip:9000;
      fastcgi_pass unix:/dev/shm/php-cgi.sock;
      fastcgi_index index.php;
      include fastcgi.conf;
    }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
      expires 30d;
      access_log off;
    }
    location ~ .*\.(js|css)?$ {
      expires 7d;
      access_log off;
    }
    location ~ ^/(\.user.ini|\.ht|\.git|\.svn|\.project|LICENSE|README.md) {
      deny all;
    }
    location /.well-known {
      allow all;
    }
  }
########################## vhost #############################
  include vhost/*.conf;
}
EOF
[ -z "`grep '/php-fpm_status' ${nginx_install_dir}/conf/nginx.conf`" ] &&  sed -i "s@index index.html index.php;@index index.html index.php;\n    location ~ /php-fpm_status {\n        #fastcgi_pass remote_php_ip:9000;\n        fastcgi_pass unix:/dev/shm/php-cgi.sock;\n        fastcgi_index index.php;\n        include fastcgi.conf;\n        allow 127.0.0.1;\n        deny all;\n        }@" ${nginx_install_dir}/conf/nginx.conf

cat > ${nginx_install_dir}/conf/proxy.conf << EOF
proxy_connect_timeout 300s;
proxy_send_timeout 900;
proxy_read_timeout 900;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Referer \$http_referer;
proxy_set_header Cookie \$http_cookie;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
EOF

sed -i "s@/data/www/default@${www_dir}/default@" ${nginx_install_dir}/conf/nginx.conf
sed -i "s@/data/logs@${logs_dir}@g" ${nginx_install_dir}/conf/nginx.conf
sed -i "s@^user www www@user ${run_user} ${run_group}@" ${nginx_install_dir}/conf/nginx.conf

cat > /etc/logrotate.d/nginx << EOF
${logs_dir}/*nginx.log {
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
