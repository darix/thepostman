dovecot:
  config:
    dovecot:
      'service lmtp':
        'unix_listener /var/spool/postfix/private/dovecot-lmtp':
          mode:  '0666'
      'service auth':
        'unix_listener /var/spool/postfix/private/auth':
          mode:  '0660'
          user:  postfix
          group: postfix