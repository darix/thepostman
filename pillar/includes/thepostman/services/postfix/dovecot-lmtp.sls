{%- set lmtp_socket_path = 'lmtp:unix:private/dovecot-lmtp' %}
postfix:
  config:
    main.cf:
      mailbox_transport: {{ lmtp_socket_path }}
      virtual_transport: {{ lmtp_socket_path }}