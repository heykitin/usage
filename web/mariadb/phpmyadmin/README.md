### Install phpMyAdmin

Set variable:

```bash
phpmyadmin_ver="5.2.1"
```

Download source code

```bash
wget https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_ver}/phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz
```

Install phpmyadmin

```bash
cd /usr/local/src
tar zxf phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz
mkdir -p /data/wwwroot/default
mv phpMyAdmin-${phpmyadmin_ver}-all-languages /data/wwwroot/default/pma
```

Configure phpmyadmin

```bash
cp /data/wwwroot/default/pma/config.sample.inc.php /data/wwwroot/default/pma/config.inc.php
mkdir /data/wwwroot/default/pma/{upload,save}
sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" /data/wwwroot/default/pma/config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" /data/wwwroot/default/pma/config.inc.php
sed -i "s@host'\].*@host'\] = '127.0.0.1';@" /data/wwwroot/default/pma/config.inc.php
sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 32)\';@" /data/wwwroot/default/pma/config.inc.php
```