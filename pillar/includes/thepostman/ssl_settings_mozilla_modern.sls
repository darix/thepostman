# generated 2025-12-11, Mozilla Guideline v5.7, Postfix 3.9.0, OpenSSL 3.4.0, modern config
# https://ssl-config.mozilla.org/#server=postfix&version=3.9.0&config=modern&openssl=3.4.0&guideline=5.7

{%- set minimum_tls_version = '">=TLSv1.3"' %}
{%- set security_level = "may" %}
postfix:
  config:
    main.cf:
      smtpd_tls_auth_only: yes
      smtpd_tls_security_level: {{ security_level }}
      smtpd_tls_mandatory_protocols: {{ minimum_tls_version }}
      smtpd_tls_protocols: {{ minimum_tls_version }}
      smtp_tls_security_level: {{ security_level }}
      smtp_tls_mandatory_protocols: {{ minimum_tls_version }}
      smtp_tls_protocols: {{ minimum_tls_version }}
      tls_preempt_cipherlist: no
      tls_eecdh_auto_curves: X25519 prime256v1 secp384r1
      tls_ffdhe_auto_groups: