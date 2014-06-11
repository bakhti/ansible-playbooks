kibana ansible role
=====================

Install [kibana](http://www.elasticsearch.org/overview/kibana/) and set it up.

Requirements
------------

### Roles

- common
- elasticsearch
- nginx

### Variables

```yaml
kibana_version: v3.0.1
http_user: kibana
http_password: kibanapass
allowed_addresses:
  - 127.0.0.1
  - 33.33.33.1
app_path: /var/www
app_user: nginx
```
