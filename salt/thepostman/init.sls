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
log = logging.getLogger("thepostman")

config_defaults = {
    'master.cf': {
        'smtp': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'smtp',},
        'pickup': {'type': 'unix', 'private': 'n', 'unpriv': '-', 'chroot': 'n', 'wakeup': '60', 'maxproc': '1', 'command': 'pickup',},
        'cleanup': {'type': 'unix', 'private': 'n', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '0', 'command': 'cleanup',},
        'qmgr': {'type': 'unix', 'private': 'n', 'unpriv': '-', 'chroot': 'n', 'wakeup': '300', 'maxproc': '1', 'command': 'qmgr',},
        'tlsmgr': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '1000?', 'maxproc': '1', 'command': 'tlsmgr',},
        'rewrite': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'trivial-rewrite',},
        'bounce': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '0', 'command': 'bounce',},
        'defer': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '0', 'command': 'bounce',},
        'trace': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '0', 'command': 'bounce',},
        'verify': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '1', 'command': 'verify',},
        'flush': {'type': 'unix', 'private': 'n', 'unpriv': '-', 'chroot': 'n', 'wakeup': '1000?', 'maxproc': '0', 'command': 'flush',},
        'proxymap': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'proxymap',},
        'proxywrite': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '1', 'command': 'proxymap',},
        'relay': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'smtp', 'args': '-o syslog_name=${multi_instance_name?{$multi_instance_name}:{postfix}}/$service_name'},
        'showq': {'type': 'unix', 'private': 'n', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'showq',},
        'error': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'error',},
        'retry': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'error',},
        'discard': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'discard',},
        'local': {'type': 'unix', 'private': '-', 'unpriv': 'n', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'local',},
        'virtual': {'type': 'unix', 'private': '-', 'unpriv': 'n', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'virtual',},
        'lmtp': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '-', 'command': 'lmtp',},
        'anvil': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '1', 'command': 'anvil',},
        'scache': {'type': 'unix', 'private': '-', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '1', 'command': 'scache',},
        'postlog': {'type': 'unix-dgram', 'private': 'n', 'unpriv': '-', 'chroot': 'n', 'wakeup': '-', 'maxproc': '1', 'command': 'postlogd',},
    },
    'main.cf': {
        'compatibility_level': '3.10',
        'queue_directory': '/var/spool/postfix',
        'command_directory': '/usr/sbin',
        'daemon_directory': '/usr/lib/postfix/bin/',
        'data_directory': '/var/lib/postfix',
        'mail_owner': 'postfix',
        'unknown_local_recipient_reject_code': '550',
        'smtpd_banner': '$myhostname ESMTP',
        'debug_peer_level': '2',
        'debugger_command': ['', '\tPATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin', 'ddd $daemon_directory/$process_name $process_id & sleep 5'],
        'sendmail_path': '/usr/sbin/sendmail',
        'newaliases_path': '/usr/bin/newaliases',
        'mailq_path': '/usr/bin/mailq',
        'setgid_group': 'maildrop',
        'html_directory': '/usr/share/doc/packages/postfix-doc/html',
        'manpage_directory': '/usr/share/man',
        'sample_directory': '/usr/share/doc/packages/postfix-doc/samples',
        'readme_directory': '/usr/share/doc/packages/postfix-doc/README_FILES',
        'biff': 'no',
        'content_filter': '',
        'delay_warning_time': '0h',
        'smtp_dns_support_level': 'enabled',
        'disable_mime_output_conversion': 'no',
        'disable_vrfy_command': 'yes',
        'inet_interfaces': 'all',
        'inet_protocols': 'ipv4',
        'masquerade_classes': 'envelope_sender, header_sender, header_recipient',
        'masquerade_domains': '',
        'masquerade_exceptions': '',
        'mydestination': '$myhostname, localhost.$mydomain, localhost',
        'mynetworks_style': 'subnet',
        'relayhost': '',
        'alias_maps': '',
        'canonical_maps': '',
        'relocated_maps': '',
        'sender_canonical_maps': '',
        'transport_maps': '',
        'mail_spool_directory': '/var/mail',
        'message_strip_characters': '',
        'defer_transports': '',
        'mailbox_command': '',
        'mailbox_transport': '',
        'mailbox_size_limit': '0',
        'message_size_limit': '0',
        'strict_8bitmime': 'no',
        'strict_rfc821_envelopes': 'no',
        'smtpd_delay_reject': 'yes',
        'smtpd_helo_required': 'yes',
        'smtpd_client_restrictions': '',
        'smtpd_helo_restrictions': '',
        'smtpd_sender_restrictions': '',
        'smtpd_recipient_restrictions': '',
        'smtpd_forbid_bare_newline': 'normalize',
        'smtpd_forbid_bare_newline_exclusions': '$mynetworks',
        'smtp_sasl_auth_enable': 'no',
        'smtp_sasl_security_options': '',
        'smtp_sasl_password_maps': '',
        'smtpd_sasl_auth_enable': 'no',
        'smtpd_sasl_type': 'cyrus',
        'smtpd_sasl_path': 'smtpd',
        'relay_clientcerts': '',
        'smtp_tls_security_level': '',
        'smtp_tls_CAfile': '',
        'smtp_tls_CApath': '',
        'smtp_tls_cert_file': '',
        'smtp_tls_key_file': '',
        'smtp_tls_session_cache_database': '',
        'smtpd_tls_security_level': '',
        'smtpd_tls_CAfile': '',
        'smtpd_tls_CApath': '',
        'smtpd_tls_cert_file': '',
        'smtpd_tls_key_file': '',
        'smtpd_tls_ask_ccert': 'no',
        'smtpd_tls_exclude_ciphers': 'RC4',
        'smtpd_tls_received_header': 'no',
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

def format_rspamd(config_data, indent_count=0):
  lines = []
  for key, value in config_data.items():
    indent_str = " " * indent_count
    if isinstance(value,str):
      lines.append(f"{indent_str}{key} = \"{value}\";")
    elif isinstance(value, list):
      value_str = ", ".join([f"\"{v}\"" for v in value])
      lines.append(f"{indent_str}{key} = [{value_str}];")
    elif isinstance(value, dict):
      lines.append(f"{indent_str}{key} {{")
      lines.extend(format_rspamd(value, indent_count+2))
      lines.append(f"{indent_str}}}")

  return lines

def run():
  config = {}

  if "postfix" in __pillar__ and __pillar__["postfix"].get("enabled", True):
    postfix_pillar = __pillar__["postfix"]
    postfix_packages = ["swaks"]

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
      if "sasl_passwd" == config_file:
        file_permissions = "0600"

      config_section = f"postfix_{config_file}"
      postfix_service_deps.append(config_section)

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
            {"name":     f"/etc/postfix/{config_file}"},
        ]
      }

    config_file = "aliases"
    config_section = f"postfix_{config_file}"
    config_file_name = f"/etc/postfix/{config_file}"
    run_section = "postfix_postalias"

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

      map_file_name = f"/etc/postfix/{map_file}"

      if isinstance(map_data, list):
        map_file_content = "\n".join(map_data)
      elif isinstance(map_data, str):
        map_file_content = map_data
      else:
        raise SaltRenderError(f"map_data for {map_file} is neither a list nor a string. Found type {type(map_data)}")

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

    config["postfix_service"] = {
      "service.running": [
        {"name": "postfix.service"},
        {"enable": True},
        {"reload": True},
        {"require": postfix_service_deps},
        {"watch":   postfix_service_deps},
      ]
    }

  rspamd_packages = ["rspamd"]
  if "rspamd" in __pillar__ and __pillar__["rspamd"].get("enabled", True):
    rspamd_service_deps = ["rspamd_packages"]

    config["rspamd_packages"] = {
      "pkg.installed": [
        { "pkgs": rspamd_packages },
      ]
    }

    file_permissions = "0640"

    for config_file, config_data in __salt__["pillar.get"]("rspamd:config:local", {}).items():

      config_section = f"rspamd_local_{config_file}"
      config_file_name = f"/etc/rspamd/local.d/{config_file}.cfg"
      config_file_content = format_rspamd(config_data)

      rspamd_service_deps.append(config_section)

      config[config_section] = {
        "file.managed": [
            {"user":     "root"},
            {"group":    "_rspamd"},
            {"mode":     file_permissions},
            {"require":  ["rspamd_packages"]},
            {"contents": config_file_content},
            {"name":     config_file_name},
        ],
      }

    config["rspamd_service"] = {
      "service.running": [
        {"name": "rspamd.service"},
        {"enable": True},
        {"reload": True},
        {"require": rspamd_service_deps},
        {"watch":   rspamd_service_deps},
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


  return config