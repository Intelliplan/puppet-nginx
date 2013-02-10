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
##
define nginx::site(
  $content     = undef,
  $source      = undef,
  $root        = undef,
  $ensure      = 'present',
  $index       = 'index.html',
  $include     = '',
  $listen      = '80',
  $server_name = undef,
  $access_log  = undef,
  $ssl_certificate     = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = '5m',
  $log_dir     = hiera('log_dir', $nginx::params::log_dir)
) {

  case $ensure {
    'present' : {
       nginx::install_site { $name:
         content => $content,
         source  => $source,
         root    => $root
       }
    }
    'absent' : {
       nginx::disable_site { $name: }
   }
    default: { err ("Unknown ensure value: '$ensure'") }
  }

  $real_server_name = $server_name ? {
    undef   => $name,
    default => $server_name,
  }

  $real_access_log = $access_log ? {
    undef   => "${log_dir}/${name}_access.log",
    default => $access_log,
  }

  # Autogenerating ssl certs
  if $listen == '443' and  $ensure == 'present' and ($ssl_certificate == undef or $ssl_certificate_key == undef) {
    nginx::create_ssl_cert { $name: }

    $real_ssl_certificate = $ssl_certificate ? {
      undef   => "/etc/nginx/ssl/${name}.pem",
      default => $ssl_certificate,
    }
  
    $real_ssl_certificate_key = $ssl_certificate_key ? {
      undef   => "/etc/nginx/ssl/${name}.key",
      default => $ssl_certificate_key,
    }
  }
}