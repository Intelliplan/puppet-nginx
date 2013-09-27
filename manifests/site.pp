# Define: nginx::site
#
# Install a nginx site in /etc/nginx/sites-available (and symlink in /etc/nginx/sites-enabled).
#
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * content: site definition (should be a template).
# * root: document root (Required)
# * server_name : server_name directive (could be an array)
# * listen : address/port the server listen to. Defaults to 80. Auto enable ssl if 443
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
# * include : custom include for the site (could be an array). Include files must exists
#   to avoid nginx reload errors. Use with nginx::site_include
# * ssl_certificate : ssl_certificate path. If empty auto-generating ssl cert
# * ssl_certificate_key : ssl_certificate_key path. If empty auto-generating ssl cert key
#   See http://wiki.nginx.org for details.
#
define nginx::site(
  $content             = undef,
  $source              = undef,
  $root                = undef,
  $ensure              = 'present',
  $include             = '',
  $listen              = '80',
  $server_name         = undef,
  $access_log          = undef,
  $ssl_certificate     = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = '5m',
  $locations           = [],
  $return              = undef,
) {
  $etc_dir = $nginx::etc_dir
  $log_dir = $nginx::log_dir

  $real_server_name = $server_name ? {
    undef   => $name,
    default => $server_name,
  }

  $real_access_log = $access_log ? {
    undef   => "${log_dir}/${name}_access.log",
    default => $access_log,
  }

  if straryinclude($listen, '443') and  $ensure == 'present'{
    $ssl_certificate_name = "${etc_dir}/ssl/${name}.pem"
    $ssl_certificate_key_name = "${etc_dir}/ssl/${name}.key"
    # Autogenerating ssl certs
    if ($ssl_certificate == undef or $ssl_certificate_key == undef) {
      nginx::create_ssl_cert { $name:
        server_name => $real_server_name,
      }
    }
    else {
      file { $ssl_certificate_name:
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => $ssl_certificate,
      }
      file { $ssl_certificate_key_name:
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => $ssl_certificate_key,
      }

      Service['nginx'] <~ File[$ssl_certificate_name]
      Service['nginx'] <~ File[$ssl_certificate_key_name]
    }
  }

  case $ensure {
    'present' : {
      nginx::install_site { $name:
        content             => $content,
        source              => $source,
        listen              => $listen,
        server_name         => $real_server_name,
        ssl_certificate     => $ssl_certificate_name,
        ssl_certificate_key => $ssl_certificate_key_name,
        ssl_session_timeout => $ssl_session_timeout,
        root                => $root,
        locations           => $locations,
      }
    }
    'absent' : {
      nginx::disable_site { $name: }
    }
    default: { err ("Unknown ensure value: '$ensure'") }
  }
}
