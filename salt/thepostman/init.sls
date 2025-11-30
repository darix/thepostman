#!py
#
# thepostman
#
# Copyright (C) 2025   darix
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
from salt.exceptions import SaltConfigurationError, SaltRenderError

import logging
import os
import re
log = logging.getLogger("thepostman")

# keep in sync with tols/import-etc-postfix
config_defaults = {
    'master.cf': {
      "smtp-inet":{"name":"smtp","type":"inet","private":"n","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"smtpd"},
      "dnsblog-unix":{"name":"dnsblog","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"0","command":"dnsblog"},
      "tlsproxy-unix":{"name":"tlsproxy","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"0","command":"tlsproxy"},
      "pickup-unix":{"name":"pickup","type":"unix","private":"n","unpriv":"-","chroot":"n","wakeup":"60","maxproc":"1","command":"pickup"},
      "cleanup-unix":{"name":"cleanup","type":"unix","private":"n","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"0","command":"cleanup"},
      "qmgr-unix":{"name":"qmgr","type":"unix","private":"n","unpriv":"-","chroot":"n","wakeup":"300","maxproc":"1","command":"qmgr"},
      "tlsmgr-unix":{"name":"tlsmgr","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"1000?","maxproc":"1","command":"tlsmgr"},
      "rewrite-unix":{"name":"rewrite","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"trivial-rewrite"},
      "bounce-unix":{"name":"bounce","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"0","command":"bounce"},
      "defer-unix":{"name":"defer","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"0","command":"bounce"},
      "trace-unix":{"name":"trace","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"0","command":"bounce"},
      "verify-unix":{"name":"verify","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"1","command":"verify"},
      "flush-unix":{"name":"flush","type":"unix","private":"n","unpriv":"-","chroot":"n","wakeup":"1000?","maxproc":"0","command":"flush"},
      "proxymap-unix":{"name":"proxymap","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"proxymap"},
      "proxywrite-unix":{"name":"proxywrite","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"1","command":"proxymap"},
      "smtp-unix":{"name":"smtp","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"smtp"},
      "relay-unix":{"name":"relay","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"smtp","args":"-o syslog_name=${multi_instance_name?{$multi_instance_name}:{postfix}}/$service_name"},
      "showq-unix":{"name":"showq","type":"unix","private":"n","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"showq"},
      "error-unix":{"name":"error","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"error"},
      "retry-unix":{"name":"retry","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"error"},
      "discard-unix":{"name":"discard","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"discard"},
      "local-unix":{"name":"local","type":"unix","private":"-","unpriv":"n","chroot":"n","wakeup":"-","maxproc":"-","command":"local"},
      "virtual-unix":{"name":"virtual","type":"unix","private":"-","unpriv":"n","chroot":"n","wakeup":"-","maxproc":"-","command":"virtual"},
      "lmtp-unix":{"name":"lmtp","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"-","command":"lmtp"},
      "anvil-unix":{"name":"anvil","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"1","command":"anvil"},
      "scache-unix":{"name":"scache","type":"unix","private":"-","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"1","command":"scache"},
      "postlog-unix-dgram":{"name":"postlog","type":"unix-dgram","private":"n","unpriv":"-","chroot":"n","wakeup":"-","maxproc":"1","command":"postlogd"},
    },
    'main.cf': {
        'compatibility_level': '3.10',
        'smtpd_banner': '$myhostname ESMTP',
        'setgid_group': 'maildrop',
        'html_directory': '/usr/share/doc/packages/postfix-doc/html',
        'sample_directory': '/usr/share/doc/packages/postfix-doc/samples',
        'biff': 'no',
        'delay_warning_time': '1h',
        'smtp_dns_support_level': 'enabled',
        'disable_vrfy_command': 'yes',
        'masquerade_exceptions': 'root',
        'mynetworks_style': 'host',
        'alias_maps': '',
        'message_strip_characters': '\\0',
        'mailbox_size_limit': '0',
        'message_size_limit': '0',
        'smtpd_recipient_restrictions': 'permit_mynetworks, reject_unauth_destination',
        'smtp_sasl_security_options': '',
        'smtp_tls_key_file': '',
        'smtpd_tls_key_file': '',
        'smtpd_tls_exclude_ciphers': 'RC4',
        'relay_domains': '$mydestination, lmdb:/etc/postfix/relay'
    },
    'aliases': {
      'MAILER-DAEMON':  'postmaster',
      'postmaster':     'root',
      'bin':            'root',
      'daemon':         'root',
      'named':          'root',
      'nobody':         'root',
      'uucp':           'root',
      'www':            'root',
      'ftp-bugs':       'root',
      'postfix':        'root',
      'manager':        'root',
      'dumper':         'root',
      'operator':       'root',
      'abuse':          'postmaster',
      'decode':         'root',
    }
}


config_files = [
  "main.cf",
  "master.cf",
]

dovecot_config_defaults = {
  'dovecot': {
    'dovecot_config_version':  '2.4.0',
    'dovecot_storage_version': '2.4.0',
    'protocols': {},
    'base_dir': '/run/dovecot',
    'verbose_proctitle': True,
    'userdb passwd': {},
    'service lmtp': {
      'unix_listener lmtp': {
        'mode': '0666',
      },
      'unix_listener /var/spool/postfix/private/dovecot-lmtp': {
        'mode': '0666',
      },
    },
    'service imap-login': {
        'inet_listener imap': {},
        'inet_listener imaps': {},
    },
    'service pop3-login': {
      'inet_listener pop3': {},
      'inet_listener pop3s': {},
    },
    'service submission-login': {
      'inet_listener submission': {},
      'inet_listener submissions': {},
    },
    'service imap': {},
    'service pop3': {},
    'service submission': {},
    'service auth': {
      'unix_listener auth-userdb': {},
    },
    'service auth-worker': {},
    'service dict': {
      'unix_listener dict': {}
    },
    'service managesieve-login': {
      'inet_listener sieve': {
        'port': 4190
      },
      'inet_listener sieve_deprecated': {
        'port': 2000
      },
    },
    'service managesieve': {},
  }
}


def expand_main_cf_values(config_data):
  new_config = {}
  for key, value in config_data.items():
    if isinstance(value, list):
      new_value="\n\t".join([x.lstrip() for x in value])
    elif isinstance(value, str):
      new_value = value
    else:
      raise SaltRenderError(f"value for {key} is neither a string or list {type(value)}")
    new_config[key] = new_value
  return new_config

def rspamd_format_pair(lines, key, value, indent_count=0):
    indent_str = " " * indent_count
    if isinstance(value, bool):
      lines.append(f"{indent_str}{key} = \"{str(value).lower()}\";")
    elif isinstance(value, str) or isinstance(value, int):
      lines.append(f"{indent_str}{key} = \"{value}\";")
    elif isinstance(value, list):
      value_indent_str = " " * (indent_count+2)
      lines.append(f"{indent_str}{key} [")
      for v in value:
        if isinstance(v, dict):
          lines.append(f"{value_indent_str}{{")
          for subkey, subval in v.items():
            rspamd_format_pair(lines, subkey, subval, indent_count+4)
          lines.append(f"{value_indent_str}}},")
        elif isinstance(v, bool):
          lines.append(f"{value_indent_str}{str(v).lower()},")
        elif isinstance(v, str) or isinstance(v, int):
          lines.append(f"{value_indent_str}\"{v}\",")
        else:
          lines.append(f"{value_indent_str}# TODO: {type(v)} {v}")
      lines.append(f"{indent_str}];")
    elif isinstance(value, dict):
      lines.append(f"{indent_str}{key} {{")
      for subkey, subval in value.items():
        rspamd_format_pair(lines, subkey, subval, indent_count+2)
      lines.append(f"{indent_str}}}")
    else:
      lines.append(f"# TODO: {key}: {type(value)} {value}")

def rspamd_format_config(config_data, indent_count=0):
  lines = []
  for key, value in config_data.items():
    rspamd_format_pair(lines, key, value)
  return lines

def rspamd_guess_keytype_from_path(path):
  key_type = __salt__["pillar.get"]("rspamd:dkim_signing:default_type", "rsa")
  key_bits = __salt__["pillar.get"](f"rspamd:dkim_signing:types_config:{key_type.lower()}:key_length", None)

  filename = os.path.basename(path)
  key_matcher = re.compile(r'^(?P<prefix>.*?)([\._-](?P<key_type>rsa|ed25519|ed25519-seed))?([\._-](?P<key_bits>\d+))?\.key$', re.IGNORECASE)
  m=key_matcher.match(filename)
  if m:
    log.error(m)
    if m.group('key_type'):
      key_type = m.group('key_type')
    if m.group('key_bits'):
      key_bits = m.group('key_bits')

  return key_type, key_bits

def rspamd_generate_key(config, domain, selector, path, require_in=["rspamd_service"]):

  #  -h, --help                 Show this help message and exit.
  #        -d <domain>,         Create a key for a specific domain (default: example.com)
  #  --domain <domain>
  #          -s <selector>,     Create a key for a specific DKIM selector (default: mail)
  #  --selector <selector>
  #         -k <privkey>,       Save private key to file instead of printing it to stdout
  #  --privkey <privkey>
  #      -b <bits>,             Generate an RSA key with the specified number of bits (512 to 4096)
  #  --bits <bits>
  #      -t <type>,             Key type: RSA, ED25519 or ED25119-seed (default: rsa)
  #  --type <type>
  #        -o <output>,         Output public key in the following format: dns, dnskey or plain (default: dns)
  #  --output <output>
  #  --priv-output <priv_output>
  #                             Output private key in the following format: PEM or DER (for RSA) (default: pem)
  #  -f, --force                Force overwrite of existing files

  key_type, key_bits = rspamd_guess_keytype_from_path(path)

  section_keygen = f"rspamd_keygen_{domain}_{selector}_{key_type}"

  key_directory = os.path.dirname(path)
  if not(os.path.exists(key_directory)):
    config[f"rspamd_key_dir_{domain}_{selector}_{key_type}"] = {
      "file.directory": [
        {'name': key_directory},
        {'user': 'root'},
        {'group': '_rspamd'},
        {'mode': '0750'},
        {'require_in': [section_keygen]}
      ]
    }

  cmdline = [
    "/usr/bin/rspamadm",
    "dkim_keygen",
    f"--domain '{domain}'",
    f"--selector '{selector}'",
    f"--type '{key_type}'",
    f"--privkey '{path}'"
  ]
  if key_bits is not None:
    cmdline.append(f"--bits '{key_bits}'")

  config[section_keygen] = {
    "cmd.run" : [
      {"name": " ".join(cmdline)},
      {"creates": path},
      {"cwd", key_directory},
      {"umask", "017"},
      {"require_in": require_in}
    ],
    "file.managed": [
      {'name':       path},
      {'user':       'root'},
      {'group':      '_rspamd'},
      {'mode':       '0640'},
      {'require_in': require_in},
    ]
  }

def dovecot_format_pair(dovecot_config_content, key, value, indent_level=0):
  value_indent_string = (" " * indent_level)
  if isinstance(value, bool):
    if value:
      dovecot_config_content.append(f"{value_indent_string}{key} = yes")
    else:
      dovecot_config_content.append(f"{value_indent_string}{key} = no")

  elif isinstance(value, str) or isinstance(value, int):
    dovecot_config_content.append(f"{value_indent_string}{key} = {value}\n")

  elif isinstance(value, list):
    dovecot_config_content.extend([f"{value_indent_string}{key} {x}" for x in value])

  elif isinstance(value, dict):

    indent_level += 2
    dovecot_config_content.append(f"{value_indent_string}{key} " + "{")

    for subkey, subval in value.items():
      dovecot_format_pair(dovecot_config_content, subkey, subval, indent_level)

    dovecot_config_content.append(value_indent_string + "}")
  else:
    dovecot_config_content.append(f"# TODO: {key}: {type(value)} {value}")


def dovecot_purge_configs(config, dovecot_config_dir, dovecot_config_files=[], require=[], require_in=[], do_purge=False):
  if __salt__["pillar.get"]("dovecot:purge_untracked_files", do_purge) and os.path.exists(dovecot_config_dir):
    for filename in os.listdir(dovecot_config_dir):
      full_path = os.path.join(dovecot_config_dir, filename)
      if full_path not in dovecot_config_files:
        config_section = f"dovecot_purge_unmanaged_{filename}"
        config[config_section] = {
            'file.absent': [
              {'name': full_path },
              {'require_in': require_in},
              {'require': require},
            ]
          }

def postfix_purge_configs(config, postfix_config_dir, postfix_managed_files=[], require=[], require_in=[], do_purge=False):
  if __salt__["pillar.get"]("postfix:purge_untracked_files", False) and os.path.exists(postfix_config_dir):
    all_files = [f for f in os.listdir(postfix_config_dir) if not(f.endswith(".lmdb"))]

    default_files_from_package = [
      "bounce.cf.default",
      "main.cf.default",
      "openssl_postfix.conf.in"
    ]

    for filename in all_files:
      full_path = os.path.join(postfix_config_dir, filename)
      lmdb_full_path = f"{full_path}.lmdb"

      if not(filename in default_files_from_package) and not(full_path in postfix_managed_files) and os.path.isfile(full_path):
        config_section = f"postfix_purge_unmanaged_{filename}"

        config[config_section] = {
          "file.absent": [
            {"name": full_path },
            {'require_in': require_in},
            {'require': require},
          ]
        }
        if os.path.isfile(lmdb_full_path):
          config_section = f"postfix_purge_unmanaged_{filename}_lmdb"

          config[config_section] = {
            "file.absent": [
              {"name": lmdb_full_path },
              {'require_in': require_in},
              {'require': require},
            ]
          }

def run():
  config = {}
  postfix_packages = ["swaks"]

  postfix_config_dir = "/etc/postfix"
  postfix_managed_files = []

  if "postfix" in __pillar__ and __pillar__["postfix"].get("enabled", True):
    postfix_pillar = __pillar__["postfix"]


    if postfix_pillar.get("needs_bdb", False):
        postfix_packages.append("postfix-bdb-lmdb")
    else:
        postfix_packages.append("postfix")

    for backend in postfix_pillar.get("map_backends", []):
      if backend in ["ldap", "mysql", "postgresql"]:
        postfix_packages.append(f"postfix-{backend}")

    postfix_config_deps = ["postfix_packages"]
    postfix_service_deps = ["postfix_packages"]


    config["postfix_packages"] = {
      "pkg.installed": [
        { "pkgs": postfix_packages },
      ]
    }

    file_permissions = "0644"

    for config_file in config_files:

      file_permissions = "0644"

      config_section = f"postfix_{config_file}"
      postfix_service_deps.append(config_section)

      config_file_name = f"{postfix_config_dir}/{config_file}"
      postfix_managed_files.append(config_file_name)

      pillar_key = f"postfix:config:{config_file}"
      section_defaults = config_defaults.get(config_file, {})

      config_context = __salt__["pillar.get"](pillar_key, default=section_defaults, merge=True)

      if "main.cf" == config_file:
        config_context = expand_main_cf_values(config_context)

      config[config_section] = {
        "file.managed": [
            {"user":     "root"},
            {"group":    "root"},
            {"mode":     file_permissions},
            {"template": "jinja"},
            {"require":  postfix_config_deps},
            {"context": {"config": config_context }},
            {"source":   f"salt://thepostman/files/etc/postfix/{config_file}.j2"},
            {"name":     config_file_name},
        ]
      }

    config_file = "aliases"
    config_section = f"postfix_{config_file}"
    config_file_name = f"{postfix_config_dir}/{config_file}"
    run_section = "postfix_postalias"

    postfix_managed_files.append(config_file_name)
    postfix_service_deps.append(run_section)

    pillar_key = f"postfix:config:{config_file}"
    section_defaults = config_defaults.get(config_file, {})

    config_context = __salt__["pillar.get"](pillar_key, default=section_defaults, merge=True)

    config[config_section] = {
      "file.managed": [
          {"user":     "root"},
          {"group":    "root"},
          {"mode":     file_permissions},
          {"template": "jinja"},
          {"require":  postfix_config_deps},
          {"context": {"config": config_context }},
          {"source":   f"salt://thepostman/files/etc/postfix/aliases.j2"},
          {"name":     config_file_name},
      ]
    }
    config[run_section] = {
      "cmd.run": [
        {"name": f"/usr/bin/newaliases"},
        {"require": [config_section]},
        {"onchanges": [config_section]},
        {"watch": [config_section]},
      ]
    }

    for map_file, map_data in __salt__["pillar.get"]("postfix:maps", {}).items():
      config_section = f"postfix_map_{map_file}"
      run_section = f"postfix_postmap_{map_file}"

      postfix_service_deps.append(run_section)

      map_file_name = f"{postfix_config_dir}/{map_file}"
      postfix_managed_files.append(map_file_name)

      if isinstance(map_data, list):
        map_file_content = "\n".join(map_data)
      elif isinstance(map_data, str):
        map_file_content = map_data
      else:
        raise SaltRenderError(f"map_data for {map_file} is neither a list nor a string. Found type {type(map_data)}")

      if "sasl_passwd" == map_file:
        file_permissions = "0600"

      config[config_section] = {
        "file.managed": [
            {"user":     "root"},
            {"group":    "root"},
            {"mode":     file_permissions},
            {"require":  postfix_config_deps},
            {"contents": map_file_content},
            {"name":     map_file_name},
        ],
      }

      config[run_section] = {
        "cmd.run": [
          {"name": f"/usr/sbin/postmap {map_file_name}"},
          {"require": [config_section]},
          {"onchanges": [config_section]},
          {"watch": [config_section]},
        ]
      }

    postfix_purge_configs(config,
      postfix_config_dir,
      postfix_managed_files,
      require=["postfix_packages"],
      require_in=["postfix_service"]
    )


    config["postfix_service"] = {
      "service.running": [
        {"name": "postfix.service"},
        {"enable": True},
        {"reload": True},
        {"require": postfix_service_deps},
        {"watch":   postfix_service_deps},
      ]
    }
  else:
    config["postfix_service"] = {
      "service.dead": [
        {"name": "postfix.service"},
        {"enable": False},
      ]
    }

    postfix_purge_configs(config,
      postfix_config_dir,
      postfix_managed_files,
      require=["postfix_service"],
      require_in=["postfix_packages"],
      do_purge=True
    )

    postfix_packages.append("postfix-bdb-lmdb")
    postfix_packages.append("postfix")
    config["postfix"] = {
      "pkg.purged": [
        { "pkgs": postfix_packages },
        { "require": ["postfix_service"]},
      ]
    }

  rspamd_packages = ["rspamd"]
  rspamd_config_files = []
  rspamd_config_dir = "/etc/rspamd"
  if "rspamd" in __pillar__ and __salt__["pillar.get"]("rspamd:enabled", True):
    config["rspamd_packages"] = {
      "pkg.installed": [
        { "pkgs": rspamd_packages },
      ]
    }

    file_permissions = "0640"

    for config_file_section, config_section_data in __salt__["pillar.get"]("rspamd:config", {}).items():
      for config_file, config_data in config_section_data.items():

        config_section = f"rspamd_{config_file_section}_{config_file}"
        config_file_name = f"{rspamd_config_dir}/{config_file_section}.d/{config_file}.conf"
        config_file_content = rspamd_format_config(config_data)
        rspamd_service_deps = ["rspamd_configcheck"]
        config[config_section] = {
          "file.managed": [
              {"user":         "root"},
              {"group":        "_rspamd"},
              {"mode":         file_permissions},
              {"contents":     config_file_content},
              {"name":         config_file_name},
              {"require":      ["rspamd_packages"]},
              {'require_in':   rspamd_service_deps},
              {'watch_in':     rspamd_service_deps},
              {'onchanges_in': rspamd_service_deps},
          ],
        }

    rspamd_dkim_path = "/etc/rspamd/dkim"
    for dkim_domain, dkim_domain_data in  __salt__["pillar.get"]("rspamd:config:local:dkim_signing:domain", {}).items():
      if "path" in dkim_domain_data and "selector" in dkim_domain_data:
        rspamd_generate_key(config, dkim_domain, dkim_domain_data["selector"], dkim_domain_data["path"], require_in=rspamd_service_deps)
      elif "selectors" in dkim_domain_data:
        for selector_block in dkim_domain_data["selectors"]:
          if "path" in selector_block and "selector" in selector_block:
            rspamd_generate_key(config, dkim_domain, selector_block["selector"], selector_block["path"], require_in=rspamd_service_deps)
          else:
            raise SaltConfigurationError(f"Can not handle {dkim_domain}: {selector_block}")
      else:
        raise SaltConfigurationError(f"Can not handle {dkim_domain}: {dkim_domain_data}")

    config["rspamd_config"] = {
      "cmd.run": [
        {'name':       'rspamadm configtest'},
        {'require_in': ['rspamd_service']},
      ]
    }

    if __salt__["pillar.get"]("rspamd:running", True):
      config["rspamd_service"] = {
        "service.running": [
          {"name": "rspamd.service"},
          {"enable": True},
          {"reload": True},
        ]
      }
  else:
    config["rspamd_service"] = {
      "service.dead": [
        {"name": "rspamd.service"},
        {"enable": False},
      ]
    }

    config["rspamd_packages"] = {
      "pkg.purged": [
        { "pkgs": rspamd_packages },
        { "require": ["rspamd_service"]},
      ]
    }

  dovecot_config_dir = "/etc/dovecot"
  dovecot_config_files = []
  if "dovecot" in __pillar__ and __salt__["pillar.get"]("dovecot:enabled", True):
    dovecot_packages = ['dovecot24']

    for fts in __salt__["pillar.get"]("dovecot:fts", []):
      dovecot_packages.append(f"dovecot24-fts-{fts}")

    for auth_backend in __salt__["pillar.get"]("dovecot:auth_backends", []):
      dovecot_packages.append(f"dovecot24-backend-{auth_backend}")

    for plugin in __salt__["pillar.get"]("dovecot:plugins", []):
      dovecot_packages.append(f"dovecot24-plugin-{plugin}")

    config["dovecot_packages"] = {
      "pkg.installed": [
        {'pkgs': dovecot_packages}
      ]
    }
    for config_file, _ in __salt__["pillar.get"]("dovecot:config", {}).items():
      pillar_key   = f"dovecot:config:{config_file}"
      section_name = f"dovecot_config_{config_file}"
      config_filename = f"{dovecot_config_dir}/{config_file}.conf"

      section_defaults = dovecot_config_defaults.get(config_file, {})

      config_context = __salt__["pillar.get"](pillar_key, default=section_defaults, merge=True)
      dovecot_config_content = ["""# Managed by salt
"""]
      for key, value in config_context.items():
        dovecot_format_pair(dovecot_config_content, key, value)

      dovecot_config_files.append(config_filename)
      config[section_name] = {
        "file.managed" : [
          {'name': config_filename},
          {'mode': '0640'},
          {'user': 'root'},
          {'group': 'root'},
          {'template': 'jinja'},
          {'contents': dovecot_config_content},
          {'require': ['dovecot_packages']},
          {'require_in': ["dovecot_service"]},
          {'onchanges_in': ["dovecot_service"]},
          {'watch_in': ["dovecot_service"]},
        ]
      }

    config["dovecot_service"] = {
      'service.running': [
        {'name': 'dovecot.service'},
        {'enable': True},
        {'reload': True},
      ]
    }

    dovecot_purge_configs(config, dovecot_config_dir,dovecot_config_files,
      require=["dovecot_packages"],
      require_in=["dovecot_service"]
    )
  else:
    config["dovecot_service"] = {
      "service.dead": [
        {"name": "dovecot.service"},
        {"enable": False},
      ]
    }

    dovecot_purge_configs(config,
      dovecot_config_dir,
      dovecot_config_files,
      require=["dovecot_service"],
      require_in=["dovecot_packages"],
      do_purge=True
    )

    config["dovecot_packages"] = {
      "pkg.purged": [
        { "pkgs": ['dovecot24'] },
      ]
    }

  return config