# Define: install_site
#
# Install nginx vhost
# This definition is private, not intended to be instantiated directly
#
define nginx::install_site(
  $sites_available = hiera('sites_available', $nginx::params::sites_available),
  $sites_enabled   = hiera('sites_enabled', $nginx::params::sites_enabled),
  $group           = hiera('group', $nginx::params::group),
  $content         = undef,
  $source          = undef,
  $listen          = undef,
  $server_name     = undef,
  $root            = undef,
  $locations       = undef,
) {
  # first, make sure the site config exists
  case $content {
    undef: {
      case $source {
        undef: {
          file { "${sites_available}/${name}":
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
          file { "${sites_available}/${name}":
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
      file { "${sites_available}/${name}":
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
  file { "${sites_enabled}/${name}":
    ensure => link,
    target => "${sites_available}/${name}",
    notify  => Service['nginx'],
    require => File["sites-${name}"],
  }
  if $root != undef {
    # ensure mkdir $root
    file { $root:
      ensure  => directory,
      mode    => '0750',
      owner   => 'root',
      group   => $group,
      require => Package['nginx'],
       notify  => Service['nginx'],
    } # end file   
  } # end conditional
}  # end nginx::install_site()
