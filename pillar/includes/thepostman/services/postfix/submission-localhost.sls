postfix:
  config:
    master.cf:
      localhost-only:submission-inet:
        name: localhost:submission
        type: inet
        private: "n"
        unpriv: "-"
        chroot: "n"
        wakeup: "-"
        maxproc: "-"
        command: smtpd
      localhost-only:submissions-inet:
        name: localhost:submissions
        type: inet
        private: "n"
        unpriv: "-"
        chroot: "n"
        wakeup: "-"
        maxproc: "-"
        command: smtpd