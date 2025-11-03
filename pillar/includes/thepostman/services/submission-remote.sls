postfix:
  config:
    master.cf:
      submission-inet:
        name: submission
        type: inet
        private: "n"
        unpriv: "-"
        chroot: "n"
        wakeup: "-"
        maxproc: "-"
        command: smtpd
        args: "-o syslog_name=postfix/submission -o smtpd_forbid_unauth_pipelining=no -o
          smtpd_tls_security_level=encrypt -o smtpd_sasl_auth_enable=yes -o smtpd_tls_auth_only=yes
          -o local_header_rewrite_clients=static:all -o smtpd_hide_client_session=yes -o
          smtpd_reject_unlisted_recipient=no -o smtpd_client_restrictions=$mua_client_restrictions
          -o smtpd_helo_restrictions=$mua_helo_restrictions -o smtpd_sender_restrictions=$mua_sender_restrictions
          -o smtpd_recipient_restrictions= -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
          -o milter_macro_daemon_name=ORIGINATING"
      submissions-inet:
        name: submissions
        type: inet
        private: "n"
        unpriv: "-"
        chroot: "n"
        wakeup: "-"
        maxproc: "-"
        command: smtpd
        args: "-o syslog_name=postfix/submission -o smtpd_forbid_unauth_pipelining=no -o
          smtpd_tls_security_level=encrypt -o smtpd_sasl_auth_enable=yes -o smtpd_tls_auth_only=yes
          -o local_header_rewrite_clients=static:all -o smtpd_hide_client_session=yes -o
          smtpd_reject_unlisted_recipient=no -o smtpd_client_restrictions=$mua_client_restrictions
          -o smtpd_helo_restrictions=$mua_helo_restrictions -o smtpd_sender_restrictions=$mua_sender_restrictions
          -o smtpd_recipient_restrictions= -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
          -o milter_macro_daemon_name=ORIGINATING"