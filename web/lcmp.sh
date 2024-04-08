#!/bin/bash
## export path
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

## check memory
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

Mem=`free -m | awk '/Mem:/{print $2}'`

if [ $Mem -le 640 ]; then
	Mem_level=512M
	Memory_limit=64
	THREAD=1
elif [ $Mem -gt 640 -a $Mem -le 1280 ]; then
	Mem_level=1G
	Memory_limit=128
elif [ $Mem -gt 1280 -a $Mem -le 2500 ]; then
	Mem_level=2G
	Memory_limit=192
elif [ $Mem -gt 2500 -a $Mem -le 3500 ]; then
	Mem_level=3G
	Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ]; then
	Mem_level=4G
	Memory_limit=320
elif [ $Mem -gt 4500 -a $Mem -le 8000 ]; then
	Mem_level=6G
	Memory_limit=384
elif [ $Mem -gt 8000 ]; then
	Mem_level=8G
	Memory_limit=448
fi

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

## set variable
run_user="caddy"
run_group="caddy"
mariadb_install_dir="/usr/local/mariadb"
mariadb_data_dir="/data/mariadb"
php_install_dir="/usr/local/php"
timezone="Asia/Shanghai"
redis_install_dir="/usr/local/redis"
memcached_install_dir="/usr/local/memcached"
imagick_install_dir="/usr/local/imagemagick"
www_dir="/data/www"
wwwlogs_dir="/data/wwwlogs"
dbinstallmethod="1"
dbrootpwd="kitin@DB0105"

## soft version
caddy_ver="2.7.6"
boost_ver="1.84.0"
boost_ver2="$(echo ${boost_ver} | awk -F. '{print $1"_"$2"_"$3}')"
jemalloc_ver="5.3.0"
mariadb_ver="10.11.7"
php_ver="8.3.4"
imagick_ver="7.1.1-29"
pecl_imagick_ver="3.7.0"
redis_ver="7.2.4"
pecl_redis_ver="6.0.2"
memcached_ver="1.6.24"
libmemcaached_ver="1.0.18"
pecl_memcached_ver="3.2.0"
libiconv_ver="1.17"
phpmyadmin_ver="5.2.1"

## update && install base soft
apt update
apt install -y debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf libjpeg62-turbo-dev libjpeg-dev libpng-dev libwebp7 libwebp-dev libfreetype6 libfreetype6-dev libssh2-1-dev libmhash2 libpcre3 libpcre3-dev gzip libbz2-1.0 libbz2-dev libgd-dev libxml2 libxml2-dev libsodium-dev argon2 libargon2-1 libargon2-dev libiconv-hook-dev zlib1g zlib1g-dev libc6 libc6-dev libc-client2007e-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev numactl libreadline-dev curl libcurl3-gnutls libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11-dev openssl net-tools libssl-dev libtool libevent-dev bison re2c libsasl2-dev libxslt1-dev libicu-dev locales patch vim zip unzip tmux htop bc dc expect libexpat1-dev libonig-dev libtirpc-dev rsync git lsof lrzsz rsyslog cron logrotate chrony libsqlite3-dev psmisc wget sysv-rc apt-transport-https ca-certificates software-properties-common gnupg

## init dir
cd /usr/local/src

## download file
### caddy
if [ "$(get_ip_country)" == "CN" ]; then
	wget -t0 -c https://gh.kitin.cc/https://github.com/caddyserver/caddy/releases/download/v${caddy_ver}/caddy_${caddy_ver}_linux_amd64.tar.gz
else
	wget -t0 -c https://github.com/caddyserver/caddy/releases/download/v${caddy_ver}/caddy_${caddy_ver}_linux_amd64.tar.gz
fi

### boost
wget -t0 -c https https://boostorg.jfrog.io/artifactory/main/release/${boost_ver}/source/boost_${boost_ver2}.tar.gz

## jemalloc
if [ "$(get_ip_country)" == "CN" ]; then
	wget -t0 -c https://gh.kitin.cc/https://github.com/jemalloc/jemalloc/archive/${jemalloc_ver}.tar.gz
else
	wget -t0 -c https://github.com/jemalloc/jemalloc/archive/${jemalloc_ver}.tar.gz
fi

## mariadb
if [ "${dbinstallmethod}" == "1" ]; then
	file_type=bintar-linux-systemd-x86_64
	file_name=mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz
elif [ "${dbinstallmethod}" == "2" ]; then
	file_type=source
	file_name=mariadb-${mariadb_ver}.tar.gz
fi

if [ "$(get_ip_country)" == "CN" ]; then
	wget -t0 -c https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_ver}/${file_type}/${file_name}
else
	wget -t0 -c https://archive.mariadb.org/mariadb-${mariadb_ver}/${file_type}/${file_name}
fi

## php
if [ "$(get_ip_country)" == "CN" ]; then
	wget -t0 -c https://secure.php.net/distributions/php-${php_ver}.tar.gz
else
	wget -t0 -c https://www.php.net/distributions/php-${php_ver}.tar.gz
fi

## imagemagick
wget -t0 -c https://imagemagick.org/archive/ImageMagick.tar.gz

### pecl_imagick
wget -t0 -c https://pecl.php.net/get/imagick-${pecl_imagick_ver}.tgz

## redis
### redis_server
if [ "$(get_ip_country)" == "CN" ]; then
	wget -t0 -c https://gh.kitin.cc/https://github.com/redis/redis/archive/${redis_ver}.tar.gz
else
	wget -t0 -c https://github.com/redis/redis/archive/${redis_ver}.tar.gz
fi

### pecl_redis
wget -t0 -c https://pecl.php.net/get/redis-${pecl_redis_ver}.tgz

## memcached
### memcached_server
wget -t0 -c https://www.memcached.org/files/memcached-${memcached_ver}.tar.gz
### linmemcached
wget -t0 -c https://launchpad.net/libmemcached/1.0/${libmemcaached_ver}/+download/libmemcached-${libmemcaached_ver}.tar.gz
## pecl_memcached
wget -t0 -c https://pecl.php.net/get/memcached-${pecl_memcached_ver}.tgz

## libiconv
if [ "$(get_ip_country)" == "CN" ]; then
	wget -t0 -c https://mirrors.tuna.tsinghua.edu.cn/gnu/libiconv/libiconv-${libiconv_ver}.tar.gz
else
	wget -t0 -c https://ftp.gnu.org/gnu/libiconv/libiconv-${libiconv_ver}.tar.gz
fi

## phpmyadmin
wget -t0 -c https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_ver}/phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz

# install soft
## caddy
mkdir -p /etc/caddy
mkdir -p /var/log/caddy
groupadd caddy
useradd -g caddy -m -d /var/lib/caddy -s /usr/sbin/nologin caddy

cd /usr/local/src
tar zxf caddy_${caddy_ver}_linux_amd64.tar.gz
mv caddy /usr/bin/
chmod +x /usr/bin/caddy

cat > /usr/lib/systemd/system/caddy.service << EOF
[Unit]
Description=Caddy
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

systemctl enable caddy

mkdir -p /data/www/default
mkdir -p /var/lib/caddy/ssl

cat > /etc/caddy/Caddyfile << EOF
{
	admin off
	log {
		output file /var/log/caddy/access.log {
		roll_size 100mb
		roll_keep_for 15d
		}
	}
}

:80 {
	root * /data/www/default
	header {
		Strict-Transport-Security "max-age=31536000; preload"
		X-Content-Type-Options nosniff
		X-Frame-Options SAMEORIGIN
	}
	encode gzip
	# php_fastcgi unix//dev/shm/php-cgi.sock
	file_server browse
}
EOF

caddy fmt --overwrite /etc/caddy/Caddyfile

chown -R caddy:caddy /etc/caddy
chown -R caddy:caddy /var/lib/caddy
chown -R caddy:caddy /var/log/caddy
chown -R caddy:caddy /data/www

## jemalloc
cd /usr/local/src/
tar zxf ${jemalloc_ver}.tar.gz
cd jemalloc-${jemalloc_ver}
autoconf
./configure
make -j$(nproc)
make install

ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1
echo '/usr/local/lib' > /etc/ld.so.conf.d/jemalloc.conf
ldconfig

## mariadb
groupadd mysql
useradd -g mysql -M -s /usr/sbin/nologin mysql

mkdir -p ${mariadb_install_dir}
chown -R mysql:mysql ${mariadb_install_dir}

if [ "${dbinstallmethod}" == "1" ]; then
	cd /usr/local/src
	tar zxf mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz
	mv /usr/local/src/mariadb-${mariadb_ver}-linux-systemd-x86_64/* ${mariadb_install_dir}
	sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' ${mariadb_install_dir}/bin/mysqld_safe  
	sed -i "s@/usr/local/mysql@${mariadb_install_dir}@g" ${mariadb_install_dir}/bin/mysqld_safe
elif [ "${dbinstallmethod}" == "2" ]; then
	cd /usr/local/src/
	tar zxf boost_${boost_ver2}.tar.gz
	tar zxf mariadb-${mariadb_ver}.tar.gz
	cd mariadb-${mariadb_ver}
	mkdir build-sql && cd build-sql
	cmake .. -DCMAKE_INSTALL_PREFIX=${mariadb_install_dir} \
	-DMYSQL_DATADIR=${mariadb_data_dir} \
	-DDOWNLOAD_BOOST=1 \
	-DWITH_BOOST=/usr/local/src/boost_${boost_ver2} \
	-DSYSCONFDIR=/etc \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_PARTITION_STORAGE_ENGINE=1 \
	-DWITH_FEDERATED_STORAGE_ENGINE=1 \
	-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
	-DWITH_MYISAM_STORAGE_ENGINE=1 \
	-DWITH_EMBEDDED_SERVER=1 \
	-DENABLE_DTRACE=0 \
	-DENABLED_LOCAL_INFILE=1 \
	-DDEFAULT_CHARSET=utf8mb4 \
	-DDEFAULT_COLLATION=utf8mb4_general_ci \
	-DEXTRA_CHARSETS=all \
	-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'

	make -j$(nproc)
	make install
fi

cp ${mariadb_install_dir}/support-files/mysql.server /etc/init.d/mysql
sed -i "s@^basedir=.*@basedir=${mariadb_install_dir}@" /etc/init.d/mysql
sed -i "s@^datadir=.*@datadir=${mariadb_data_dir}@" /etc/init.d/mysql
chmod +x /etc/init.d/mysql

cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = ${mariadb_install_dir}
datadir = ${mariadb_data_dir}
pid-file = ${mariadb_data_dir}/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4

skip-name-resolve
#skip-networking
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 500M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7

log_error = ${mariadb_data_dir}/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = ${mariadb_data_dir}/mysql-slow.log

performance_schema = 0

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 500M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

sed -i "s@max_connections.*@max_connections = $((${Mem}/3))@" /etc/my.cnf

if [ ${Mem} -gt 1500 -a ${Mem} -le 2500 ]; then
	sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
	sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/my.cnf
	sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
	sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
	sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
	sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
	sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
elif [ ${Mem} -gt 2500 -a ${Mem} -le 3500 ]; then
	sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
	sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/my.cnf
	sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
	sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
	sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
	sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
	sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
elif [ ${Mem} -gt 3500 ]; then
	sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
	sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/my.cnf
	sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
	sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
	sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
	sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
	sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
fi

chown -R mysql:mysql ${mariadb_install_dir}
touch /tmp/mysql.sock
chown mysql:mysql /tmp/mysql.sock
mkdir -p ${mariadb_data_dir}
touch ${mariadb_data_dir}/{mysql.pid,mysql-error.log,mysql-slow.log}
chown -R mysql:mysql ${mariadb_data_dir}
chmod 664 /tmp/mysql.sock ${mariadb_data_dir}/*

echo "export PATH=${mariadb_install_dir}/bin:\$PATH" > /etc/profile.d/mysql.sh
source /etc/profile

${mariadb_install_dir}/scripts/mysql_install_db --user=mysql --basedir=${mariadb_install_dir} --datadir=${mariadb_data_dir}

chmod 600 /etc/my.cnf
systemctl daemon-reload
service mysql start

${mariadb_install_dir}/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${dbrootpwd}\" with grant option;"
${mariadb_install_dir}/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${dbrootpwd}\" with grant option;"
${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "delete from mysql.user where Password='' and User not like 'mariadb.%';"
${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "delete from mysql.db where User='';"
${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "delete from mysql.proxies_priv where Host!='localhost';"
${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;"
${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "reset master;"
echo "${mariadb_install_dir}/lib" > /etc/ld.so.conf.d/mariadb.conf

ldconfig
service mysql stop
systemctl enable mysql

## install php
### install libiconv
cd /usr/local/src
tar zxf libiconv-${libiconv_ver}.tar.gz
cd libiconv-${libiconv_ver}
./configure
make -j$(nproc)
make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/libc.conf
ldconfig

cd /usr/local/src
tar zxf php-${php_ver}.tar.gz
cd php-${php_ver}
mkdir build-php && cd build-php
../configure --prefix=${php_install_dir} \
--with-config-file-path=${php_install_dir}/etc \
--with-config-file-scan-dir=${php_install_dir}/etc/php.d \
--with-fpm-user=${run_user} \
--with-fpm-group=${run_group} \
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

mkdir -p ${php_install_dir}/etc/php.d
echo "export PATH=${php_install_dir}/bin:\$PATH" > /etc/profile.d/php.sh
source /etc/profile
cp /usr/local/src/php-${php_ver}/php.ini-production ${php_install_dir}/etc/php.ini

sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" ${php_install_dir}/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' ${php_install_dir}/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' ${php_install_dir}/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' ${php_install_dir}/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' ${php_install_dir}/etc/php.ini
sed -i "s@^;date.timezone.*@date.timezone = ${timezone}@" ${php_install_dir}/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 100M@' ${php_install_dir}/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' ${php_install_dir}/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 600@' ${php_install_dir}/etc/php.ini
sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' ${php_install_dir}/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' ${php_install_dir}/etc/php.ini
 
cat > ${php_install_dir}/etc/php.d/opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=${Memory_limit}
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

cat > /usr/lib/systemd/system/php-fpm.service << 'EOF'
[Unit]
Description=The PHP FastCGI Process Manager
Documentation=http://php.net/docs.php
After=network.target

[Service]
Type=simple
PIDFile=/usr/local/php/var/run/php-fpm.pid
ExecStart=/usr/local/php/sbin/php-fpm --nodaemonize --fpm-config usr/local/php/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
LimitNOFILE=1000000
LimitNPROC=1000000
LimitCORE=1000000

[Install]
WantedBy=multi-user.target
EOF

sed -i "s@/usr/local/php@${php_install_dir}@g" /usr/lib/systemd/system/php-fpm.service
systemctl daemon-reload
systemctl enable php-fpm

cat > ${php_install_dir}/etc/php-fpm.conf << EOF
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

[${run_user}]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = ${run_user}
listen.group = ${run_group}
listen.mode = 0666
user = ${run_user}
group = ${run_group}

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

if [ $Mem -le 3000 ]; then
	sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@" ${php_install_dir}/etc/php-fpm.conf
elif [ $Mem -gt 3000 -a $Mem -le 4500 ]; then
	sed -i "s@^pm.max_children.*@pm.max_children = 50@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.start_servers.*@pm.start_servers = 30@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
elif [ $Mem -gt 4500 -a $Mem -le 6500 ]; then
	sed -i "s@^pm.max_children.*@pm.max_children = 60@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" ${php_install_dir}/etc/php-fpm.conf
elif [ $Mem -gt 6500 -a $Mem -le 8500 ]; then
	sed -i "s@^pm.max_children.*@pm.max_children = 70@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@" ${php_install_dir}/etc/php-fpm.conf
elif [ $Mem -gt 8500 ]; then
	sed -i "s@^pm.max_children.*@pm.max_children = 80@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" ${php_install_dir}/etc/php-fpm.conf
fi

## install redis
### install redis_server
mkdir -p ${redis_install_dir}/{bin,etc,var}
cd /usr/local/src
tar zxf ${redis_ver}.tar.gz
cd redis-${redis_ver}
make -j$(nproc)
make PREFIX=${redis_install_dir} install

ln -s ${redis_install_dir}/bin/* /usr/local/bin/
cp redis.conf ${redis_install_dir}/etc/
sed -i 's@pidfile.*@pidfile /var/run/redis/redis.pid@' ${redis_install_dir}/etc/redis.conf
sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" ${redis_install_dir}/etc/redis.conf
sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" ${redis_install_dir}/etc/redis.conf

groupadd redis
useradd -g redis -M -s /usr/sbin/nologin redis
chown -R redis:redis ${redis_install_dir}/{var,etc}

cat > /usr/lib/systemd/system/redis-server.service << 'EOF'
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
Type=forking
PIDFile=/var/run/redis/redis.pid
User=redis
Group=redis

Environment=statedir=/var/run/redis
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p ${statedir}
ExecStartPre=/bin/chown -R redis:redis ${statedir}
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
ExecStop=/bin/kill -s TERM $MAINPID
Restart=always
LimitNOFILE=1000000
LimitNPROC=1000000
LimitCORE=1000000

[Install]
WantedBy=multi-user.target
EOF

sed -i "s@/usr/local/redis@${redis_install_dir}@g" /lib/systemd/system/redis-server.service
systemctl daemon-reload
systemctl enable redis-server
systemctl start redis-server

### install pecl_redis
cd /usr/local/src
tar zxf redis-${pecl_redis_ver}.tgz
cd redis-${pecl_redis_ver}
${php_install_dir}/bin/phpize
./configure --with-php-config=${php_install_dir}/bin/php-config
make -j$(nproc)
make install

echo 'extension=redis.so' > ${php_install_dir}/etc/php.d/redis.ini

## install memcached
### install memcached
groupadd memcached
useradd -g memcached -M -s /usr/sbin/nologin memcached
mkdir -p ${memcached_install_dir}
cd /usr/local/src
tar zxf memcached-${memcached_ver}.tar.gz
cd memcached-${memcached_ver}
./configure --prefix=${memcached_install_dir}
make -j$(nproc)
make install

ln -s ${memcached_install_dir}/bin/memcached /usr/bin/memcached

cat > /usr/lib/systemd/system/memcached.service << 'EOF'
[Unit]
Description=memcached daemon
After=network.target

[Service]
Environment=PORT=11211
Environment=USER=memcached
Environment=MAXCONN=1024
Environment=CACHESIZE=256
Environment="OPTIONS=-l 127.0.0.1"
ExecStart=/usr/bin/memcached -p ${PORT} -u ${USER} -m ${CACHESIZE} -c ${MAXCONN} $OPTIONS
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true
CapabilityBoundingSet=CAP_SETGID CAP_SETUID CAP_SYS_RESOURCE
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX


[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable memcached
systemctl start memcached

### install libmemcached
cd /usr/local/src
tar zxf libmemcached-${libmemcaached_ver}.tar.gz

cat > libmemcached-build.patch << 'EOF'
diff -up ./clients/memflush.cc.old ./clients/memflush.cc
--- ./clients/memflush.cc.old	2017-02-12 10:12:59.615209225 +0100
+++ ./clients/memflush.cc	2017-02-12 10:13:39.998382783 +0100
@@ -39,7 +39,7 @@ int main(int argc, char *argv[])
 {
   options_parse(argc, argv);
 
-  if (opt_servers == false)
+  if (!opt_servers)
   {
     char *temp;
 
@@ -48,7 +48,7 @@ int main(int argc, char *argv[])
       opt_servers= strdup(temp);
     }
 
-    if (opt_servers == false)
+    if (!opt_servers)
     {
       std::cerr << "No Servers provided" << std::endl;
       exit(EXIT_FAILURE);
EOF

patch -d libmemcached-${libmemcaached_ver} -p0 < libmemcached-build.patch

cd libmemcached-${libmemcaached_ver}
sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure
./configure --with-memcached=${memcached_install_dir}
make -j$(nproc)
make install

### install pecl_memcached
cd /usr/local/src
tar zxf memcached-${pecl_memcached_ver}.tgz
cd memcached-${pecl_memcached_ver}
${php_install_dir}/bin/phpize
./configure --with-php-config=${php_install_dir}/bin/php-config
make -j$(nproc)
make install


cat > ${php_install_dir}/etc/php.d/memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF

## install imagegick
### install imagemagick
cd /usr/local/src
tar zxf ImageMagick.tar.gz
cd ImageMagick-${imagick_ver}
./configure --prefix=${imagick_install_dir} \
--enable-shared \
--enable-static
make -j$(nproc)
make install

### install pecl_imagick
cd /usr/local/src
tar zxf imagick-${pecl_imagick_ver}.tgz
cd imagick-${pecl_imagick_ver}
${php_install_dir}/bin/phpize
./configure --with-php-config=${php_install_dir}/bin/php-config \
--with-imagick=${imagick_install_dir}
make -j$(nproc)
make install
echo 'extension=imagick.so' > ${php_install_dir}/etc/php.d/imagick.ini

## install phpmyadmin
cd /usr/local/src
tar zxf phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz
mkdir -p ${www_dir}/default
mv phpMyAdmin-${phpmyadmin_ver}-all-languages ${www_dir}/default/pma
cp ${www_dir}/default/pma/config.sample.inc.php ${www_dir}/default/pma/config.inc.php
mkdir ${www_dir}/default/pma/{upload,save}

sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" ${www_dir}/default/pma/config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" ${www_dir}/default/pma/config.inc.php
sed -i "s@host'\].*@host'\] = '127.0.0.1';@" ${www_dir}/default/pma/config.inc.php
sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 32)\';@" ${www_dir}/default/pma/config.inc.php

rm -rf /usr/local/src/*

## tool
cd /data/www/default
cat > pinfo.php << 'EOF'
<?php
phpinfo();
?>
EOF

wget -t0 -c https://github.com/kmvan/x-prober/raw/master/dist/prober.php -O xp.php
wget -t0 -c https://github.com/teddysun/lamp/raw/master/conf/ocp.php

chown -R caddy:caddy ${www_dir}
find ${www_dir} -type d -exec chmod 755 {} \;
find ${www_dir} -type f -exec chmod 644 {} \;
