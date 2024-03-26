## Install MariaDB

### Set Variable

```bash
boost_ver="1.84.0"
boost_ver2="$(echo ${boost_ver} | awk -F. '{print $1"_"$2"_"$3}')"
jemalloc_ver="5.3.0"
mariadb_ver="10.11.7"
```

### Install Jemalloc For MariaDB

```bash
cd /usr/local/src
wget https://github.com/jemalloc/jemalloc/archive/${jemalloc_ver}.tar.gz
tar zxf ${jemalloc_ver}.tar.gz
cd jemalloc-${jemalloc_ver}
autoconf
./configure
make -j$(nproc)
make install

ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1
echo '/usr/local/lib' > /etc/ld.so.conf.d/jemalloc.conf
ldconfig
```

### Create User, Group, Dir And Grant Permissions

```bash
groupadd mysql
useradd -g mysql -M -s /usr/sbin/nologin mysql

mkdir -p /usr/local/mariadb
chown -R mysql:mysql /usr/local/mariadb
```

### Install MariaDB Form Binary File

- Download binary file

```bash
cd /usr/local/src
wget https://archive.mariadb.org/mariadb-${mariadb_ver}/bintar-linux-systemd-x86_64/mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz

# for CN, use tsinghua mirror
wget https://mirrors.tuna.tsinghua.edu.cn/mariadb-${mariadb_ver}/bintar-linux-systemd-x86_64/mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz
```

- Install

```bash
tar zxf mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz
mv /usr/local/src/mariadb-${mariadb_ver}-linux-systemd-x86_64 /usr/local/mariadb
sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/local/mariadb/bin/mysqld_safe  
sed -i "s@/usr/local/mysql@/usr/local/mariadb@g" /usr/local/mariadb/bin/mysqld_safe
```

### Install MariaDB Form Source Code

- Download source code

```bash
cd /usr/local/src

# boost
wget https https://boostorg.jfrog.io/artifactory/main/release/${boost_ver}/source/boost_${boost_ver2}.tar.gz

# mariadb
wget https://archive.mariadb.org/mariadb-${mariadb_ver}/bintar-linux-systemd-x86_64/mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz

# for CN, use tsinghua mirror
wget https://mirrors.tuna.tsinghua.edu.cn/mariadb-${mariadb_ver}/bintar-linux-systemd-x86_64/mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz
```

```bash
tar zxf boost_${boost_ver2}.tar.gz
tar zxf mariadb-${mariadb_ver}.tar.gz
cd mariadb-${mariadb_ver}
mkdir build-sql && cd build-sql
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb \
-DMYSQL_DATADIR=/data/mariadb \
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

make -j$(nproc) && make install
```

### Configure MariaDB

Change basedir for mysqld

```bash
cp /usr/local/mariadb/support-files/mysql.server /etc/init.d/mysql
sed -i "s@^basedir=.*@basedir=/usr/local/mariadb@" /etc/init.d/mysql
sed -i "s@^datadir=.*@datadir=/data/mariadb@" /etc/init.d/mysql
chmod +x /etc/init.d/mysql
```

Create `my.cnf` see [here](./my.cnf) and configure like follow:

```bash
# memory（M）/3
max_connections = 

# memory 1500M - 2500M：
thread_cache_size = 16
query_cache_size = 16M
myisam_sort_buffer_size = 16M
key_buffer_size = 16M
innodb_buffer_pool_size = 128M
tmp_table_size = 32M
table_open_cache = 256

# memory 2500M - 3500M：
thread_cache_size = 32
query_cache_size = 32M
myisam_sort_buffer_size = 32M
key_buffer_size = 64M
innodb_buffer_pool_size = 512M
tmp_table_size = 64M
table_open_cache = 512

# memory 3500M：
thread_cache_size = 64
query_cache_size = 64M
myisam_sort_buffer_size = 64M
key_buffer_size = 256M
innodb_buffer_pool_size = 1024M
tmp_table_size = 128M
table_open_cache = 1024
```

Create file, dir and grant permissions

```bash
touch /tmp/mysql.sock
chown mysql:mysql /tmp/mysql.sock
mkdir -p /data/mariadb
touch /data/mariadb/{mysql.pid,mysql-error.log,mysql-slow.log}
chown -R mysql:mysql /data/mariadb
chmod 664 /tmp/mysql.sock /data/mariadb/*
chown -R mysql:mysql /usr/local/mariadb
```

Add environment variables

```bash
echo 'export PATH=/usr/local/mariadb/bin:$PATH' > /etc/profile.d/mysql.sh
source /etc/profile
```

Ininialize data, start mariadb

```bash
/usr/local/mariadb/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mariadb/ --datadir=/data/mariadb

chmod 600 /etc/my.cnf
systemctl daemon-reload
service mysql start
```

Security settings

```bash
dbrootpwd="password"
/usr/local/mariadb/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${dbrootpwd}\" with grant option;"
/usr/local/mariadb/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${dbrootpwd}\" with grant option;"
/usr/local/mariadb/bin/mysql -uroot -p${dbrootpwd} -e "delete from mysql.user where Password='' and User not like 'mariadb.%';"
/usr/local/mariadb/bin/mysql -uroot -p${dbrootpwd} -e "delete from mysql.db where User='';"
/usr/local/mariadb/bin/mysql -uroot -p${dbrootpwd} -e "delete from mysql.proxies_priv where Host!='localhost';"
/usr/local/mariadb/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;"
/usr/local/mariadb/bin/mysql -uroot -p${dbrootpwd} -e "reset master;"
```

Link libraries

```bash
echo "/usr/local/mariadb/lib" > /etc/ld.so.conf.d/mariadb.conf
ldconfig
```