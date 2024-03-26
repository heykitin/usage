## Install PHP

### Preparation

Set variable:

```bash
user="www" # set to caddy for caddy
group="www" # set to caddy for caddy
php_ver="8.3.4"
libiconv_ver="1.17"
```

Download source code:

```bash
cd /usr/local/src

# php
wget https://secure.php.net/distributions/php-${php_ver}.tar.gz

# libiconv
wget https://ftp.gnu.org/gnu/libiconv/libiconv-${libiconv_ver}.tar.gz
# for CN, use tsinghua mirror
wget https://mirrors.tuna.tsinghua.edu.cn/gnu/libiconv/libiconv-${libiconv_ver}.tar.gz
```

Install libiconv:

```bash
cd /usr/local/src
tar zxf libiconv-${libiconv_ver}.tar.gz
cd libiconv-${libiconv_ver}
./configure
make -j$(nproc)
make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/libc.conf
ldconfig
```

Install PHP:

```bash
cd /usr/local/src
tar zxf php-${php_ver}.tar.gz
cd php-${php_ver}
mkdir build-php && cd build-php
../configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-config-file-scan-dir=/usr/local/php/etc/php.d \
--with-fpm-user=${uesr} \
--with-fpm-group=${group} \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv=/usr/local/ \
--with-freetype \
--with-jpeg \
--with-zlib \
--with-password-argon2 \
--with-sodium \
--with-curl \
--with-openssl \
--with-mhash \
--with-xsl \
--with-gettext \
--with-zip \
--enable-fpm \
--enable-opcache \
--enable-mysqlnd \
--enable-xml \
--enable-bcmath \
--enable-shmop \
--enable-exif \
--enable-sysvsem \
--enable-mbregex \
--enable-mbstring \
--enable-gd \
--enable-pcntl \
--enable-sockets \
--enable-ftp \
--enable-intl \
--enable-soap \
--disable-fileinfo \
--disable-rpath \
--disable-debug
make ZEND_EXTRA_LIBS='-liconv' -j $(nproc)
make install
```

Add environment variables:

```bash
echo "export PATH=/usr/local/php/bin:\$PATH" > /etc/profile.d/php.sh
source /etc/profile
```

Copy `php.ini` and configure:

```bash
cp /usr/local/src/php-${php_ver}/php.ini-production /usr/local/php/etc/php.ini

# configure follow
memory_limit = 
output_buffering = On
short_open_tag = On
expose_php = Off
equest_order = "CGP"
date.timezone = Asia/Shanghai
post_max_size = 100M
upload_max_filesize = 50M
max_execution_time = 600
realpath_cache_size = 2M
disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen
```

`memory_limit` configure like follow:

```bash
# memory < 640M
memory_limit = 64

# memory 640M - 1280M
memory_limit = 128

# memory 1280M - 2500M
memory_limit = 192

# memory 2500M - 3500M
memory_limit = 256

# memory 3500M - 4500M
memory_limit = 320

# memory 4500M - 8000M
memory_limit = 384

#memory > 8000M
memory_limit = 448
```

Configure Opocache:

```bash
cat > /usr/local/php/etc/php.d/opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=100000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
;opcache.save_comments=0
opcache.consistency_checks=0
;opcache.optimization_level=0
EOF
```

> `opcache.memory_consumption=` is same as above `memory_limit` in **php.ini**

Add systemctl file at `/usr/local/systemd/system/php-fpm.service` see [here](./php-fpm.service)

Reload systemctl file and start php:

```bash
systemctl daemon-reload
systemctl enable php-fpm
```

Create `php-fpm.conf` at `/usr/local/php/etc/php-fpm.conf` 

```bash
cat > /usr/local/php/etc/php-fpm.conf << EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning

emergency_restart_threshold = 30
emergency_restart_interval = 60s
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[${user}]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = ${user}
listen.group = ${group}
listen.mode = 0666
user = ${user}
group = ${group}

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

pm.status_path = /php-fpm_status
slowlog = var/log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF
```

Configure `php-fpm.conf` like follow:

```bash
# memory < 3000M
pm.max_children = memory (Mb) /3/20
pm.start_servers = memory (Mb) /3/20
pm.min_spare_servers = memory (Mb) /3/20
pm.max_spare_servers = memory (Mb) /3/20

# memory 3000M - 4500M
pm.max_children = 50
pm.start_servers = 30
pm.min_spare_servers = 20
pm.max_spare_servers = 50

# memory 4500M - 6500M
pm.max_children = 60
pm.start_servers = 40
pm.min_spare_servers = 30
pm.max_spare_servers = 60

# memory 6500M - 8500M
pm.max_children = 70
pm.start_servers = 50
pm.min_spare_servers = 40
pm.max_spare_servers = 70

# memory > 8500M
pm.max_children = 80
pm.start_servers = 60
pm.min_spare_servers = 50
pm.max_spare_servers = 80
```