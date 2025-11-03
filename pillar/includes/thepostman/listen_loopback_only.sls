include:
 - .smtp_inet

postfix:
  config:
    main.cf:
      inet_interfaces: loopback-only