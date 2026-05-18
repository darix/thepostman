# A mail setup formula for saltstack that delivers

Initially it started out with only handling postfix.
Then rspamd got added (including creating dkim keys).
And in the end it also got support for dovecot >= 2.4.

follow pillar.example

## Required salt master config:

```
file_roots:
  base:
    - {{ salt_base_dir }}/salt
    - {{ formulas_base_dir }}/thepostman/salt
pillar_roots:
  base:
    - {{ formulas_base_dir }}/thepostman/pillar/
```

## cfgmgmt-template integration

if you are using our [cfgmgmt-template](https://codeberg.org/salted-geeko/cfgmgmt-template) as a starting point the saltmaster you can simplify the setup with:

```
git submodule add https://codeberg.org/salted-geeko/thepostman formulas/thepostman
ln -s /srv/cfgmgmt/formulas/thepostman/config/enable_thepostman.conf /etc/salt/master.d/
systemctl restart saltmaster
```

## License

[AGPL-3.0-only](https://spdx.org/licenses/AGPL-3.0-only.html)

