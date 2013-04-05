# Define: install_site
#
# Install nginx vhost
# This definition is private, not intended to be instantiated directly
#
define nginx::install_site(
  $sites_available = $nginx::params::sites_available,
  $sites_enabled   = $nginx::params::sites_enabled,
  $content         = undef,
  $source          = undef,
  $listen          = undef,
  $server_name     = undef,
  $ssl_certificate = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = undef,
  $root            = undef,
  $locations       = undef,
) {
  $user = $nginx::user
  $group = $nginx::group

  # first, make sure the site config exists
  case $content {
    undef: {
      case $source {
        undef: {
          file { "${sites_available}/${name}.conf":
            ensure  => present,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            content => template('nginx/site.erb'),
            alias   => "sites-${name}",
            notify  => Service['nginx'],
            require => Package['nginx'],
          }
        }
        default: {
          file { "${sites_available}/${name}.conf":
            ensure  => present,
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            alias   => "sites-${name}",
            source => $source,
            require => Package['nginx'],
            notify  => Service['nginx'],
          }
        }
      }
    }
    default: {
      file { "${sites_available}/${name}.conf":
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        alias   => "sites-${name}",
        content => $content,
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
  }
  # now, enable it.
  file { "${sites_enabled}/${name}.conf":
    ensure => link,
    target => "${sites_available}/${name}.conf",
    notify  => Service['nginx'],
    require => File["sites-${name}"],
  }
  if $root != undef {
    # ensure mkdir $root
    file { $root:
      ensure  => directory,
      mode    => '2755',
      owner   => $user,
      group   => $group,
      require => Package['nginx'],
      notify  => Service['nginx'],
    } # end file   
  } # end conditional
}  # end nginx::install_site()
