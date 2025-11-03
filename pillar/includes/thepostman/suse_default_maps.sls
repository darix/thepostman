postfix:
  config:
    main.cf:
      canonical_maps: lmdb:/etc/postfix/canonical
      relocated_maps: lmdb:/etc/postfix/relocated
      sender_canonical_maps: lmdb:/etc/postfix/sender_canonical
      transport_maps: lmdb:/etc/postfix/transport
      smtpd_sender_restrictions: lmdb:/etc/postfix/access
      relay_domains: $mydestination, lmdb:/etc/postfix/relay
  maps:
    canonical: []
    relocated_maps: []
    relay: []
    relocated: []
    sender_canonical: []
    transport: []
    access: []
    relay_domains: []
    generic: []
    header_checks: []
    helo_access: []
    relay_ccerts: []
    virtual: []
    relay_recipients: []