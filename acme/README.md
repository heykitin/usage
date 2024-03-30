## ACME
### Install acme.sh

- Install from [https://get.acme.sh](https://get.acme.sh)

```bash
curl https://get.acme.sh | sh -s email=my@example.com
```

or 

```bash
wget -O -  https://get.acme.sh | sh -s email=my@example.com
```

- Install in CN

```bash
git clone https://gitee.com/neilpang/acme.sh.git
cd acme.sh
./acme.sh --install -m my@example.com
```

### Usage

#### Normal Issue

You must point all the domains to you server,and run:

```bash
# Single domain
acme.sh --issue -d example.com -w /home/wwwroot/example.com

# Multiple domains in the same cert
acme.sh --issue -d example.com -d www.example.com -d m.example.com --webroot /home/wwwroot/example.com
```

#### Install the cert to Apache/Nginx

- Apache mode:

```bash
acme.sh --install-cert -d example.com \
--cert-file      /path/to/certfile/in/apache/cert.pem  \
--key-file       /path/to/keyfile/in/apache/key.pem  \
--fullchain-file /path/to/fullchain/certfile/apache/fullchain.pem \
--reloadcmd     "service apache2 force-reload"
```

Or set string "apache" it will force use of apache plugin automatically:

```bash
acme.sh --issue -d example.com -d www.example.com --apache
```

- Nginx mode:

```bash
acme.sh --install-cert -d example.com \
--key-file       /path/to/keyfile/in/nginx/key.key  \
--fullchain-file /path/to/fullchain/nginx/cert.cer \
--reloadcmd     "service nginx force-reload"
```

Or set string "nginx" automatically to verify the domain and then restore the nginx config:

```bash
acme.sh --issue -d example.com -d www.example.com --nginx
```

#### Issue ECC Certificates

```bash
acme.sh --issue -w /home/wwwroot/example.com -d example.com --keylength ec-256
```

#### Set Default CA

Default CA is letsencrypt, run command follow change to zerossl:

```bash
acme.sh --set-default-ca --server zerossl
```

#### Issue Certificates With DNS Api

- CloudFlare

```bash
export CF_Key="<key>"
export CF_Email="<email>"

./acme.sh --issue --dns dns_cf -d example.com
```

- DNSPod

```bash
export DP_Id="<id>"
export DP_Key="<key>"

./acme.sh --issue --dns dns_dp -d example.com
```
