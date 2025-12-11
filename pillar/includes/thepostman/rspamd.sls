{%- set rspamd_socket_path = 'unix:/run/rspamd/worker-proxy.socket' %}
postfix:
  config:
    main.cf:
      smtpd_milters:     {{ rspamd_socket_path }}
      non_smtpd_milters: {{ rspamd_socket_path }}