{%- set lmtp_socket_path = 'lmtp:unix:private/dovecot-lmtp' %}
postfix:
  config:
    main.cf:
      smtpd_sasl_type: dovecot
      smtpd_sasl_path: private/auth
      mailbox_transport: {{ lmtp_socket_path }}
      virtual_transport: {{ lmtp_socket_path }}