## Install PHP Addons

### Preparation

Set variable:

```bash
imagick_ver="7.1.1-29"
pecl_imagick_ver="3.7.0"
redis_ver="7.2.4"
pecl_redis_ver="6.0.2"
memcached_ver="1.6.24"
libmemcaached_ver="1.0.18"
pecl_memcached_ver="3.2.0"
```

Download source code:

```bash
cd /usr/local/src
# imagemagick
wget https://imagemagick.org/archive/ImageMagick.tar.gz

# pecl_imagick
wget https://pecl.php.net/get/imagick-${pecl_imagick_ver}.tgz

# redis
# redis_server
wget https://github.com/redis/redis/archive/${redis_ver}.tar.gz

# pecl_redis
wget https://pecl.php.net/get/redis-${pecl_redis_ver}.tgz

# memcached
# memcached_server
wget https://www.memcached.org/files/memcached-${memcached_ver}.tar.gz

# linmemcached
wget https://launchpad.net/libmemcached/1.0/${libmemcaached_ver}/+download/libmemcached-${libmemcaached_ver}.tar.gz

# pecl_memcached
wget https://pecl.php.net/get/memcached-${pecl_memcached_ver}.tgz
```

---

### Redis

```bash
mkdir -p /usr/local/redis/{etc,var}
cd /usr/local/src
tar zxf ${redis_ver}.tar.gz
cd redis-${redis_ver}
make -j$(nproc)
make PREFIX=/usr/local/redis install
```

MV bin file and configure:

```bash
ln -s /usr/local/redis/bin/* /usr/local/bin/
cp /usr/local/src/redis-${redis_ver}/redis.conf /usr/local/redis/etc/
vim /usr/local/redis/etc/redis.conf

# configure like:
pidfile /var/run/redis/redis.pid
logfile /usr/local/redis/var/redis.log
dir /usr/local/redis/var
daemonize yes
bind 127.0.0.1 ::1

# maxmemory：memory (Mb) /8*1000000
maxmemory 512000000
```

Add group, user and grant permissions:

```bash
groupadd redis
useradd -g redis -M -s /usr/sbin/nologin redis
chown -R redis:redis /usr/local/redis/{var,etc}
```

Create systemd file at `/usr/lib/systemd/system/redis-server.service` see [here](./redis-server.service)

Reload systemd file, start server and set auto start:

```bash
systemctl daemon-reload
systemctl enable redis-server
systemctl start redis-server
```

Install pecl-redis and add pecl-redis extend for php:

```bash
cd /usr/local/src
tar zxf redis-${pecl_redis_ver}.tgz
cd redis-${pecl_redis_ver}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make -j$(nproc)
make install

echo 'extension=redis.so' > /usr/local/php/etc/php.d/redis.ini
```

---

### Memcached

Add user, group:

```bash
groupadd memcached
useradd -g memcached -M -s /usr/sbin/nologin memcached
```

Install memcached:

```bash
cd /usr/local/src
tar zxf memcached-${memcached_ver}.tar.gz
cd memcached-${memcached_ver}
./configure --prefix=/usr/local/memcached
make -j$(nproc)
make install
ln -s /usr/local/memcached/bin/memcached /usr/bin/memcached
```

Create systemd file at `/usr/lib/systemd/system/memcached.service` see [here](./memcached.service)

Reload systemd file, start server and set auto start:

```bash
systemctl daemon-reload
systemctl enable memcached
systemctl start memcached
```

Before install libmemcachd, patching it first, path file see [here](./libmemcached-build.patch)

```bash
cd /usr/local/src
tar zxf libmemcached-${libmemcaached_ver}.tar.gz
patch -d libmemcached-${libmemcaached_ver} -p0 < libmemcached-build.patch
```

Install libmemcachd:

```bash
cd libmemcached-${libmemcaached_ver}
sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure
./configure --with-memcached=/usr/local/memcached
make -j$(nproc)
make install
```

Install pecl-memcached and add pecl-memcached extend for php:

```bash
cd /usr/local/src
tar zxf memcached-${pecl_memcached_ver}.tgz
cd memcached-${pecl_memcached_ver}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make -j$(nproc)
make install

cat > /usr/local/php/etc/php.d/memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF
```

---

### Imagick

Install imagemagick:

```bash
cd /usr/local/src
tar zxf ImageMagick.tar.gz
cd ImageMagick-${imagick_ver}
./configure --prefix=/usr/local/imagemagick \
--enable-shared \
--enable-static
make -j$(nproc)
make install
```

Install pecl-imagick and add pecl-imagick extend for php:

```bash
cd /usr/local/src
tar zxf imagick-${pecl_imagick_ver}.tgz
cd imagick-${pecl_imagick_ver}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config \
--with-imagick=/usr/local/imagemagick
make -j$(nproc)
make install
echo 'extension=imagick.so' > /usr/local/php/etc/php.d/imagick.ini
```