## Autoindex

- Usage

1. Makesure your nginx install with [ngx_http_autoindex_module](https://nginx.org/en/docs/http/ngx_http_autoindex_module.html) and [ngx_http_auth_basic_module](https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html), usually, they were installed by default. 

2. Download `autoindex.html` and `mainifest.json` to your sitedir like: `/path/to/siteroot/.theme`

3. Configure localtion follows:

```nginx
location / {
  autoindex on;
  autoindex_localtime on;
  autoindex_exact_size off;
  charset utf-8;
  add_after_body /.theme/autoindex.html;
}
```

4. Add user name and password for dir:

install `htpasswd` and run follows:

```bash
htpasswd -c /path/to/.htpasswd user

New password:
Re-type new password:
Adding password for user user
```

Configure localtion follows:

```nginx
location /locked/ {
  auth_basic "Login to continue";
  auth_basic_user_file /path/to/.htpasswd;
  autoindex on;
  autoindex_localtime on;
  autoindex_exact_size off;
  charset utf-8;
  add_after_body /.theme/autoindex.html;
}
```