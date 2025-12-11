dovecot:
  config:
    dovecot:
      'service imap-login':
        'inet_listener imap':
          haproxy: yes
        'inet_listener imaps':
          haproxy: yes
      'service managesieve-login':
        'inet_listener sieve':
          haproxy: yes
      'service pop3-login':
        'inet_listener pop3':
          haproxy: yes
        'inet_listener pop3s':
          haproxy: yes
      'service submission-login':
        'inet_listener submission':
          haproxy: yes
        'inet_listener submissions':
          haproxy: yes